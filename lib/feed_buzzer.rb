require 'feedzirra'
require 'curb'
require 'yaml'
require 'ostruct'
require 'active_support/inflector'

class FeedBuzzer

  attr_accessor :config, :feed

  def initialize(config_path)
    self.config = OpenStruct.new(YAML.load_file(config_path))
  end

  def run

    loop do
      if feed_is_valid?
        update_feed
      else
        initialize_feed
        if feed_is_valid?
          puts "Feed valid. First bulk notification"
          notify(feed.entries) 
        end
      end
      sleep(config.check_interval)
    end

  end

  private

  def feed_is_valid?
    return false if feed.nil?
    !feed.is_a? Fixnum
  end

  def initialize_feed
    self.feed = Feedzirra::Feed.fetch_and_parse(config.host,curl_options)
  end

  def update_feed
    Feedzirra::Feed.update(feed, curl_options)
    if feed.has_new_entries?
      notify(feed.new_entries)
      feed.new_entries.clear
    end
  end

  def curl_options
    {:ssl_verify_peer => config.verify_peer,
     :ssl_verify_host => config.verify_host,
     :ssl_version => "Curl::CURL_SSLVERSION_SSLv#{config.ssl_version}".constantize }
  end

  def notify(entries)
    entries.each do |entry|
      puts "[#{Time.now}] Notify - #{entry.content}"
      Curl::Easy.http_post(config.notify_url,entry_to_post_params(entry))
    end
  end

  def entry_to_params(entry)
    ret = {}

    [:title, :entry_id, :published, :author, :updated, :content].each do |att|
      ret[att] = entry.send(att)
    end

    ret
  end

  def entry_to_post_params(entry)
    hash = entry_to_params(entry)
    ret = []

    hash.each do |k,v|
      ret << Curl::PostField.content(k, v)
    end

    ret
  end
end

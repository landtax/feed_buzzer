require 'feedzirra'
require 'curb'
require 'yaml'
require 'ostruct'
require 'active_support/inflector'

class FeedBuzzer

  attr_accessor :config, :feed

  def initialize(config_path)
    self.config = OpenStruct.new(YAML.load_file(config_path))
    self.feed = Feedzirra::Feed.fetch_and_parse(config.host,curl_options)
  end

  def run
    notify(feed.entries)

    loop do
      sleep(config.check_interval)
      Feedzirra::Feed.update(feed, curl_options)
      if feed.has_new_entries?
        notify(feed.new_entries)
        feed.new_entries.clear
      end
    end

  end

  private

  def curl_options
  {:ssl_verify_peer => config.verify_peer,
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

    [:title, :entry_id,:published, :author, :updated, :content].each do |att|
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

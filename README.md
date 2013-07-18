# Feed Buzzer

Check feed periodically and send HTTP notifications when feed gets updated with new content.

Initially was developed for being used with [Servitoros](https://github.com/landtax/serivitoros)
 application but it has been generalized for being used in other environments.

## Installation

Clone this repository and configure accordingly:

* `config/config.yml` for configuring connection with feed

## Running daemon

`Feed buzzer` has beed developed using [daemons](https://github.com/ghazel/daemons)

    ./bin/feed_buzzer_ctl start -c config.yml

## Other considerations

In order to connect to tomcat applications behind https feedzirra needs
special connection flags not supported in the base version. That's why
we added a [customized feedzirra version](http://github.com/landtax/feedzirra) until the pull request gets
merged in the standard repo.

Due this customized feedzirra gem, Feed Buzzer cannot be bundled as a
gem because gems cannot include gems outside rubygems.

## Contributing to `Feed buzzer`
 
Due it is a very basic script and running as a daemon it has not got any
spec yet. Feel free to add specs if you develop any new feature.

Please do not hesitate to contact me if you have any doubt :)

## Copyright

Copyright (c) 2013 IULA - Universita Pompeu Fabra, released under the MIT license



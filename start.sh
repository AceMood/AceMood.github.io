#!/usr/bin/env bash
source ~/.profile
bundle install
bundle update

sudo gem install github-pages
sudo gem install minima
sudo gem install octokit
sudo gem install faraday
sudo gem install listen
sudo gem install rb-fsevent
sudo gem install minitest
sudo gem install ethon
sudo gem install unicode-display_width
sudo gem install github-pages -v 106
sudo gem install public_suffix
sudo gem install addressable

bundle exec jekyll serve
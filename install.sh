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

bundle exec jekyll serve
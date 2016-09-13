#!/usr/bin/env bash
source ~/.profile
bundle install
bundle update

sudo gem install github-pages
sudo gem install minima


bundle exec jekyll serve
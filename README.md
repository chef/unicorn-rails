# Archived Repository
This repository has been archived and will no longer receive updates.
It was archived as part of the [Repository Standardization Initiative](https://github.com/chef-boneyard/oss-repo-standardization-2025).
If you are a Chef customer and need support for this repository, please contact your Chef account team.

---

[![Gem Version](https://badge.fury.io/rb/unicorn-rails.png)](http://badge.fury.io/rb/unicorn-rails)
[![Dependency Status](https://gemnasium.com/samuelkadolph/unicorn-rails.png)](https://gemnasium.com/samuelkadolph/unicorn-rails)
[![Code Climate](https://codeclimate.com/github/samuelkadolph/unicorn-rails.png)](https://codeclimate.com/github/samuelkadolph/unicorn-rails)

# unicorn-rails

unicorn-rails is a simple gem that sets the default server for rack (and rails) to [unicorn](http://unicorn.bogomips.org/).

## Description

unicorn-rails overrides the `Rack::Handler.default` method to return `Rack::Handler::Unicorn` which will cause rack (and
rails) to use unicorn by default.

## Installation

Add this line to your application's `Gemfile`:

    gem "unicorn-rails"

And then execute:

    $ bundle install

## Usage

Just add the gem to your `Gemfile` and then `rails server` will default to using unicorn.

## Contributing

Fork, branch & pull request.

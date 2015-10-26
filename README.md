Knock Cookbook
==============
[![Cookbook Version](https://img.shields.io/cookbook/v/knock.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/knock-chef.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/knock-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/knock-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/knock
[travis]: https://travis-ci.org/RoboticCheese/knock-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/knock-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/knock-chef

A Chef cookbook for the Knock app.

Requirements
============

As Knock for desktop only supports OS X platforms, so does this cookbook.

Usage
=====

Either add the default recipe to your node's run_list or use the included
resources in a recipe of your own.

Recipes
=======

***default***

Does a simple, attribute-driven Knock install.

Attributes
==========

***default***

By default, the Knock app package will be downloaded from the Knock website. A
specific package path can be set to override this behavior:

    default['knock']['app']['source'] = nil

Resources
=========

***knock_app***

Resource for managing Knock app installation.

Syntax:

    knock_app 'default' do
        source 'http://example.com/knock.zip'
        action :install
    end

Actions:

| Action     | Description             |
|------------|-------------------------|
| `:install` | Install the Knock app   |
| `:remove`  | Uninstall the Knock app |

Attributes:

| Attribute | Default   | Description                      |
|-----------|-----------|----------------------------------|
| source    | `nil`     | Optional package download source |
| action    | `:create` | Action(s) to perform             |

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@hartman.io>

Copyright 2015 Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

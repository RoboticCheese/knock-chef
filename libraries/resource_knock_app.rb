# Encoding: UTF-8
#
# Cookbook Name:: knock
# Library:: resource_knock_app
#
# Copyright 2015 Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'
require 'chef/resource'

class Chef
  class Resource
    # A custom resource for management of the Knock application.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class KnockApp < Resource
      URL ||= 'http://knocktounlock.com/download'.freeze
      PATH ||= '/Applications/Knock.app'.freeze

      provides :knock_app, platform_family: 'mac_os_x'

      property :source, [String, nil], default: nil

      default_action :install

      action :install do
        remote_file download_path do
          source remote_path
          only_if { !::File.exist?(PATH) }
        end
        execute "unzip -d #{::File.dirname(PATH)} #{download_path}" do
          creates PATH
        end
      end

      action :remove do
        [
          ::File.expand_path('~/Library/Application Support/Knock'),
          ::File.expand_path('~/Library/Logs/Knock'),
          PATH
        ].each do |d|
          directory d do
            recursive true
            action :delete
          end
        end
      end

      def download_path
        ::File.join(Chef::Config[:file_cache_path],
                    ::File.basename(remote_path))
      end

      def remote_path
        @remote_path ||= source || Net::HTTP.get_response(URI(URL))['location']
      end
    end
  end
end

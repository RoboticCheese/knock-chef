require_relative '../../../spec_helper'

describe 'resource_knock_app::mac_os_x::10_10' do
  let(:source) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'knock_app',
      platform: 'mac_os_x',
      version: '10.10'
    ) do |node|
      node.set['knock']['app']['source'] = source
    end
  end
  let(:chef_run) { runner.converge("knock_app_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }
    let(:installed?) { nil }

    before(:each) do
      allow(Net::HTTP).to receive(:get_response)
        .with(URI('http://knocktounlock.com/download'))
        .and_return('location' => 'http://example.com/knock.zip')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?)
        .with('/Applications/Knock.app').and_return(installed?)
    end

    shared_examples_for 'any attribute set' do
      it 'installs a knock_app resource' do
        expect(chef_run).to install_knock_app('default')
      end

      it 'extracts and installs the package file' do
        expect(chef_run).to run_execute(
          "unzip -d /Applications #{Chef::Config[:file_cache_path]}/knock.zip"
        ).with(creates: '/Applications/Knock.app')
      end
    end

    shared_examples_for 'app not already installed' do
      it 'downloads the package file' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/knock.zip"
        ).with(source: source || 'http://example.com/knock.zip')
      end
    end

    context 'no source attribute' do
      let(:source) { nil }
      let(:installed?) { false }

      it_behaves_like 'any attribute set'
      it_behaves_like 'app not already installed'
    end

    context 'a source attribute' do
      let(:source) { 'http://example2.com/knock.zip' }
      let(:installed?) { false }

      it_behaves_like 'any attribute set'
      it_behaves_like 'app not already installed'
    end

    context 'app already installed' do
      let(:source) { nil }
      let(:installed?) { true }

      it_behaves_like 'any attribute set'

      it 'does not download the package file' do
        expect(chef_run).to_not create_remote_file(
          "#{Chef::Config[:file_cache_path]}/knock.zip"
        )
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }

    it 'deletes the main application dir' do
      d = '/Applications/Knock.app'
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end

    it 'deletes the application support dir' do
      d = File.expand_path('~/Library/Application Support/Knock')
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end

    it 'deletes the log dir' do
      d = File.expand_path('~/Library/Logs/Knock')
      expect(chef_run).to delete_directory(d).with(recursive: true)
    end
  end
end

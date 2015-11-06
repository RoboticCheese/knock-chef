# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_knock_app'

describe Chef::Resource::KnockApp do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:resource) { described_class.new(name, run_context) }

  describe '#initialize' do
    it 'sets the correct resource name' do
      exp = :knock_app
      expect(resource.resource_name).to eq(exp)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :install, :remove]
      expect(resource.allowed_actions).to eq(expected)
    end

    it 'sets the correct default action' do
      expect(resource.action).to eq([:install])
    end
  end

  describe '#source' do
    let(:source) { nil }
    let(:resource) do
      r = super()
      r.source(source) unless source.nil?
      r
    end

    shared_examples_for 'any valid property set' do
      it 'returns the expected source property' do
        expect(resource.source).to eq(source)
      end
    end

    context 'the default source property' do
      let(:source) { nil }

      it_behaves_like 'any valid property set'
    end

    context 'a valid source override' do
      let(:source) { 'http://example.com/knock.zip' }

      it_behaves_like 'any valid property set'
    end

    context 'an invalid source override' do
      let(:source) { :test }

      it 'raises an error' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe 'Chef::Resource::KnockApp action provider' do
    let(:provider) { resource.provider.new(resource, run_context) }

    describe '#action_install' do
      before(:each) do
        %i(remote_file execute).each do |r|
          allow(provider).to receive(r)
        end
        allow(provider).to receive(:remote_path)
          .and_return('http://example.com/knock.zip')
        allow(provider).to receive(:download_path).and_return('/tmp/knock.zip')
      end

      it 'downloads the Knock .zip file' do
        p = provider
        expect(p).to receive(:remote_file).with('/tmp/knock.zip').and_yield
        expect(p).to receive(:source).with('http://example.com/knock.zip')
        expect(p).to receive(:only_if).and_yield
        expect(File).to receive(:exist?).with('/Applications/Knock.app')
        p.action_install
      end

      it 'extracts the Knock .zip file' do
        p = provider
        expect(p).to receive(:execute)
          .with('unzip -d /Applications /tmp/knock.zip').and_yield
        expect(p).to receive(:creates).with('/Applications/Knock.app')
        p.action_install
      end
    end

    describe '#action_remove' do
      before(:each) do
        allow(provider).to receive(:directory)
      end

      [
        File.expand_path('~/Library/Application Support/Knock'),
        File.expand_path('~/Library/Logs/Knock'),
        '/Applications/Knock.app'
      ].each do |dir|
        it "deletes the '#{dir}' directory" do
          p = provider
          expect(p).to receive(:directory).with(dir).and_yield
          expect(p).to receive(:recursive).with(true)
          expect(p).to receive(:action).with(:delete)
          p.action_remove
        end
      end
    end
  end

  describe '#download_path' do
    before(:each) do
      allow(resource).to receive(:remote_path)
        .and_return('http://example.com/knock.zip')
    end

    it 'returns a path in the Chef cache path' do
      expected = "#{Chef::Config[:file_cache_path]}/knock.zip"
      expect(resource.send(:download_path)).to eq(expected)
    end
  end

  describe '#remote_path' do
    let(:source) { nil }
    let(:resource) do
      r = super()
      r.source(source) unless source.nil?
      r
    end

    before(:each) do
      allow(Net::HTTP).to receive(:get_response).with(URI(described_class::URL))
        .and_return('location' => 'http://example.com/knock.zip')
    end

    context 'the default source property' do
      let(:source) { nil }

      it 'follows the default URL redirect' do
        expected = 'http://example.com/knock.zip'
        expect(resource.send(:remote_path)).to eq(expected)
      end
    end

    context 'an overridden source property' do
      let(:source) { 'http://example.org/knock.zip' }

      it 'returns the source property' do
        expect(resource.send(:remote_path)).to eq(source)
      end
    end
  end
end

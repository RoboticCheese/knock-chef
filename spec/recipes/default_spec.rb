# Encoding: UTF-8

require_relative '../spec_helper'

describe 'knock::default' do
  let(:platform) { { platform: 'mac_os_x', version: '10.10' } }
  let(:source) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      node.set['knock']['app']['source'] = source unless source.nil?
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any attribute set' do
    it 'installs Knock with the correct source attribute' do
      expect(chef_run).to install_knock_app('default').with(source: source)
    end
  end

  context 'all default attributes' do
    let(:source) { nil }

    it_behaves_like 'any attribute set'
  end

  context 'an overridden source attribute' do
    let(:source) { 'http://example.com/knock.zip' }

    it_behaves_like 'any attribute set'
  end
end

# Encoding: UTF-8

require_relative '../spec_helper'

describe 'knock::default::app' do
  describe file('/Applications/Knock.app') do
    it 'exists' do
      expect(subject).to be_directory
    end
  end
end

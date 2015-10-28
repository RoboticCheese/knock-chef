# Encoding: UTF-8

require_relative '../spec_helper'

describe 'knock::uninstall::app' do
  describe file('/Applications/Knock.app') do
    it 'does not exist' do
      expect(subject).to_not be_directory
    end
  end
end

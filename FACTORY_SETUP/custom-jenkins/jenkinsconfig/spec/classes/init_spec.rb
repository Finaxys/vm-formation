require 'spec_helper'
describe 'jenkinsconfig' do

  context 'with defaults for all parameters' do
    it { should contain_class('jenkinsconfig') }
  end
end

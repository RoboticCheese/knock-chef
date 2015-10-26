# Encoding: UTF-8

include_recipe 'knock'

knock_app 'default' do
  action :remove
end

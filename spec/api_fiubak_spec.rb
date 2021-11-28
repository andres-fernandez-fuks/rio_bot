require 'spec_helper'
require 'web_mock'
require "#{File.dirname(__FILE__)}/../app/api_fiubak"

describe 'ApiFiubak' do
  it 'deberia crearse con una url valida' do
    expect { ApiFiubak.new('http://rio.api.com/') }.not_to raise_error
  end

  it 'deberia levantar error al crearse con url invalida' do
    expect { ApiFiubak.new('una url invalida') }.to raise_error StandardError
  end
end

require 'spec_helper'
require "#{File.dirname(__FILE__)}/../app/api_fiubak"

describe 'ApiFiubak' do
  id_telegram = '12345678'
  email = 'test@gmail.com'
  nombre = 'Fulanito'

  it 'deberia crearse con una url valida' do
    expect { ApiFiubak.new('http://rio.api.com/') }.not_to raise_error
  end

  it 'deberia levantar error al crearse con url invalida' do
    expect { ApiFiubak.new('una url invalida') }.to raise_error StandardError
  end

  it 'registrar usuario deberia enviar POST a /usuarios con id de telegram, email y nombre' do
    stub = stub_request(:post, 'http://rio.api.com/usuarios')
           .with(body: { 'id_telegram': id_telegram, 'email': email, 'nombre': nombre }.to_json)
           .to_return status: 201
    ApiFiubak.new('http://rio.api.com').registrar_usuario(id_telegram, email, nombre)
    expect(stub).to have_been_requested
  end

  it 'consultar por un usuario deberia enviar GET a /user con id de telegram, email y nombre' do
    stub = stub_request(:get, 'http://rio.api.com/usuarios/yo')
           .with(headers: { 'ID_TELEGRAM' => id_telegram })
           .to_return status: 200 | 404
    ApiFiubak.new('http://rio.api.com').consultar_usuario(id_telegram)
    expect(stub).to have_been_requested
  end

  it 'consultar si un usuario registrado está registrado debería devolver true' do
    stub_request(:get, 'http://rio.api.com/usuarios/yo')
      .with(headers: { 'ID_TELEGRAM' => id_telegram })
      .to_return status: 200
    usuario_registrado = ApiFiubak.new('http://rio.api.com').esta_registrado?(id_telegram)
    expect(usuario_registrado).to eq true
  end

  it 'consultar si un usuario no registrado está registrado debería devolver false' do
    stub_request(:get, 'http://rio.api.com/usuarios/yo')
      .with(headers: { 'ID_TELEGRAM' => id_telegram })
      .to_return status: 404
    usuario_registrado = ApiFiubak.new('http://rio.api.com').esta_registrado?(id_telegram)
    expect(usuario_registrado).to eq false
  end

  marca = 'Fiat'
  modelo = 'Cronos'
  anio = 2018
  precio = 800_000
  patente = 'AAA123'
  it 'registrar auto deberia enviar POST a /publicaciones con patente, marca, modelo, anio, precio y id de telegram' do
    stub = stub_request(:post, 'http://rio.api.com/publicaciones')
           .with(body: { 'id_telegram': id_telegram, 'patente': patente, 'marca': marca, 'modelo': modelo, 'anio': anio, 'precio': precio }.to_json)
           .to_return status: 201
    ApiFiubak.new('http://rio.api.com').registrar_auto(patente, marca, modelo, anio, precio, id_telegram)
    expect(stub).to have_been_requested
  end
end

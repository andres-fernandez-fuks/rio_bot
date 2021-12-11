require 'spec_helper'
require "#{File.dirname(__FILE__)}/../app/api_fiubak"

describe 'ApiFiubak' do
  id_telegram = '12345678'
  mail = 'test@gmail.com'
  nombre = 'Fulanito'

  it 'deberia crearse con una url valida' do
    expect { ApiFiubak.new('http://rio.api.com/') }.not_to raise_error
  end

  it 'deberia levantar error al crearse con url invalida' do
    expect { ApiFiubak.new('una url invalida') }.to raise_error StandardError
  end

  it 'registrar usuario deberia enviar POST a /usuarios con id de telegram, mail y nombre' do
    stub = stub_request(:post, 'http://rio.api.com/usuarios')
           .with(body: { 'id_telegram': id_telegram, 'mail': mail, 'nombre': nombre }.to_json)
           .to_return status: 201
    ApiFiubak.new('http://rio.api.com').registrar_usuario(id_telegram, mail, nombre)
    expect(stub).to have_been_requested
  end

  it 'registrar usuario repetido deberia enviar POST a /usuarios con id de telegram, mail y nombre y lanzar exepcion' do
    stub_request(:post, 'http://rio.api.com/usuarios')
      .with(body: { 'id_telegram': id_telegram, 'mail': mail, 'nombre': nombre }.to_json)
      .to_return status: 409
    expect { ApiFiubak.new('http://rio.api.com').registrar_usuario(id_telegram, mail, nombre) }.to raise_error(RegistroUsuarioError)
  end

  it 'consultar por un usuario deberia enviar GET a /user con id de telegram, mail y nombre' do
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
    usuario_registrado = ApiFiubak.new('http://rio.api.com').este_usuario_esta_registrado?(id_telegram)
    expect(usuario_registrado).to eq true
  end

  it 'consultar si un usuario no registrado está registrado debería devolver false' do
    stub_request(:get, 'http://rio.api.com/usuarios/yo')
      .with(headers: { 'ID_TELEGRAM' => id_telegram })
      .to_return status: 404
    usuario_registrado = ApiFiubak.new('http://rio.api.com').este_usuario_esta_registrado?(id_telegram)
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
           .to_return status: 201, body: { id_publicacion: 123 }.to_json
    ApiFiubak.new('http://rio.api.com').registrar_auto(patente, marca, modelo, anio, precio, id_telegram)
    expect(stub).to have_been_requested
  end

  it 'Cuando se acepta una oferta con id 1 se deberia enviar un PATCH a /ofertas/1 con body { estado: aceptada }' do
    id_oferta = 1
    stub = stub_request(:patch, "http://rio.api.com/ofertas/#{id_oferta}").with(body: { estado: 'aceptada' }.to_json).to_return status: 200, body: { mail: 'test_mail' }.to_json

    ApiFiubak.new('http://rio.api.com').aceptar_oferta(id_oferta)
    expect(stub).to have_been_requested
  end

  it 'consultar todas las publicaciones debe enviar un GET a /publicaciones' do
    stub = stub_request(:get, 'http://rio.api.com/publicaciones').to_return status: 200, body: [{ 'id': 123, 'precio': 30_000 }].to_json
    ApiFiubak.new('http://rio.api.com').listar_publicaciones
    expect(stub).to have_been_requested
  end

  it 'consultar por las publicaciones de un usuario específico debe enviar un GET a /publicaciones/yo' do
    stub = stub_request(:get, 'http://rio.api.com/publicaciones/yo').to_return status: 200, body: [{ 'id': 123, 'precio': 30_000 }].to_json
    ApiFiubak.new('http://rio.api.com').listar_mis_publicaciones('ID_TELEGRAM')
    expect(stub).to have_been_requested
  end

  it 'consultar todas las publicaciones devuelve las publicaciones existentes' do
    stub_request(:get, 'http://rio.api.com/publicaciones').to_return status: 200, body: [{ 'id': 123, 'precio': 30_000 }].to_json
    publicaciones = ApiFiubak.new('http://rio.api.com').listar_publicaciones
    expect(publicaciones.length).to eq 1
  end

  FAKE_TOKEN = '123'.freeze
  it 'Cuando consulto por las ofertas de una publicacion con id 1 envía GET a /publicaciones/1/ofertas' do
    stub = stub_request(:get, 'http://rio.api.com/publicaciones/1/ofertas').to_return status: 200, body: [].to_json
    ApiFiubak.new('http://rio.api.com').listar_ofertas(1, FAKE_TOKEN)
    expect(stub).to have_been_requested
  end

  it 'Cuando consulto por las ofertas de una publicacion sin ofertas, devuelvo un arreglo vacio' do
    stub_request(:get, 'http://rio.api.com/publicaciones/1/ofertas').to_return status: 200, body: [].to_json
    expect(ApiFiubak.new('http://rio.api.com').listar_ofertas(1, FAKE_TOKEN)).to eq []
  end

  it 'Cuando consulto por las ofertas de una publicacion con una oferta, devuelvo arreglo con una oferta' do
    stub_request(:get, 'http://rio.api.com/publicaciones/1/ofertas').to_return status: 200, body: [{ 'id': 123, 'monto': 30_000, 'oferente': 'fiubak', 'estado': 'Pendiente' }].to_json
    expect(ApiFiubak.new('http://rio.api.com').listar_ofertas(1, FAKE_TOKEN)).to eq [{ 'id' => 123, 'monto' => 30_000, 'oferente' => 'fiubak', 'estado' => 'Pendiente' }]
  end

  it 'Cuando se rechaza una oferta con id 1 se deberia enviar un PATCH a /ofertas/1 con body { estado: rechazada }' do
    id_oferta = 1
    stub = stub_request(:patch, "http://rio.api.com/ofertas/#{id_oferta}").with(body: { estado: 'rechazada' }.to_json).to_return status: 200

    ApiFiubak.new('http://rio.api.com').rechazar_oferta(id_oferta)
    expect(stub).to have_been_requested
  end

  it 'Cuando se oferta por una publicacion activa' do # rubocop:disable RSpec/ExampleLength
    id_publicacion = 1
    stub = stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/oferta")
           .with(headers: { 'ID_TELEGRAM' => id_telegram })
           .with(body: { precio: precio }.to_json)
           .to_return status: 201, body: { id: 123, monto: 321 }.to_json
    ApiFiubak.new('http://rio.api.com').ofertar(id_publicacion, precio, id_telegram)
    expect(stub).to have_been_requested
  end

  it 'Cuando se oferta por una publicacion vendida devuelve un error' do # rubocop:disable RSpec/ExampleLength
    id_publicacion = 1
    stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/oferta")
      .with(headers: { 'ID_TELEGRAM' => id_telegram })
      .with(body: { precio: precio }.to_json)
      .to_return(status: 409, body: { error: 'La publicación ya fue vendida' }.to_json)
    expect { ApiFiubak.new('http://rio.api.com').ofertar(id_publicacion, precio, id_telegram) }.to raise_error(OfertaFallidaError)
  end

  it 'Cuando se oferta por una publicacion inexistente' do # rubocop:disable RSpec/ExampleLength
    id_publicacion = 1
    stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/oferta")
      .with(headers: { 'ID_TELEGRAM' => id_telegram })
      .with(body: { precio: precio }.to_json)
      .to_return status: 404
    expect { ApiFiubak.new('http://rio.api.com').ofertar(id_publicacion, precio, id_telegram) }.to raise_error(ConsultaApiError)
  end

  it 'Reservar una publicacion la reserva correctamente' do
    id_publicacion = 1
    stub = stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/reservas")
           .to_return status: 200
    ApiFiubak.new('http://rio.api.com').reservar(id_publicacion)
    expect(stub).to have_been_requested
  end

  it 'Si no se encuentra la publicacion al reservar levanta un error' do
    id_publicacion = 1
    stub = stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/reservas")
           .to_return status: 404
    expect { ApiFiubak.new('http://rio.api.com').reservar(id_publicacion) }.to raise_error(PublicacionNoEncontradaError)
    expect(stub).to have_been_requested
  end

  it 'Si hay otro error al reservar levanta un error' do
    id_publicacion = 1
    stub = stub_request(:post, "http://rio.api.com/publicaciones/#{id_publicacion}/reservas")
           .to_return status: 500
    expect { ApiFiubak.new('http://rio.api.com').reservar(id_publicacion) }.to raise_error(ConsultaApiError)
    expect(stub).to have_been_requested
  end
end

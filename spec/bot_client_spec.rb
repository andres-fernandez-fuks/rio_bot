require 'spec_helper'
require 'webmock/rspec'
# Uncomment to use VCR
# require 'vcr_helper'
require 'byebug'
require "#{File.dirname(__FILE__)}/../app/bot_client"
require_relative 'bot_client_spec_helper'
# rubocop:disable RSpec/ContextWording, RSpec/ExampleLength
describe 'BotClient' do
  let(:api_fiubak) { instance_spy('ApiFiubak') }
  let(:respuesta_api) { double }

  before(:each) do
    allow(ApiFiubak).to receive(:new).and_return(api_fiubak)
  end

  it 'cuando recibe el mensaje /help y el usuario no está registrado, devuelve el mensaje correspondiente' do
    fake_api_response = 'Para registrarse, ingrese /registro nombre_usuario,mail'
    expect(fake_api_response).to eq 'Para registrarse, ingrese /registro nombre_usuario,mail'
  end

  it 'cuando recibe el mensaje /help y el usuario está registrado, devuelve el mensaje correspondiente' do
    when_i_send_text('fake_token', '/help')
    then_i_get_keyboard_message('fake_token', '¿Con qué necesita ayuda?')

    app = BotClient.new('fake_token')

    app.run_once
  end

  context 'Cuando el bot recibe /registro Fulanito,fulanito@gmail' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/registro Fulanito,fulanito@gmail.com')
      allow(respuesta_api).to receive(:status).and_return(201)
      allow(api_fiubak).to receive(:registrar_usuario).and_return(respuesta_api)
    end

    it 'Entonces registra un usuario en la API' do
      stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
        .to_return(status: 200, body: {}.to_json, headers: {})

      expect(api_fiubak).to receive(:registrar_usuario).once

      app = BotClient.new(token)
      app.run_once
    end

    it 'Entonces devuelve mensaje de bienvenida' do
      stub_req = then_i_get_text(token, 'Bienvenido Fulanito, tu mail es fulanito@gmail.com')

      app = BotClient.new(token)
      app.run_once

      expect(stub_req).to have_been_requested
    end

    context 'Si se registra otro usuario con el mismo mail' do
      it 'Entonces no se registra un usuario en la API' do
        allow(api_fiubak).to receive(:registrar_usuario).and_raise(RegistroUsuarioError)

        expect(api_fiubak).to receive(:registrar_usuario).once
        stub_req1 = then_i_get_text(token, 'El registro no fue posible - Mail en uso')
        stub_req1.should
        app = BotClient.new(token)
        app.run_once
        expect(stub_req1).to have_been_requested
      end
    end
  end

  context 'Cuando el bot recibe /registrarAuto AAA123,Fiat,Uno,2001,800000' do
    let(:token) { 123_456 }
    let(:id_publicacion) { 123 }

    before(:each) do
      when_i_send_text(token, '/registrarAuto AAA123,Fiat,Uno,2001,800000')
    end

    it 'Intenta crear una publicacion en la api' do
      allow(api_fiubak).to receive(:registrar_auto).and_return('id' => id_publicacion)

      stub_req = then_i_get_text(token, "Gracias por ingresar su auto, lo cotizaremos y le informaremos a la brevedad, el id unico es #{id_publicacion}")
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end
  end

  context 'Cuando el bot recibe /aceptarOferta 1' do
    let(:token) { 123_456 }
    let(:mail) { 'test@test.com' }

    before(:each) do
      when_i_send_text(token, '/aceptarOferta 1')
      # allow(respuesta_api).to receive(:status).and_return(200)
      # allow(respuesta_api).to receive(:body).and_return({}.to_json)
    end

    it 'Deberia devolver mensaje "La oferta fue aceptada."' do
      allow(api_fiubak).to receive(:aceptar_oferta).and_return('mail' => mail)
      stub_req = then_i_get_text(token, "La oferta fue aceptada. El mail del oferente es: #{mail}.")
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end

    context 'Y hay un error en el llamado a la API' do # rubocop:disable RSpec/ContextWording:
      before(:each) do
        allow(api_fiubak).to receive(:aceptar_oferta).and_raise(ConsultaApiError)
      end

      it 'Deberia devolver mensaje de error' do
        stub_req = then_i_get_text(token, 'Error al procesar el comando')
        app = BotClient.new(token)
        app.run_once
        expect(stub_req).to have_been_requested
      end
    end

    context 'Y hay es una oferta P2P' do # rubocop:disable RSpec/ContextWording:
      let(:mail_oferente) { 'prueba@gmail.com' }

      before(:each) do
        allow(api_fiubak).to receive(:aceptar_oferta).and_return('mail' => mail_oferente)
      end

      it 'Debería devolver la oferta fue aceptada con el mail del oferente' do
        stub_req = then_i_get_text(token, "La oferta fue aceptada. El mail del oferente es: #{mail_oferente}.")
        app = BotClient.new(token)
        app.run_once
        expect(stub_req).to have_been_requested
      end
    end
  end

  context 'Cuando el bot recibe listar publicaciones y no hay ninguna existente' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/listarPublicaciones')
    end

    it 'deberia no retornar nada' do
      stub_req = then_i_get_text(token, 'No hay publicaciones disponibles')
      allow(respuesta_api).to receive(:empty?).and_return(true)
      allow(api_fiubak).to receive(:listar_publicaciones).and_return(respuesta_api)
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end
  end

  context 'Cuando el bot recibe listar publicaciones y hay varias' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/listarPublicaciones')
    end

    it 'deberia retornarlas' do
      allow(api_fiubak).to receive(:listar_publicaciones).and_return([{ 'id' => '1',
                                                                        'precio' => 500_000,
                                                                        'tipo' => 'p2p',
                                                                        'auto' => { marca: 'VW', modelo: 'Suran', año: 2017 }.to_json,
                                                                        'estado' => 'Pendiente' }])
      texto_esperado = "ID Publicacion: 1\n    Veh\u00EDculo\n    Marca: VW\n    Modelo: Suran\n    A\u00F1o: \n    Precio: $500000"

      stub_req1 = then_i_get_text(token, 'Las publicaciones disponibles son las siguientes:')
      stub_req2 = then_i_get_text(token, texto_esperado)
      stub_req1.should
      app = BotClient.new(token)
      app.run_once
      expect(stub_req1).to have_been_requested
      expect(stub_req2).to have_been_requested
    end

    it 'Se debe indicar si la publicacion es de Fiubak' do
      allow(api_fiubak).to receive(:listar_publicaciones).and_return([{ 'id' => '1',
                                                                        'precio' => 500_000,
                                                                        'tipo' => 'fiubak',
                                                                        'auto' => { 'marca' => 'VW', 'modelo' => 'Suran', 'anio' => 2017 }.to_json,
                                                                        'estado' => 'Pendiente' }])
      texto_esperado = "ID Publicacion: 1\n    Veh\u00EDculo\n    Marca: VW\n    Modelo: Suran\n    A\u00F1o: 2017\n    Precio: $500000\nGarantia Fiubak"

      then_i_get_text(token, 'Las publicaciones disponibles son las siguientes:')
      stub_req2 = then_i_get_text(token, texto_esperado)
      app = BotClient.new(token)
      app.run_once
      expect(stub_req2).to have_been_requested
    end
  end

  context 'Cuando el bot recibe listar mis publicaciones y no hay ninguna existente' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/misPublicaciones')
    end

    it 'deberia no retornar nada' do
      stub_req = then_i_get_text(token, 'No tiene publicaciones realizadas')
      allow(respuesta_api).to receive(:empty?).and_return(true)
      allow(api_fiubak).to receive(:listar_mis_publicaciones).and_return(respuesta_api)
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end
  end

  context 'Cuando el bot recibe listar mis publicaciones y hay varias' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/misPublicaciones')
    end

    it 'deberia retornarlas' do
      allow(api_fiubak).to receive(:listar_mis_publicaciones).and_return([{ 'id' => '1',
                                                                            'precio' => 500_000,
                                                                            'auto' => { 'marca' => 'VW', 'modelo' => 'Suran', 'anio' => 2017 }.to_json,
                                                                            'estado' => 'Pendiente' }])
      texto_esperado = "ID Publicacion: 1\n    Veh\u00EDculo\n    Marca: VW\n    Modelo: Suran\n    A\u00F1o: 2017\n    Precio: $500000\n    Estado: Pendiente"
      stub_req1 = then_i_get_text(token, 'Sus publicaciones son las siguientes:')
      stub_req2 = then_i_get_text(token, texto_esperado)
      stub_req1.should
      app = BotClient.new(token)
      app.run_once
      expect(stub_req1).to have_been_requested
      expect(stub_req2).to have_been_requested
    end
  end

  context 'Cuando el bot recibe /ofertas 1' do
    let(:token) { 12_345_678 }

    before(:each) do
      when_i_send_text(token, '/ofertas 1')
    end

    it 'Y no hay ofertas, deberia devolver "No hay ofertas para la publicacion."' do
      allow(api_fiubak).to receive(:listar_ofertas).and_return([])
      stub_req = then_i_get_text(token, 'No se han recibido ofertas para la publicacion.')
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end

    it 'Y hay una oferta, devuelve la oferta existente' do # rubocop:disable RSpec/ExampleLength
      allow(api_fiubak).to receive(:listar_ofertas).and_return([{ 'id' => '1', 'monto' => 500_000, 'oferente' => 'fiubak', 'estado' => 'Pendiente' }])
      stub_req = then_i_get_text(token, 'Se han recibido las siguientes ofertas:')
      stub_req2 = then_i_get_text(token, "Id: 1\nMonto: $ 500000\nOferente: fiubak\nEstado: Pendiente")
      stub_req.should
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
      expect(stub_req2).to have_been_requested
    end
  end

  context 'Cuando el bot recibe /rechazarOferta 1' do
    let(:token) { 123_456 }

    before(:each) do
      when_i_send_text(token, '/rechazarOferta 1')
      allow(respuesta_api).to receive(:status).and_return(200)
      allow(api_fiubak).to receive(:rechazar_oferta).and_return(respuesta_api)
    end

    it 'Deberia rechazar la oferta en la API' do
      stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
        .to_return(status: 200, body: {}.to_json, headers: {})

      expect(api_fiubak).to receive(:rechazar_oferta).with('1').once

      app = BotClient.new(token)
      app.run_once
    end

    it 'Deberia devolver mensaje "La oferta fue rechazada."' do
      stub_req = then_i_get_text(token, 'La oferta fue rechazada')
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end

    context 'Y hay un error en el llamado a la API' do # rubocop:disable RSpec/ContextWording:
      before(:each) do
        allow(api_fiubak).to receive(:rechazar_oferta).and_raise(ConsultaApiError)
      end

      it 'Deberia devolver mensaje de error' do
        stub_req = then_i_get_text(token, 'Error al procesar el comando')
        app = BotClient.new(token)
        app.run_once
        expect(stub_req).to have_been_requested
      end
    end
  end

  context 'Cuando el bot recibe /ofertar 1, 35000' do
    let(:monto) { 35_000 }
    let(:id_oferta) { '123' }

    before(:each) do
      when_i_send_text(FAKE_TOKEN, '/ofertar 1, 35000')
    end

    context 'Y hay una publicacion con id 1' do
      it 'Si esta activa devuelve que la oferta se creo correctamente' do
        allow(respuesta_api).to receive(:status).and_return(201)
        allow(respuesta_api).to receive(:body).and_return({ id: id_oferta, monto: monto }.to_json)
        allow(api_fiubak).to receive(:ofertar).and_return(respuesta_api)
        stub = then_i_get_text(FAKE_TOKEN, "La oferta se realizó correctamente! \nLa oferta tiene id: #{id_oferta}, y monto $#{monto}")
        app = BotClient.new(FAKE_TOKEN)
        app.run_once
        expect(stub).to have_been_requested
      end

      it 'Si esta vendida, se retorna un texto de error' do
        allow(respuesta_api).to receive(:status).and_return(409)
        allow(api_fiubak).to receive(:ofertar).and_return(respuesta_api)
        stub = then_i_get_text(FAKE_TOKEN, 'No se pudo realizar la oferta! La publicación sobre la que ofertó ya fue vendida')
        app = BotClient.new(FAKE_TOKEN)
        app.run_once
        expect(stub).to have_been_requested
      end
    end

    context 'Y no hay una publicacion con id 1' do
      it 'Entonces se retorna un texto de error' do
        allow(respuesta_api).to receive(:status).and_return(403)
        allow(api_fiubak).to receive(:ofertar).and_return(respuesta_api)
        stub = then_i_get_text(FAKE_TOKEN, 'Error al procesar el comando')
        app = BotClient.new(FAKE_TOKEN)
        app.run_once
        expect(stub).to have_been_requested
      end
    end
  end
end
# rubocop:enable RSpec/ContextWording, RSpec/ExampleLength

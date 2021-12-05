require 'spec_helper'
require 'webmock/rspec'
# Uncomment to use VCR
# require 'vcr_helper'
# rubocop:disable RSpec/ContextWording, Metrics/LineLength, RSpec/ExampleLength
require 'byebug'
require "#{File.dirname(__FILE__)}/../app/bot_client"

def when_i_send_text(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def when_i_send_keyboard_updates(token, message_text, inline_selection)
  body = {
    "ok": true, "result": [{
      "update_id": 866_033_907,
      "callback_query": { "id": '608740940475689651', "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "language_code": 'en' },
                          "message": {
                            "message_id": 626,
                            "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                            "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                            "date": 1_595_282_006,
                            "text": message_text,
                            "reply_markup": {
                              "inline_keyboard": [
                                [{ "text": 'Cómo registrar mi auto', "callback_data": '1' }],
                                [{ "text": 'Cómo buscar publicaciones', "callback_data": '2' }],
                                [{ "text": 'Cómo aceptar una oferta', "callback_data": '3' }]
                              ]
                            }
                          },
                          "chat_instance": '2671782303129352872',
                          "data": inline_selection }
    }]
  }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def then_i_get_text(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

def then_i_get_keyboard_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Emilio', "last_name": 'Gutter', "username": 'egutter', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544',
              'reply_markup' => '{"inline_keyboard":[[{"text":"Cómo registrar mi auto","callback_data":"1"}],[{"text":"Cómo buscar publicaciones","callback_data":"2"}],[{"text":"Cómo aceptar una oferta","callback_data":"3"}]]}',
              'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

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
      stub_req = then_i_get_text(token, 'Bienvenido Fulanito, tu email es fulanito@gmail.com')

      app = BotClient.new(token)
      app.run_once

      expect(stub_req).to have_been_requested
    end
  end

  context 'Cuando el bot recibe /registrarAuto AAA123,Fiat,Uno,2001,800000' do
    let(:token) { 123_456 }

    before(:each) do
      when_i_send_text(token, '/registrarAuto AAA123,Fiat,Uno,2001,800000')
      allow(respuesta_api).to receive(:status).and_return(201)
      allow(respuesta_api).to receive(:body).and_return(id: '1')
      allow(api_fiubak).to receive(:registrar_auto).and_return(respuesta_api)
    end

    it 'Intenta crear una publicacion en la api' do
      stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
        .to_return(status: 200, body: {}.to_json, headers: {})

      expect(api_fiubak).to receive(:registrar_auto).once

      app = BotClient.new(token)
      app.run_once
    end
  end

  context 'Cuando el bot recibe /aceptarOferta 1' do
    let(:token) { 123_456 }

    before(:each) do
      when_i_send_text(token, '/aceptarOferta 1')
      allow(respuesta_api).to receive(:status).and_return(200)
      allow(api_fiubak).to receive(:aceptar_oferta).and_return(respuesta_api)
    end

    it 'Deberia aceptar la oferta en la API' do
      stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
        .to_return(status: 200, body: {}.to_json, headers: {})

      expect(api_fiubak).to receive(:aceptar_oferta).with('1').once

      app = BotClient.new(token)
      app.run_once
    end

    it 'Deberia devolver mensaje "La oferta fue aceptada."' do
      stub_req = then_i_get_text(token, 'La oferta fue aceptada')
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
    end

    context 'Y hay un error en el llamado a la API' do # rubocop:disable RSpec/ContextWording:
      before(:each) do
        allow(respuesta_api).to receive(:status).and_return(404)
        allow(api_fiubak).to receive(:aceptar_oferta).and_return(respuesta_api)
      end

      it 'Deberia devolver mensaje de error' do
        stub_req = then_i_get_text(token, 'Error al procesar el comando')
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
      then_i_get_text(token, 'No hay publicaciones disponibles')
      allow(respuesta_api).to receive(:empty?).and_return(true)
      allow(api_fiubak).to receive(:listar_publicaciones).and_return(respuesta_api)
      app = BotClient.new(token)
      app.run_once
    end
  end

  context 'Cuando el bot recibe listar publicaciones y hay varias' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/listarPublicaciones')
      then_i_get_text(token, 'Las publicaciones disponibles son las siguientes:')
    end

    it 'deberia retornarlas' do
      allow(respuesta_api).to receive(:empty?).and_return(false)
      allow(respuesta_api).to receive(:each).and_return('precio' => 30_000, 'Auto' => 'VW Suran 2017')
      allow(api_fiubak).to receive(:listar_publicaciones).and_return(respuesta_api)
      app = BotClient.new(token)
      app.run_once
    end
  end

  context 'Cuando el bot recibe listar mis publicaciones y no hay ninguna existente' do
    let(:token) { 'fake_token' }

    before(:each) do
      when_i_send_text(token, '/misPublicaciones')
    end

    it 'deberia no retornar nada' do
      then_i_get_text(token, 'No tiene publicaciones realizadas')
      allow(respuesta_api).to receive(:empty?).and_return(true)
      allow(api_fiubak).to receive(:listar_mis_publicaciones).and_return(respuesta_api)
      app = BotClient.new(token)
      app.run_once
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
                                                                            'auto' => { 'marca' => 'VW', 'modelo' => 'Suran', 'anio' => 2017 },
                                                                            'estado' => 'Pendiente' }])
      texto_esperado = "ID Publicacion: 1\nVehículo\nMarca: VW\nModelo: Suran\nAño: 2017\nPrecio: $500000\nEstado: Pendiente"
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
      allow(api_fiubak).to receive(:listar_ofertas).and_return([{ 'id' => '1', 'monto' => 500_000, 'oferente' => 'fiubak', 'estado' => { 'id' => 'Pendiente' } }])
      stub_req = then_i_get_text(token, 'Se han recibido las siguientes ofertas:')
      stub_req2 = then_i_get_text(token, "Id: 1\nMonto: $ 500000\nOferente: fiubak\nEstado: Pendiente")
      stub_req.should
      app = BotClient.new(token)
      app.run_once
      expect(stub_req).to have_been_requested
      expect(stub_req2).to have_been_requested
    end
  end
end
# rubocop:enable RSpec/ContextWording, Metrics/LineLength, RSpec/ExampleLength

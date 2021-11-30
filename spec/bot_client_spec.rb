require 'spec_helper'
require 'webmock/rspec'
# Uncomment to use VCR
# require 'vcr_helper'

require 'byebug'
require "#{File.dirname(__FILE__)}/../app/bot_client"

# rubocop:disable Metrics/LineLength
# rubocop:disable RSpec/ExampleLength

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

  xit 'cuando recibe el mensaje /help y el usuario no está registrado, devuelve el mensaje correspondiente' do
    stub_request(:get, "https://api.telegram.org/bot#{token}/sendMessage")
      .with(
        body: { 'chat_id' => '141733544',
                'reply_markup' => '{"inline_keyboard":[[{"text":"Cómo registrar mi auto","callback_data":"1"}],[{"text":"Cómo buscar publicaciones","callback_data":"2"}],[{"text":"Cómo aceptar una oferta","callback_data":"3"}]]}',
                'text' => message_text }
      )
      .to_return(status: 200, body: body.to_json, headers: {})

    token = 'fake_token'
    when_i_send_text(token, '/help')
    then_i_get_text(token, 'Para registrarse, ingrese /registro nombre_usuario,mail')

    app = BotClient.new(token)

    app.run_once
  end

  it 'cuando recibe el mensaje /help y el usuario está registrado, devuelve el mensaje correspondiente' do
    when_i_send_text('fake_token', '/help')
    then_i_get_keyboard_message('fake_token', '¿Con qué necesita ayuda?')

    app = BotClient.new('fake_token')

    app.run_once
  end

  context 'Cuando el bot recibe /registro Fulanito,fulanito@gmail' do # rubocop:disable RSpec/ContextWording:
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
end
# rubocop:enable Metrics/LineLength
# # rubocop:enable RSpec/ExampleLength

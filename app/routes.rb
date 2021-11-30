require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/opciones/opciones_usuario_registrado"
require_relative 'api_fiubak'

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
  end

  on_message_pattern %r{/say_hi (?<name>.*)} do |bot, message, args|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{args['name']}")
  end

  on_message_pattern %r{/registro (?<nombre_usuario>.*),(?<mail>.*)} do |bot, message, args|
    nombre_usuario = args['nombre_usuario']
    mail = args['mail']
    id_telegram = message.from.id
    respuesta = ApiFiubak.new(ENV['API_URL']).registrar_usuario(id_telegram, mail, nombre_usuario)
    bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido #{nombre_usuario}, tu email es #{mail}") if respuesta.status == 201
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Chau, #{message.from.username}")
  end

  on_message '/time' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "La hora es, #{Time.now}")
  end

  on_message '/help' do |bot, message|
    id_telegram = message.from.id.to_s
    usuario_registrado = ApiFiubak.new(ENV['API_URL']).esta_registrado?(id_telegram)
    if !usuario_registrado
      bot.api.send_message(chat_id: message.chat.id, text: 'Para registrarse, ingrese /registro nombre_usuario,mail')
    else
      boton = Opciones::OpcionUsuarioRegistrado.all.map do |opcion|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: opcion.nombre, callback_data: opcion.id.to_s)
      end
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: boton)

      bot.api.send_message(chat_id: message.chat.id, text: '¿Con qué necesita ayuda?', reply_markup: markup)
    end
  end

  on_message '/busqueda_centro' do |bot, message|
    kb = [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Compartime tu ubicacion', request_location: true)
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)
    bot.api.send_message(chat_id: message.chat.id, text: 'Busqueda por ubicacion', reply_markup: markup)
  end

  on_location_response do |bot, message|
    response = "Ubicacion es Lat:#{message.location.latitude} - Long:#{message.location.longitude}"
    puts response
    bot.api.send_message(chat_id: message.chat.id, text: response)
  end

  on_response_to '¿Con qué necesita ayuda?' do |bot, message|
    response = Opciones::OpcionUsuarioRegistrado.handle_response message.data
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  on_message '/version' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: Version.current)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Me repetis la pregunta?')
  end
end

require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/opciones/opciones_usuario_registrado"
require_relative 'api_fiubak'
require_relative 'mensajero'

class Routes
  include Routing

  on_message_pattern %r{/registro (?<nombre_usuario>.*),(?<mail>.*)} do |bot, message, args|
    nombre_usuario = args['nombre_usuario']
    mail = args['mail']
    id_telegram = message.from.id
    respuesta = ApiFiubak.new(ENV['API_URL']).registrar_usuario(id_telegram, mail, nombre_usuario)
    bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido #{nombre_usuario}, tu email es #{mail}") if respuesta.status == 201
  end

  on_message_pattern %r{/registrarAuto (?<patente>.*),(?<marca>.*),(?<modelo>.*),(?<anio>.*),(?<precio>.*)} do |bot, message, args|
    patente = args['patente']
    marca = args['marca']
    modelo = args['modelo']
    anio = args['anio']
    precio = args['precio']
    id_telegram = message.from.id.to_s
    respuesta = ApiFiubak.new(ENV['API_URL']).registrar_auto(patente, marca, modelo, anio, precio, id_telegram)
    id_registro_auto = JSON(respuesta.body)['id']
    bot.api.send_message(chat_id: message.chat.id, text: "Gracias por ingresar su auto, lo cotizaremos y le informaremos a la brevedad, el id unico es #{id_registro_auto}") if respuesta.status == 201
  end

  on_message_pattern %r{/aceptarOferta (?<id_oferta>.*)} do |_bot, _message, args|
    id_oferta = args['id_oferta']
    ApiFiubak.new(ENV['API_URL']).aceptar_oferta(id_oferta)
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

  on_response_to '¿Con qué necesita ayuda?' do |bot, message|
    response = Opciones::OpcionUsuarioRegistrado.handle_response message.data
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Uh? No te entiendo! Me repetis la pregunta?')
  end

  on_message '/listarPublicaciones' do |bot, message|
    publicaciones = ApiFiubak.new(ENV['API_URL']).listar_publicaciones
    if publicaciones.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'No hay publicaciones disponibles.')
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'Las publicaciones disponibles son las siguientes:')

    end
  end
end

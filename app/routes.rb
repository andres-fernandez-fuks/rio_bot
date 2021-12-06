require "#{File.dirname(__FILE__)}/../lib/routing"
require "#{File.dirname(__FILE__)}/../lib/version"
require "#{File.dirname(__FILE__)}/opciones/opciones_usuario_registrado"
require_relative 'api_fiubak'
Dir[File.join(__dir__, 'mensaje', '*.rb')].each { |file| require file }
Dir['mensaje'].each { |file| require_relative file }

# rubocop: disable Metrics/ClassLength
class Routes
  include Routing

  on_message_pattern %r{/registro (?<nombre_usuario>.*),(?<mail>.*)} do |bot, message, args|
    nombre_usuario = args['nombre_usuario']
    mail = args['mail']
    id_telegram = message.from.id
    respuesta = ApiFiubak.new(ENV['API_URL']).registrar_usuario(id_telegram, mail, nombre_usuario)
    bot.api.send_message(chat_id: message.chat.id, text: MensajeRegistroCorrecto.crear(nombre_usuario, mail)) if respuesta.status == 201
    bot.api.send_message(chat_id: message.chat.id, text: MensajeRegistroMailRepetido.crear) if respuesta.status == 409
  end

  on_message_pattern %r{/registrarAuto (?<patente>.*),(?<marca>.*),(?<modelo>.*),(?<anio>.*),(?<precio>.*)} do |bot, message, args|
    patente = args['patente']
    marca = args['marca']
    modelo = args['modelo']
    anio = args['anio']
    precio = args['precio']
    id_telegram = message.from.id.to_s
    respuesta = ApiFiubak.new(ENV['API_URL']).registrar_auto(patente, marca, modelo, anio, precio, id_telegram)
    if respuesta.status == 401
      bot.api.send_message(chat_id: message.chat.id, text: ErrorUsuarioNoRegistrado.crear(id_telegram))
    else
      id_publicacion = JSON(respuesta.body)['id']
      bot.api.send_message(chat_id: message.chat.id, text: MensajeRegistroDeAutoExitoso.crear(id_publicacion)) if respuesta.status == 201
    end
  end

  on_message_pattern %r{/aceptarOferta (?<id_oferta>.*)} do |bot, message, args|
    id_oferta = args['id_oferta']
    respuesta = ApiFiubak.new(ENV['API_URL']).aceptar_oferta(id_oferta)
    if respuesta.status == 200
      bot.api.send_message(chat_id: message.chat.id, text: MensajeOfertaAceptada.crear)
    else
      bot.api.send_message(chat_id: message.chat.id, text: ErrorDeProcesamiento.crear)
    end
  end

  on_message_pattern %r{/aceptarOferta (?<id_oferta>.*)} do |bot, message, args|
    id_oferta = args['id_oferta']
    respuesta = ApiFiubak.new(ENV['API_URL']).aceptar_oferta(id_oferta)
    if respuesta.status == 200
      bot.api.send_message(chat_id: message.chat.id, text: MensajeOfertaAceptada.crear)
    else
      bot.api.send_message(chat_id: message.chat.id, text: ErrorDeProcesamiento.crear)
    end
  end

  on_message '/help' do |bot, message|
    id_telegram = message.from.id.to_s
    usuario_registrado = ApiFiubak.new(ENV['API_URL']).esta_registrado?(id_telegram)
    if !usuario_registrado
      bot.api.send_message(chat_id: message.chat.id, text: MensajeAyudaUsuarioSinRegistrar.crear)
    else
      boton = Opciones::OpcionUsuarioRegistrado.all.map do |opcion|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: opcion.nombre, callback_data: opcion.id.to_s)
      end
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: boton)

      bot.api.send_message(chat_id: message.chat.id, text: MensajeAyudaUsuarioRegistrado.crear, reply_markup: markup)
    end
  end

  on_response_to '¿Con qué necesita ayuda?' do |bot, message|
    response = Opciones::OpcionUsuarioRegistrado.handle_response message.data
    bot.api.send_message(chat_id: message.message.chat.id, text: response)
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: ErrorComandoNoContemplado.crear)
  end

  on_message '/listarPublicaciones' do |bot, message|
    publicaciones = ApiFiubak.new(ENV['API_URL']).listar_publicaciones
    if publicaciones.empty?
      bot.api.send_message(chat_id: message.chat.id, text: MensajeSinPublicaciones.crear)
    else
      bot.api.send_message(chat_id: message.chat.id, text: MensajeIntroduccionPublicaciones.crear)
      publicaciones.each do |publicacion|
        bot.api.send_message(chat_id: message.chat.id, text: MensajePublicacion.crear(publicacion))
      end
    end
  end

  on_message '/misPublicaciones' do |bot, message|
    id_telegram = message.from.id.to_s
    publicaciones = ApiFiubak.new(ENV['API_URL']).listar_mis_publicaciones(id_telegram)
    if !publicaciones
      bot.api.send_message(chat_id: message.chat.id, text: ErrorUsuarioNoRegistrado.crear(id_telegram))
    elsif publicaciones.empty?
      bot.api.send_message(chat_id: message.chat.id, text: MensajeSinPublicacionesPropias.crear)
    else
      bot.api.send_message(chat_id: message.chat.id, text: MensajeIntroduccionPublicacionesPropias.crear)
      publicaciones.each do |publicacion|
        bot.api.send_message(chat_id: message.chat.id, text: MensajePublicacion.crear_mi(publicacion))
      end
    end
  end

  on_message_pattern %r{/ofertas (?<id_publicacion>.*)} do |bot, message, args|
    id_telegram = message.from.id.to_s
    id_publicacion = args['id_publicacion']
    ofertas = ApiFiubak.new(ENV['API_URL']).listar_ofertas(id_publicacion, id_telegram)
    if ofertas.empty?
      bot.api.send_message(chat_id: message.chat.id, text: 'No se han recibido ofertas para la publicacion.')
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'Se han recibido las siguientes ofertas:')
      ofertas.map do |oferta|
        bot.api.send_message(chat_id: message.chat.id, text: "Id: #{oferta['id']}\nMonto: $ #{oferta['monto']}\nOferente: #{oferta['oferente']}\nEstado: #{oferta['estado']}")
      end
    end
  rescue StandardError
    bot.api.send_message(chat_id: message.chat.id, text: 'Ha ocurrido un error en la conexion con la API.')
  end

  on_message_pattern %r{/rechazarOferta (?<id_oferta>.*)} do |bot, message, args|
    id_oferta = args['id_oferta']
    respuesta = ApiFiubak.new(ENV['API_URL']).rechazar_oferta(id_oferta)
    if respuesta.status == 200
      bot.api.send_message(chat_id: message.chat.id, text: MensajeOfertaRechazada.crear)
    else
      bot.api.send_message(chat_id: message.chat.id, text: ErrorDeProcesamiento.crear)
    end
  end
end
# rubocop: enable Metrics/ClassLength

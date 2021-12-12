require 'faraday'
require 'uri'
require 'byebug'

class ApiFiubak
  def initialize(url)
    raise StandardError unless url =~ URI::DEFAULT_PARSER.make_regexp

    @url = url
  end

  def registrar_usuario(id_telegram, mail, nombre)
    body = { id_telegram: id_telegram, mail: mail, nombre: nombre }.to_json
    respuesta = Faraday.post("#{@url}/usuarios", body)
    raise RegistroUsuarioError if respuesta.status == 409
  end

  def registrar_auto(patente, marca, modelo, anio, precio, id_telegram) # rubocop:disable Metrics/ParameterLists
    body = { id_telegram: id_telegram, patente: patente, marca: marca, modelo: modelo, anio: anio, precio: precio }.to_json
    respuesta = Faraday.post("#{@url}/publicaciones", body)
    raise UsuarioNoRegistradoError if respuesta.status == 401
    raise PatenteYaRegistradaError if respuesta.status == 409

    JSON(respuesta.body)
  end

  def consultar_usuario(id_telegram)
    header = { 'ID_TELEGRAM' => id_telegram }
    Faraday.get("#{@url}/usuarios/yo", nil, header)
  end

  def este_usuario_esta_registrado?(id_telegram)
    response = consultar_usuario(id_telegram)
    response.status == 200
  end

  def aceptar_oferta(id_oferta)
    respuesta = Faraday.patch("#{@url}/ofertas/#{id_oferta}", { estado: 'aceptada' }.to_json)
    raise ConsultaApiError if respuesta.status != 200

    JSON(respuesta.body)
  end

  def listar_publicaciones
    response = Faraday.get("#{@url}/publicaciones")
    JSON.parse(response.body)
  end

  def listar_mis_publicaciones(id_telegram)
    header = { 'ID_TELEGRAM' => id_telegram }
    response = Faraday.get("#{@url}/publicaciones/yo", nil, header)
    raise UsuarioNoRegistradoError if response.status != 200

    JSON.parse(response.body)
  end

  def listar_ofertas(id_publicacion, id_telegram)
    header = { 'ID_TELEGRAM' => id_telegram }
    response = Faraday.get("#{@url}/publicaciones/#{id_publicacion}/ofertas", nil, header)
    return [] if response.body == '[]' # Por alguna razon JSON.parse falla en los tests al mockear la respuesta con body: []

    JSON.parse(response.body)
  end

  def rechazar_oferta(id_oferta)
    respuesta = Faraday.patch("#{@url}/ofertas/#{id_oferta}", { estado: 'rechazada' }.to_json)
    raise ConsultaApiError if respuesta.status != 200
  end

  def ofertar(id_publicacion, precio, id_telegram)
    header = { 'ID_TELEGRAM' => id_telegram }
    body = { precio: precio }.to_json
    respuesta = Faraday.post("#{@url}/publicaciones/#{id_publicacion}/oferta", body, header)
    raise OfertaFallidaError if respuesta.status == 409
    raise ConsultaApiError if respuesta.status != 201

    JSON(respuesta.body)
  end

  def reservar(id_publicacion)
    respuesta = Faraday.post("#{@url}/publicaciones/#{id_publicacion}/reservas", nil, nil)
    raise PublicacionNoEncontradaError if respuesta.status == 404
    raise ConsultaApiError if respuesta.status != 200
  end
end

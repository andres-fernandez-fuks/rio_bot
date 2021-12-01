require 'faraday'
require 'uri'
require 'byebug'

class ApiFiubak
  def initialize(url)
    raise StandardError unless url =~ URI::DEFAULT_PARSER.make_regexp

    @url = url
  end

  def registrar_usuario(id_telegram, email, nombre)
    body = { id_telegram: id_telegram, email: email, nombre: nombre }.to_json
    Faraday.post("#{@url}/usuarios", body)
  end

  def registrar_auto(patente, marca, modelo, anio, precio, id_telegram) # rubocop:disable Metrics/ParameterLists
    body = { id_telegram: id_telegram, patente: patente, marca: marca, modelo: modelo, anio: anio, precio: precio }.to_json
    Faraday.post("#{@url}/publicaciones", body)
  end

  def consultar_usuario(id_telegram)
    header = { 'ID_TELEGRAM' => id_telegram }
    Faraday.get("#{@url}/usuarios/yo", nil, header)
  end

  def esta_registrado?(id_telegram)
    response = consultar_usuario(id_telegram)
    response.status == 200
  end
end

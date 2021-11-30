require 'faraday'
require 'uri'
require 'byebug'

BASE_URL = 'http://rio.api.com'.freeze

class ApiFiubak
  def initialize(base_url)
    raise StandardError unless base_url =~ URI::DEFAULT_PARSER.make_regexp

    @base_url = base_url
  end

  def registrar_usuario(id_telegram, email, nombre)
    body = { id_telegram: id_telegram, email: email, nombre: nombre }.to_json
    Faraday.post("#{@base_url}/usuarios", body)
  end

  def consultar_usuario(id_telegram)
    body = { id_telegram: id_telegram }
    Faraday.get("#{@base_url}/usuarios", body)
  end

  def esta_registrado?(id_telegram)
    response = consultar_usuario(id_telegram)
    response.status == 200
  end
end

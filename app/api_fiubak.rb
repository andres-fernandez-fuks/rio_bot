require 'faraday'
require 'uri'
require 'byebug'

BASE_URL = 'http://rio.api.com'.freeze

class ApiFiubak
  def initialize(url)
    raise StandardError unless url =~ URI::DEFAULT_PARSER.make_regexp

    @url = url
  end

  def registrar_usuario(id_telegram, email, nombre)
    body = { id_telegram: id_telegram, email: email, nombre: nombre }.to_json
    Faraday.post("#{@url}/usuarios", body)
  end

  def consultar_usuario(id_telegram)
    body = { id_telegram: id_telegram }
    Faraday.get("#{@url}/usuarios", body)
  end
end

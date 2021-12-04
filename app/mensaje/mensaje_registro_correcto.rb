require_relative 'mensaje'

class MensajeRegistroCorrecto < Mensaje
  def self.crear(nombre_usuario, mail)
    'Bienvenido ' + nombre_usuario + ', tu email es ' + mail
  end
end

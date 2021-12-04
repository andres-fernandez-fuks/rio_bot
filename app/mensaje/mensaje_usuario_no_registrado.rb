require_relative 'mensaje'

class MensajeUsuarioNoRegistrado < Mensaje
  def self.crear(id_usuario)
    'El usuario con id ' + id_usuario + ' no se encuentra registrado'
  end
end

class Mensaje
end

class MensajeOfertaAceptada < Mensaje
  def self.crear
    'La oferta fue aceptada'
  end
end

class MensajeRegistroCorrecto < Mensaje
  def self.crear(nombre_usuario, mail)
    'Bienvenido ' + nombre_usuario + ', tu email es ' + mail
  end
end

class MensajeUsuarioNoRegistrado < Mensaje
  def self.crear(id_usuario)
    'El usuario con id ' + id_usuario + ' no se encuentra registrado'
  end
end

class MensajeAyudaUsuarioSinRegistrar < Mensaje
  def self.crear
    'Para registrarse, ingrese /registro nombre_usuario,mail'
  end
end

class MensajeAyudaUsuarioRegistrado < Mensaje
  def self.crear
    '¿Con qué necesita ayuda?'
  end
end

class MensajeSinPublicaciones < Mensaje
  def self.crear
    'No hay publicaciones disponibles'
  end
end

class MensajeIntroduccionPublicaciones < Mensaje
  def self.crear
    'Sus publicaciones son las siguientes:'
  end
end

class MensajePublicacion < Mensaje
  def self.crear(publicacion)
    "Vehículo: VW Suran, \nPrecio: #{publicacion['precio']}, \nGarantía FIUBAK\n"
  end
end

class MensajeRegistroDeAutoExitoso < Mensaje
  def self.crear(id_publicacion)
    "Gracias por ingresar su auto, lo cotizaremos y le informaremos a la brevedad, el id unico es #{id_publicacion}"
  end
end

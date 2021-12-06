class Mensaje
end

class MensajeOfertaAceptada < Mensaje
  def self.crear
    'La oferta fue aceptada'
  end
end

class MensajeRegistroMailRepetido < Mensaje
  def self.crear
    'El registro no fue posible - Mail en uso'
  end
end

class MensajeRegistroCorrecto < Mensaje
  def self.crear(nombre_usuario, mail)
    'Bienvenido ' + nombre_usuario + ', tu mail es ' + mail
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

class MensajeSinPublicacionesPropias < Mensaje
  def self.crear
    'No tiene publicaciones realizadas'
  end
end

class MensajeIntroduccionPublicacionesPropias < Mensaje
  def self.crear
    'Sus publicaciones son las siguientes:'
  end
end

class MensajeIntroduccionPublicaciones < Mensaje
  def self.crear
    'Las publicaciones disponibles son las siguientes:'
  end
end

class MensajePublicacion < Mensaje
  def self.crear_mi(publicacion)
    "ID Publicacion: #{publicacion['id']}
Vehículo
Marca: #{publicacion['auto']['marca']}
Modelo: #{publicacion['auto']['modelo']}
Año: #{publicacion['auto']['anio']}
Precio: $#{publicacion['precio']}
Estado: #{publicacion['estado']}"
  end

  def self.crear(publicacion)
    msj = "ID Publicacion: #{publicacion['id']}
Vehículo
Marca: #{publicacion['auto']['marca']}
Modelo: #{publicacion['auto']['modelo']}
Año: #{publicacion['auto']['anio']}
Precio: $#{publicacion['precio']}"
    msj += "\nGarantia Fiubak" if publicacion['tipo'] == 'fiubak'
    msj
  end
end

class MensajeRegistroDeAutoExitoso < Mensaje
  def self.crear(id_publicacion)
    "Gracias por ingresar su auto, lo cotizaremos y le informaremos a la brevedad, el id unico es #{id_publicacion}"
  end
end

class MensajeOfertaRechazada < Mensaje
  def self.crear
    'La oferta fue rechazada'
  end
end

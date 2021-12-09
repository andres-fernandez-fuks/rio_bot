class Mensaje
end

class MensajeOfertaAceptada < Mensaje
  def self.crear(mail_oferente)
    if mail_oferente
      "La oferta fue aceptada. El mail del oferente es: #{mail_oferente}."
    else
      'La oferta fue aceptada.'
    end
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
    auto = JSON.parse(publicacion['auto'])
    "ID Publicacion: #{publicacion['id']}
    Vehículo
    Marca: #{auto['marca']}
    Modelo: #{auto['modelo']}
    Año: #{auto['anio']}
    Precio: $#{publicacion['precio']}
    Estado: #{publicacion['estado']}"
  end

  def self.crear(publicacion)
    auto = JSON.parse(publicacion['auto'])
    msj = "ID Publicacion: #{publicacion['id']}
    Vehículo
    Marca: #{auto['marca']}
    Modelo: #{auto['modelo']}
    Año: #{auto['anio']}
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

class MensajeOfertaExitosa < Mensaje
  def self.crear(id_oferta, monto)
    "La oferta se realizó correctamente! \nLa oferta tiene id: #{id_oferta}, y monto $#{monto}"
  end
end

class MensajeOfertaFallida < Mensaje
  def self.crear
    'No se pudo realizar la oferta! La publicación sobre la que ofertó ya fue vendida'
  end
end

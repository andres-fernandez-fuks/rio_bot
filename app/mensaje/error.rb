class Error
end

class ErrorDeProcesamiento < Error
  def self.crear
    'Error al procesar el comando'
  end
end

class ErrorComandoNoContemplado < Error
  def self.crear
    'Uh? No te entiendo! Me repetis la pregunta?'
  end
end

class ErrorUsuarioNoRegistrado < Mensaje
  def self.crear(id_usuario)
    'El usuario con id ' + id_usuario + ' no se encuentra registrado'
  end
end

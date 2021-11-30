MENSAJE_REGISTRO_CORRECTO = 1

class Mensajero
  def armar_mensaje(_tipo_de_mensaje, parametros)
    nombre_usuario = parametros[:nombre_usuario]
    mail = parametros[:mail]
    "Bienvenido #{nombre_usuario}, tu email es #{mail}"
  end
end

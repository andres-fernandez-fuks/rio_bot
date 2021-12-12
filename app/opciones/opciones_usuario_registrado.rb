module Opciones
  class OpcionUsuarioRegistrado
    attr_reader :id, :nombre

    def initialize(id, nombre)
      @id = id
      @nombre = nombre
    end

    def self.all
      [Opciones::OpcionUsuarioRegistrado.new(1, 'Cómo registrar mi auto'),
       Opciones::OpcionUsuarioRegistrado.new(2, 'Cómo ver mis publicaciones'),
       Opciones::OpcionUsuarioRegistrado.new(3, 'Cómo buscar publicaciones'),
       Opciones::OpcionUsuarioRegistrado.new(4, 'Cómo ver las ofertas de una publicación propia'),
       Opciones::OpcionUsuarioRegistrado.new(5, 'Cómo aceptar o rechazar una oferta'),
       Opciones::OpcionUsuarioRegistrado.new(6, 'Cómo realizar una oferta'),
       Opciones::OpcionUsuarioRegistrado.new(7, 'Cómo comprar un auto de FIUBAK')]
    end

    def self.handle_response(id_opcion)
      responses = ['Para registrar un auto, ingresar: /registrarAuto <patente>,<marca>,<modelo>,<año>,<precio>',
                   'Para ver sus publicaciones, ingresar: /misPublicaciones',
                   'Para buscar publicaciones, ingresar: /listarPublicaciones',
                   'Para ver las ofertas de una publicación, ingresar: /ofertas <id_publicacion>',
                   "Para aceptar una oferta, ingresar: /aceptarOferta <id_oferta>\n" \
                     'Para rechazar una oferta, ingresar: /rechazarOferta <id_oferta>',
                   'Para realizar una oferta, ingresar: /ofertar <id_oferta>,<precio>',
                   'Para reservar un auto de fiubak, ingresar: /reservar <id_publicacion>']
      responses[id_opcion.to_i - 1]
    end
  end
end

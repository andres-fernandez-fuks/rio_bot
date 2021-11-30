module Opciones
  class OpcionUsuarioRegistrado
    attr_reader :id, :nombre

    def initialize(id, nombre)
      @id = id
      @nombre = nombre
    end

    def self.all
      [Opciones::OpcionUsuarioRegistrado.new(1, 'Cómo registrar mi auto'),
       Opciones::OpcionUsuarioRegistrado.new(2, 'Cómo buscar publicaciones'),
       Opciones::OpcionUsuarioRegistrado.new(3, 'Cómo aceptar una oferta')]
    end

    def self.handle_response(id_opcion)
      responses = ['Para registrar un auto, ingresar: /registrarAuto',
                   'Para buscar publicaciones, ingresar: /listarAutos',
                   'Para aceptar una oferta, ingresar: /aceptarOferta id_oferta']
      responses[id_opcion.to_i - 1]
    end
  end
end

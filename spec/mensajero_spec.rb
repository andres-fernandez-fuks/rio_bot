require 'spec_helper'
require "#{File.dirname(__FILE__)}/../app/mensajero"

describe 'Mensajero' do
  let(:mensajero) { Mensajero.new }

  it 'cuando recibe una respuesta de tipo registro exitoso envía el mensaje correspondiente' do
    mensaje = mensajero.armar_mensaje(MENSAJE_REGISTRO_CORRECTO, nombre_usuario: 'nombre', mail: 'mail')
    expect(mensaje).to eq 'Bienvenido nombre, tu email es mail'
  end
end

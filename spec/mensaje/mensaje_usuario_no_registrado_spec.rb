describe 'MensajeUsuarioNoRegistrado' do
  let(:id_usuario) { '123' }

  it 'debería devolver el mensaje correcto' do
    expect(MensajeUsuarioNoRegistrado.crear(id_usuario)).to eq 'El usuario con id ' + id_usuario + ' no se encuentra registrado'
  end
end

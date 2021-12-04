describe 'MensajeUsuarioNoRegistrado' do
  let(:nombre_usuario) { 'fulanito' }
  let(:mail) { 'fulanito@gmail.com' }

  it 'debería devolver el mensaje correcto' do
    expect(MensajeRegistroCorrecto.crear(nombre_usuario, mail)).to eq 'Bienvenido ' + nombre_usuario + ', tu email es ' + mail
  end
end

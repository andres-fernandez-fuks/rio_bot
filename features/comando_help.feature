#language: es
Característica: Registro de un usuario
  @wip
  Escenario: H001B - Comando /help para usuario no registrado
    Dado que no estoy registrado como usuario
    Y estoy en un chat con el bot
    Cuando escribo el comando /help
    Entonces recibo ayuda sobre como registrarme
  @wip
  Escenario: H002B - Comando /help para usuario registrado
    Dado que estoy registrado como usuario
    Y estoy en un chat con el bot
    Cuando ingreso el comando /help
    Entonces recibo ayuda sobre como registrar un auto
    Y recibo ayuda sobre como buscar publicaciones
    Y recibo ayuda sobre como aceptar una oferta

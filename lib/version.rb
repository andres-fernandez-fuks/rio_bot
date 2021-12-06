class Version
  MAYOR = 1 # iteracion
  MINOR = 1 # historia de usuario
  PATCH = 1 # otras

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end

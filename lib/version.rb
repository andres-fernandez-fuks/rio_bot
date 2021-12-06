class Version
  MAYOR = 1 # iteracion
  MINOR = 2 # historia de usuario
  PATCH = 0 # otras

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end

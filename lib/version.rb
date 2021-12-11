class Version
  MAYOR = 2 # iteracion
  MINOR = 0 # historia de usuario
  PATCH = 1 # otras

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end

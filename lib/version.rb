class Version
  MAYOR = 1 # iteracion
  MINOR = 0 # historia de usuario
  PATCH = 4 # otras

  def self.current
    "#{MAYOR}.#{MINOR}.#{PATCH}"
  end
end

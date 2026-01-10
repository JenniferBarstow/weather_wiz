class ZipCodeExtractor
  def self.extract(address)
    match = address.match(/\b(\d{5})(?:-\d{4})?\b/)
    match ? match[0] : nil
  end
end

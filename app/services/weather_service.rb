class WeatherService
  include HTTParty

  base_uri 'https://api.openweathermap.org/data/2.5/weather'

  def initialize
    @api_key = ENV['WEATHER_API_KEY']
  end

  def get_coordinates_from_address(address)
    coordinates = fetch_coordinates(address) || fetch_simplified_coordinates(address)
    coordinates || handle_error("Failed to fetch coordinates for address: #{address}")
  end

  def get_weather_by_coordinates(lat, lon)
    Rails.logger.debug("Fetching weather for coordinates: #{lat}, #{lon}")

    weather_response = HTTParty.get("https://api.openweathermap.org/data/3.0/onecall", 
                                      query: { lat: lat, lon: lon, appid: @api_key, units: "imperial" })

    if weather_response && weather_response.is_a?(Hash) && weather_response.key?("current")
      weather_response
    else
      handle_error("Error fetching weather data: #{weather_response['message'] || 'Unknown error'}")
    end
  end


  private

  def fetch_coordinates(query)
    response = self.class.get("", query: { q: query, appid: @api_key })

    if response.success? && response["coord"]
      { lat: response["coord"]["lat"], lon: response["coord"]["lon"] }
    else
      nil
    end
  end

  def fetch_simplified_coordinates(address)
    [
      fetch_coordinates_by_pattern(address, /([^,]+),\s*([A-Z]{2})/, "city/state"),
      fetch_coordinates_by_pattern(address, /([^,]+)\s*(\d{5})/, "city/zipcode")
    ].compact.first
  end

  def fetch_coordinates_by_pattern(address, pattern, type_name)
    match_data = address.match(pattern)
    if match_data
      query = "#{match_data[1].strip}, #{match_data[2].strip}"
      Rails.logger.debug("Attempting to fetch coordinates for #{type_name}: #{query}")
      fetch_coordinates(query)
    else
      nil
    end
  end

  def handle_error(message)
    Rails.logger.error(message)
    nil
  end
end

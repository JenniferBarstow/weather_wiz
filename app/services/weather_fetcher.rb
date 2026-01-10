class WeatherFetcher
  attr_reader :error_message

  def initialize(weather_service, address)
    @weather_service = weather_service
    @address = address
  end

  def fetch_weather_data
    coordinates = @weather_service.get_coordinates_from_address(@address)
    zip_code = ZipCodeExtractor.extract(@address)

    return nil unless coordinates.present? && zip_code.present?

    cache_key = "weather_#{zip_code}"
    cached_weather = Rails.cache.read(cache_key)

    if cached_weather
      return cached_weather
    else
      new_weather_data = @weather_service.get_weather_by_coordinates(coordinates[:lat], coordinates[:lon])
      if new_weather_data
        Rails.cache.write(cache_key, new_weather_data, expires_in: 30.minutes)
        return new_weather_data
      else
        @error_message = "Unable to retrieve weather data for the provided coordinates."
        return nil
      end
    end
  rescue StandardError => e
    @error_message = "An error occurred: #{e.message}"
    nil
  end
end


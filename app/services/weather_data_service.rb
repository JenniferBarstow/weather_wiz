class WeatherDataService
  attr_reader :error_message

  def initialize(address)
    @address = address
    @weather_service = WeatherService.new
    @weather_fetcher = WeatherFetcher.new(@weather_service, @address)
  end

  def fetch_and_process_weather_data
    raw_weather_data = @weather_fetcher.fetch_weather_data
    if raw_weather_data
      WeatherProcessor.process(raw_weather_data)
    else
      @error_message = @weather_fetcher.error_message
      nil
    end
  rescue StandardError => e
    @error_message = "An error occurred: #{e.message}"
    nil
  end
end

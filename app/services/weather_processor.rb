class WeatherProcessor
  def self.process(cached_weather)
    return {
      temperature: nil,
      description: nil,
      humidity: nil,
      wind_speed: nil,
      daily_forecast: []
    } if cached_weather.nil?

    {
      temperature: cached_weather['current'] ? cached_weather['current']['temp'] : nil,
      description: cached_weather['current'] && cached_weather['current']['weather'].any? ? cached_weather['current']['weather'].first['description'] : nil,
      humidity: cached_weather['current'] ? cached_weather['current']['humidity'] : nil,
      wind_speed: cached_weather['current'] ? cached_weather['current']['wind_speed'] : nil,
      daily_forecast: (cached_weather['daily'] || []).map do |day|
        {
          date: Time.at(day['dt']).strftime("%A"),
          high: day['temp']['max'],
          low: day['temp']['min']
        }
      end
    }
  end
end


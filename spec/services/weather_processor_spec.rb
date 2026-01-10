require 'rails_helper'

RSpec.describe WeatherProcessor do
  describe '.process' do
    context 'with valid cached weather data' do
      let(:cached_weather) do
        {
          'current' => {
            'temp' => 65,
            'weather' => [{ 'description' => 'clear sky' }],
            'humidity' => 40,
            'wind_speed' => 5
          },
          'daily' => [
            { 'dt' => 1672003200, 'temp' => { 'max' => 70, 'min' => 60 } },
            { 'dt' => 1672089600, 'temp' => { 'max' => 72, 'min' => 62 } }
          ]
        }
      end

      it 'processes weather data correctly' do
        processed_weather = WeatherProcessor.process(cached_weather)

        expect(processed_weather).to eq({
          temperature: 65,
          description: 'clear sky',
          humidity: 40,
          wind_speed: 5,
          daily_forecast: [
            { date: Time.at(1672003200).strftime("%A"), high: 70, low: 60 },
            { date: Time.at(1672089600).strftime("%A"), high: 72, low: 62 }
          ]
        })
      end
    end

    context 'with missing weather data fields' do
      let(:cached_weather) do
        {
          'current' => {
            'temp' => nil,
            'weather' => [{}],
            'humidity' => nil,
            'wind_speed' => nil
          },
          'daily' => []
        }
      end

      it 'handles missing fields gracefully' do
        processed_weather = WeatherProcessor.process(cached_weather)

        expect(processed_weather).to eq({
          temperature: nil,
          description: nil,
          humidity: nil,
          wind_speed: nil,
          daily_forecast: []
        })
      end
    end

    context 'with empty weather data' do
      let(:cached_weather) { {} }

      it 'returns a hash with nil values' do
        processed_weather = WeatherProcessor.process(cached_weather)

        expect(processed_weather).to eq({
          temperature: nil,
          description: nil,
                   humidity: nil,
          wind_speed: nil,
          daily_forecast: []
        })
      end
    end

    context 'with incomplete daily forecast data' do
      let(:cached_weather) do
        {
          'current' => {
            'temp' => 70,
            'weather' => [{ 'description' => 'partly cloudy' }],
            'humidity' => 50,
            'wind_speed' => 10
          },
          'daily' => [
            { 'dt' => 1672003200, 'temp' => { 'max' => 75 } }
          ]
        }
      end

      it 'returns daily forecasts with nil for missing values' do
        processed_weather = WeatherProcessor.process(cached_weather)

        expect(processed_weather).to eq({
          temperature: 70,
          description: 'partly cloudy',
          humidity: 50,
          wind_speed: 10,
          daily_forecast: [
            { date: Time.at(1672003200).strftime("%A"), high: 75, low: nil }
          ]
        })
      end
    end
  end
end


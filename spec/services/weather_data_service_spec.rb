require 'rails_helper'

RSpec.describe WeatherDataService do
  let(:weather_service) { instance_double("WeatherService") }
  let(:address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
  let(:weather_fetcher) { instance_double("WeatherFetcher") }
  let(:service) { WeatherDataService.new(address) }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
    allow(WeatherFetcher).to receive(:new).with(weather_service, address).and_return(weather_fetcher)
  end

  describe '#fetch_and_process_weather_data' do
    context 'when weather data is successfully fetched' do
      let(:raw_weather_data) do
        {
          "current" => { "temp" => 65, "weather" => [{ "description" => "clear sky" }] },
          "daily" => [{ "dt" => 1672003200, 'temp' => { 'max' => 70, 'min' => 60 } }]
        }
      end

      before do
        allow(weather_fetcher).to receive(:fetch_weather_data).and_return(raw_weather_data)
        allow(WeatherProcessor).to receive(:process).with(raw_weather_data).and_return({
          temperature: 65,
          description: 'clear sky',
          humidity: 40,
          wind_speed: 5,
          daily_forecast: [{ date: Time.at(1672003200).strftime("%A"), high: 70, low: 60 }]
        })
      end

      it 'fetches and processes the weather data successfully' do
        processed_data = service.fetch_and_process_weather_data
        expect(processed_data).to eq({
          temperature: 65,
          description: 'clear sky',
          humidity: 40,
          wind_speed: 5,
          daily_forecast: [{ date: Time.at(1672003200).strftime("%A"), high: 70, low: 60 }]
        })
      end
    end

    context 'when an error occurs during fetching weather data' do
      before do
        allow(weather_fetcher).to receive(:fetch_weather_data).and_raise(StandardError.new("An error occurred"))
      end

      it 'sets the error message and returns nil' do
        result = service.fetch_and_process_weather_data
        
        expect(result).to be_nil
        expect(service.error_message).to eq("An error occurred: An error occurred")
      end
    end

    context 'when fetching weather data fails (returns nil)' do
      before do
        allow(weather_fetcher).to receive(:fetch_weather_data).and_return(nil)
        allow(weather_fetcher).to receive(:error_message).and_return("Unable to retrieve weather data")
      end

      it 'sets the error message and returns nil' do
        result = service.fetch_and_process_weather_data

        expect(result).to be_nil
        expect(service.error_message).to eq("Unable to retrieve weather data")
      end
    end

    context 'when no coordinates are found' do
      before do
        allow(weather_fetcher).to receive(:fetch_weather_data).and_return(nil)
        allow(weather_fetcher).to receive(:error_message).and_return("No weather data available")
      end

      it 'returns nil and sets the error message' do
        result = service.fetch_and_process_weather_data

        expect(result).to be_nil
        expect(service.error_message).to eq("No weather data available")
      end
    end
  end
end

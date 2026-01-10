require 'rails_helper'

RSpec.describe WeatherFetcher do
  let(:weather_service) { instance_double("WeatherService") }
  let(:address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
  let(:fetcher) { WeatherFetcher.new(weather_service, address) }

  describe '#fetch_weather_data' do
    context 'when coordinates and zip code are valid' do
      before do
        allow(weather_service).to receive(:get_coordinates_from_address).with(address).and_return({ lat: 37.423021, lon: -122.083739 })
        allow(ZipCodeExtractor).to receive(:extract).with(address).and_return("94043")
      end

      context 'when weather data is cached' do
        it 'returns cached weather data' do
          cached_weather = { "current" => { "temp" => 65, "weather" => [{ "description" => "clear sky" }] } }
          allow(Rails.cache).to receive(:read).with("weather_94043").and_return(cached_weather)

          result = fetcher.fetch_weather_data

          expect(result).to eq(cached_weather)
       
        end
      end

      context 'when weather data is not cached' do
        it 'fetches new weather data and caches it' do
          new_weather_data = { "current" => { "temp" => 65, "weather" => [{ "description" => "clear sky" }] } }

          allow(Rails.cache).to receive(:read).with("weather_94043").and_return(nil)
          allow(weather_service).to receive(:get_weather_by_coordinates).with(37.423021, -122.083739).and_return(new_weather_data)

          expect(Rails.cache).to receive(:write).with("weather_94043", new_weather_data, expires_in: 30.minutes)

          result = fetcher.fetch_weather_data

          expect(result).to eq(new_weather_data)
        end
      end
    end

    context 'when coordinates are missing' do
      before do
        allow(weather_service).to receive(:get_coordinates_from_address).with(address).and_return(nil)
        allow(ZipCodeExtractor).to receive(:extract).with(address).and_return("94043")
      end

      it 'returns nil' do
        result = fetcher.fetch_weather_data
        expect(result).to be_nil
      end
    end

    context 'when zip code is missing' do
      before do
        allow(weather_service).to receive(:get_coordinates_from_address).with(address).and_return({ lat: 37.423021, lon: -122.083739 })
        allow(ZipCodeExtractor).to receive(:extract).with(address).and_return(nil)
      end

      it 'returns nil' do
        result = fetcher.fetch_weather_data
        expect(result).to be_nil
      end
    end

    context 'when there is an error retrieving weather data' do
      before do
        allow(weather_service).to receive(:get_coordinates_from_address).with(address).and_return({ lat: 37.423021, lon: -122.083739 })
        allow(ZipCodeExtractor).to receive(:extract).with(address).and_return("94043")
        allow(Rails.cache).to receive(:read).with("weather_94043").and_return(nil)
        allow(weather_service).to receive(:get_weather_by_coordinates).with(37.423021, -122.083739).and_return(nil)
      end

      it 'sets an error message and returns nil' do
        result = fetcher.fetch_weather_data
        expect(result).to be_nil
        expect(fetcher.error_message).to eq("Unable to retrieve weather data for the provided coordinates.")
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(weather_service).to receive(:get_coordinates_from_address).with(address).and_raise(StandardError, "Unexpected Error")
      end

      it 'sets an error message and returns nil' do
        result = fetcher.fetch_weather_data
        expect(result).to be_nil
        expect(fetcher.error_message).to eq("An error occurred: Unexpected Error")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe WeatherService do
  let(:service) { WeatherService.new }

  describe '#get_coordinates_from_address' do
    context 'when the API returns valid coordinates' do
      it 'returns coordinates from a full address' do
        address = "1600 Amphitheatre Parkway, Mountain View, CA"

        allow(service).to receive(:fetch_coordinates).with(address).and_return({ lat: 37.423021, lon: -122.083739 })

        coordinates = service.get_coordinates_from_address(address)
        expect(coordinates).to eq({ lat: 37.423021, lon: -122.083739 })
      end
    end

    context 'when the full address query fails' do
      it 'tries simplified queries with city/state' do
        address = "Mountain View, CA"

        allow(service).to receive(:fetch_coordinates).with(address).and_return(nil)
        allow(service).to receive(:fetch_simplified_coordinates).with(address).and_return({ lat: 37.423021, lon: -122.083739 })

        coordinates = service.get_coordinates_from_address(address)
        expect(coordinates).to eq({ lat: 37.423021, lon: -122.083739 })
      end
    end

    context 'when no coordinates are found' do
      it 'returns nil' do
        address = "Invalid Address"

        allow(service).to receive(:fetch_coordinates).with(address).and_return(nil)
        allow(service).to receive(:fetch_simplified_coordinates).with(address).and_return(nil)

        coordinates = service.get_coordinates_from_address(address)
        expect(coordinates).to be_nil
      end
    end
  end

  describe '#get_weather_by_coordinates' do
    context 'when the coordinates are valid' do
      it 'returns weather data' do
        lat = 37.423021
        lon = -122.083739

        weather_response = {
          "current" => { "temp" => 65, "weather" => [{ "description" => "clear sky" }] },
          "daily" => [{ "dt" => 1672003200, "temp" => { "max" => 70, "min" => 60 } }]
        }

        allow(HTTParty).to receive(:get).with("https://api.openweathermap.org/data/3.0/onecall",
          query: { lat: lat, lon: lon, appid: service.instance_variable_get(:@api_key), units: "imperial" })
          .and_return(weather_response)

        retrieved_weather_data = service.get_weather_by_coordinates(lat, lon)

        expect(retrieved_weather_data).to eq(weather_response)
      end
    end

    context 'when there is an error fetching weather data' do
      it 'returns nil' do
        lat = 37.423021
        lon = -122.083739

        error_response = double("HTTPartyResponse", success?: false)
        allow(error_response).to receive(:[]).with('message').and_return("city not found")

        allow(HTTParty).to receive(:get).with("https://api.openweathermap.org/data/3.0/onecall",
          query: { lat: lat, lon: lon, appid: service.instance_variable_get(:@api_key), units: "imperial" })
          .and_return(error_response)

        retrieved_weather_data = service.get_weather_by_coordinates(lat, lon)

        expect(retrieved_weather_data).to be_nil
      end
    end
  end
end

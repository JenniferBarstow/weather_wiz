require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #index' do
    let(:valid_address) { "1600 Amphitheatre Parkway, Mountain View, CA" }
    let(:weather_data_service) { instance_double("WeatherDataService") }

    before do
      allow(WeatherDataService).to receive(:new).with(valid_address).and_return(weather_data_service)
    end

    context 'when an address is provided' do
      context 'when fetching weather data is successful' do
        let(:cached_weather) do
          {
            temperature: 65,
            description: 'clear sky',
            humidity: 40,
            wind_speed: 10,
            daily_forecast: [{ date: Time.now.strftime("%A"), high: 70, low: 60 }]
          }
        end

        before do
          allow(weather_data_service).to receive(:fetch_and_process_weather_data).and_return(cached_weather)
          get :index, params: { address: valid_address }
        end

        it 'fetches weather data successfully' do
          expect(assigns(:temperature)).to eq(65)
          expect(assigns(:description)).to eq('clear sky')
          expect(assigns(:humidity)).to eq(40)
          expect(assigns(:wind_speed)).to eq(10)
          expect(assigns(:daily_forecast)).to eq([{ date: Time.now.strftime("%A"), high: 70, low: 60 }])
          expect(flash.now[:info]).to eq("Weather information retrieved successfully.")
        end

        it 'renders the index template' do
          expect(response).to render_template(:index)
        end
      end

      context 'when weather data fetching fails' do
        before do
          allow(weather_data_service).to receive(:fetch_and_process_weather_data).and_return(nil)
          allow(weather_data_service).to receive(:error_message).and_return("Unable to retrieve weather data")
          get :index, params: { address: valid_address }
        end

        it 'sets the error message' do
          expect(flash.now[:error]).to eq("Unable to retrieve weather data")
        end
        
        it 'renders the index template' do
          expect(response).to render_template(:index)
        end
      end
    end

    context 'when no address is provided' do
      before do
        get :index, params: { address: nil }
      end

      it 'sets an error message' do
        expect(flash.now[:error]).to eq("Please provide an address.")
      end
      
      it 'renders the index template' do
        expect(response).to render_template(:index)
      end
    end
  end
end

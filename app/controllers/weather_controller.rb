class WeatherController < ApplicationController
  def index
    if params[:address].present?
      @weather_data_service = WeatherDataService.new(params[:address])
      @cached_weather = @weather_data_service.fetch_and_process_weather_data

      if @cached_weather
        @temperature = @cached_weather[:temperature]
        @description = @cached_weather[:description]
        @humidity = @cached_weather[:humidity]
        @wind_speed = @cached_weather[:wind_speed]
        @daily_forecast = @cached_weather[:daily_forecast]

        flash.now[:info] = "Weather information retrieved successfully."
      else
        flash.now[:error] = @weather_data_service.error_message
      end
    else
      flash.now[:error] = "Please provide an address."
    end

    render :index
  end
end

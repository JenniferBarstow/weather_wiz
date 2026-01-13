# Weather Wiz

Weather Wiz is a simple ruby weather application that retrieves weather data from the OpenWeather API.

## Features

- Accepts an address as input.
- Retrieves weather data for the provided address using the [OpenWeather API](https://openweathermap.org/api).
- Displays current temperature, high and low temperatures, and an extended forecast.
- Caches forecast details for 30 minutes based on zip codes to improve response times.
- (Planned, but ran out of time):  Display an indicator if the weather data was pulled from the cache. 

### Prerequisites

- **Docker**: Make sure Docker is installed and running on your machine.
- **Environment Variables**: Set up the following environment variables in your environment:
  - `REDIS_URL`: URL for the Redis service if you plan on using Redis, otherwise adjust your config and implementation to use memory store.
  - `WEATHER_API_KEY`: Your API key for the OpenWeather API.

### Docker Setup

This application can be run in a Docker container. I chose to do this to provide a dev environment that matches production settings. This simplifies deployment and eliminates compatibility issues.

#### Docker Configuration
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - REDIS_URL=${REDIS_URL}
      - WEATHER_API_KEY=${WEATHER_API_KEY}
    depends_on:
      - redis
    volumes:
      - .:/app

  redis:
    image: redis:latest
    ports:
      - "6379:6379"
```

### Docker
Build and run the containers:
- Make sure Docker is installed and running on your machine.
- build with: `docker-compose build`
- start server/container with: `docker-compose up`
#### Access
- Once the containers are running, visit http://localhost:3000
#### Use
- Enter and sumbit a valid address
#### Response
The response returns and displays the current temperature, the current days high and low temps, and an extended forecast.
#### Caching
Caches forecast details for 30 minutes based on the zip code for provided address by using Rails' built-in caching features, utilizing Redis as the caching store for improved performance and response times.
### Architecture
- I followed Service Class Architecture for this projects, where the business logic lives within their own respective service classes. This helps keep the controller thin and focused on handling requests and responses.
- All classes and controllers are fully tested using RSpec.
### Future Improvements
There are a few enhancements that could be made if given more time:
- Implement Cache Indicator: Currently, the app does not display whether the retrieved weather data was pulled from the cache or fetched fresh from the API. Implementing this functionality would involve modifying the `WeatherFetcher` class to track cache usage and updating the controller and views to display this information clearly. I got a little ahead of myself and did all the stretch goals before implementing the use of the cache in the display. I wanted to stick to the provided time limit as closely as possible.
- Error Handling: Enhance error handling throughout, especially when retrieving data from the external weather service. Providing clear messages to users when data cannot be retrieved would improve the user experience.
- Improved UI
### Final Thoughts
- Functional requirements were prioritized over aesthetics.
- My goal was to focus on working functionalities rather than complete perfection.
- Normally I am a fan of comments in code, but my previous companies were not a huge fan of this approach. I had originally had lot of inline comments and logging, but removed them before my commit. If I could go back, I would put my comments back.

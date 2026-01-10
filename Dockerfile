FROM ruby:3.4.7

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfiles and install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy all application code
COPY . .

# Expose the application port
EXPOSE 3000

# Set environment variable for Redis URL and API Key
ENV REDIS_URL=redis://redis:6379/0
ENV WEATHER_API_KEY=${WEATHER_API_KEY}

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]

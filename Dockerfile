# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:latest AS build

# Set working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock ./
COPY lib ./lib
COPY web ./web
COPY analysis_options.yaml ./

RUN flutter pub cache repair
# Get dependencies
RUN flutter pub get

# Build web app
RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

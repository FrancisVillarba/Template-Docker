# NodeJS Dockerfile -- For Local Use Only!
# Prepare the Runner ===================================================================================================
FROM node:lts-bullseye AS runner

# Update Base System Dependencies
RUN apt update -y \
    && apt upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Remove un-needed dependencies then clean up
RUN apt-get autoremove --assume-yes \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Base NodeJS dependency update
RUN npm i -g npm@latest

# Run command
CMD ["sh", "-c", "npm i && npm run dev"]
# We run npm i and then npm run dev customise this as needed, or override it via the Docker Compose file

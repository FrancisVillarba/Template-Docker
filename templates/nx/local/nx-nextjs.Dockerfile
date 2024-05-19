# NX NextJS Dockerfile -- For Localhost Use Only!
# Prepare the Runner ==========================================================
FROM node:lts-bullseye AS Runner

##  Update Base System Dependencies
RUN apt update -y \
    && apt upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Remove un-needed dependencies then clean up
RUN apt-get autoremove --assume-yes \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

## Finalise the runner
WORKDIR /app

# Base NodeJS dependency update
RUN npm i -g npm@latest

# NX Dependencies
RUN npm i -g nx

# Run command
CMD ["sh", "-c", "npm i && nx run-many --target=serve --all"]
# We run npm i and then serve all the FEs by default, customise this as needed, or override it via the Docker Compose file

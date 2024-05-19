# NodeJS Dockerfile -- For Dev Use Only!

###############################################################################
## Runner Dependencies ========================================================
###############################################################################

FROM node:lts-bullseye AS dependencies

# Set the working directory
WORKDIR /app

# Base Global Dependencies
RUN npm i -g npm@latest

# Build Arguments
ARG HOSTPATH = ./

# Install Dependencies
COPY $HOST_PATH/package.json ./package.json
RUN npm install --no-audit

###############################################################################
## Builder ====================================================================
###############################################################################

FROM node:lts-bullseye as builder

# Set the working directory
WORKDIR /app

# Base Global Dependencies
RUN npm i -g npm@latest

# Build Arguments
ARG HOSTPATH = ./

# Copy Dependencies & Ensure they are setup
COPY --from=dependencies /app/node_modules /app/node_modules
RUN npm install --prefer-offline --no-audit

# Copy project files
COPY $HOST_PATH ./

# Build everything
RUN npm run build

###############################################################################
## Runner =====================================================================
###############################################################################

FROM node:lts-bullseye as runner

# Set the working directory
WORKDIR /app

# Update Base System Dependencies
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get autoremove --assume-yes \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

# Development Dependencies
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y vim curl \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*

# Base Global Dependencies
RUN npm i -g npm@latest

# Build Arguments
ARG HOSTPATH = ./

# Copy the project & dependencies
COPY --from=builder --chown=www-data /app/dist ./

# Install Dependencies
RUN npm install --no-dev --no-audit

# Final Setup
EXPOSE 3000
USER www-data

ENV HOSTNAME 0.0.0.0
ENV NODE_ENV develop

# Run Command
CMD npm run start --loglevel=verbose --hostname=0.0.0.0

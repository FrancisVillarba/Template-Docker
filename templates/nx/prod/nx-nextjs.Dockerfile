# NX NextJS Dockerfile -- For Dev Use Only!

###############################################################################
## Runner Dependencies ========================================================
###############################################################################

FROM node:lts-bullseye AS dependencies

# Set the working directory
WORKDIR /app

# Base Global Dependencies
RUN npm i -g npm@latest
RUN npm i -g nx@latest

# Build Arguments
ARG HOSTPATH = ./
ARG PROJECTNAME

# Ensure Project Name is set, will fail early if not
# The below will exit the build with code zero if so
RUN [ -n $PROJECTNAME ]

# Install Dependencies
COPY $HOST_PATH/package.json ./package.json
RUN npm install --no-audit

# Installs Extra Dependency (Only If Running on ARM64)
RUN if [ $(dpkg --print-architecture) = "arm64" ]; then \
        echo $(dpkg --print-architecture); \
        echo "Installing ARM dependencies"; \
        npm i @next/swc-linux-arm64-gnu; \
        npm i @next/swc-linux-arm64-musl; \
    else \
        echo "Skipping ARM dependencies"; \
        echo $(dpkg --print-architecture); \
    fi;

###############################################################################
## Builder ====================================================================
###############################################################################

FROM node:lts-bullseye as builder

# Set the working directory
WORKDIR /app

# Base Global Dependencies
RUN npm i -g npm@latest
RUN npm i -g nx@latest

# Build Arguments
ARG HOSTPATH = ./
ARG PROJECTNAME

# Ensure Project Name is set, will fail early if not
# The below will exit the build with code zero if so
RUN [ -n $PROJECTNAME ]

# Copy Dependencies & Ensure they are setup
COPY --from=dependencies /app/node_modules /app/node_modules
RUN npm install --prefer-offline --no-audit

# Copy project files
COPY $HOST_PATH ./

# Build everything
RUN nx build $PROJECTNAME

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
RUN npm i -g nx@latest

# Build Arguments
ARG HOSTPATH = ./
ARG PROJECTNAME

# Ensure Project Name is set, will fail early if not
# The below will exit the build with code zero if so
RUN [ -n $PROJECTNAME ]

# Copy the project & dependencies
COPY --from=builder --chown=www-data /app/dist/apps/$PROJECT_NAME ./

# Install Dependencies
RUN npm install --no-dev --no-audit

# Installs Extra Dependency (Only If Running on ARM64)
RUN if [ $(dpkg --print-architecture) = "arm64" ]; then \
        echo $(dpkg --print-architecture); \
        echo "Installing ARM dependencies"; \
        npm i @next/swc-linux-arm64-gnu; \
        npm i @next/swc-linux-arm64-musl; \
    else \
        echo "Skipping ARM dependencies"; \
        echo $(dpkg --print-architecture); \
    fi;

# Final Setup
EXPOSE 3000
USER www-data

ENV HOSTNAME 0.0.0.0
ENV NODE_ENV production

# Run Command
# CMD npm run start --loglevel=verbose --hostname=0.0.0.0
CMD npx next start -p 3000 -H 0.0.0.0 --loglevel=verbose

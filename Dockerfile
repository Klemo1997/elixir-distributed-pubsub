# Extend from the official Elixir image
FROM elixir:1.17.2-alpine

# Install required libraries on Alpine
# note: build-base required to run mix “make” for
# one of my dependecies (bcrypt)

RUN apk update && apk upgrade && \
  apk add git && \
  apk add postgresql-client && \
  apk add nodejs npm && \
  apk add build-base && \
  rm -rf /var/cache/apk/*

WORKDIR /app

# Set environment to production
ENV MIX_ENV dev

# Install hex package manager and rebar
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix do local.hex --force, local.rebar --force

# Cache elixir dependecies and lock file
COPY mix.* ./

# Install and compile production dependecies
RUN mix do deps.get
RUN mix deps.compile

# Cache and install node packages and dependencies
#RUN cd assets && \
#    npm install

CMD ["tail", "-f", "/dev/null"]
#CMD ["iex", "-S", "mix phx.server"]

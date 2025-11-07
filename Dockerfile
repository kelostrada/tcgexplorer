FROM elixir:1.17.3-otp-27-slim AS build

# install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      npm \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-venv \
      openssl \
      ca-certificates && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# prepare build dir
WORKDIR /app

# set build ENV
ENV MIX_ENV=prod

# install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get && \
    mix deps.compile --force

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM debian:bookworm-slim AS app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssl \
      ca-certificates \
      libncurses6 \
      libstdc++6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the entire release directory structure
COPY --from=build --chown=nobody:nogroup /app/_build/prod/rel/tcg_explorer ./

RUN chown -R nobody:nogroup /app

USER nobody:nogroup

ENV HOME=/app
ENV PATH=/app/bin:$PATH

CMD ["bin/tcg_explorer", "start"]

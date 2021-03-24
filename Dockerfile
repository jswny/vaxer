FROM elixir:1.11.2-alpine

ENV MIX_ENV="dev"

WORKDIR /app

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
RUN mix release

ENTRYPOINT [ "/app/_build/dev/rel/vaxer/bin/vaxer" ]
CMD [ "start" ]

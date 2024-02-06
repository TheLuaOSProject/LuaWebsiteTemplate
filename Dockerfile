FROM debian:latest

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y lua5.4 lua5.4-dev git build-essential wget zlib1g-dev npm emscripten unzip

RUN mkdir -p /tmp/luarocks

WORKDIR /tmp/luarocks

RUN wget http://luarocks.github.io/luarocks/releases/luarocks-3.9.2.tar.gz -O luarocks.tar.gz
RUN tar zxpf luarocks.tar.gz
WORKDIR /tmp/luarocks/luarocks-3.9.2
RUN ./configure
RUN make -j
RUN make install

WORKDIR /app
COPY . /app

RUN luarocks --lua-version=5.4 init
RUN ./luarocks make

CMD [ "./lua", "scripts/serve.lua" ]

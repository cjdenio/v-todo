### INSTALL REFLEX ###
FROM golang:1.16-alpine

ENV GOPATH /go

RUN go get github.com/cespare/reflex


FROM alpine:latest

COPY --from=0 /go/bin/reflex /bin/reflex

### INSTALL V COMPILER ###
WORKDIR /v

ENV VFLAGS -cc gcc

RUN apk --no-cache add \
    git make gcc bash \
    musl-dev \
    openssl-dev sqlite-dev \
    libx11-dev glfw-dev freetype-dev

RUN git clone https://github.com/vlang/v . && make


### RUN APP ###
RUN apk add postgresql postgresql-dev

WORKDIR /usr/src/app

COPY . .

CMD [ "reflex", "-r", ".v$", "-s", "--", "/v/v", "run", "main.v" ]

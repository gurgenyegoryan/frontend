FROM golang:1.15-alpine AS compiler

RUN apk add --no-cache ca-certificates git
RUN apk add build-base

WORKDIR /src

# restore dependencies and compile
COPY . .
RUN go mod download
RUN go build -o /go/bin/frontend .

FROM alpine AS release

RUN apk add --no-cache ca-certificates \
    busybox-extras net-tools bind-tools

WORKDIR /src
# copy compiled binary and source files
COPY --from=compiler /go/bin/frontend /src/server
COPY ./templates ./templates
COPY ./static ./static

EXPOSE 8080
ENTRYPOINT ["/src/server"]

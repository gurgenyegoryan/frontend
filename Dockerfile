FROM golang:1.15-alpine as compiler
RUN apk add --no-cache ca-certificates git
RUN apk add build-base
WORKDIR /src

# restore dependencies
# COPY go.mod go.sum ./
COPY . .
RUN ls -Alph
RUN go mod download


# Skaffold passes in debug-oriented compiler flags
# ARG SKAFFOLD_GO_GCFLAGS -gcflags="${SKAFFOLD_GO_GCFLAGS}"
RUN go build -o /go/bin/frontend .

FROM alpine as release
RUN apk add --no-cache ca-certificates \
    busybox-extras net-tools bind-tools
WORKDIR /src
COPY --from=compiler /go/bin/frontend /src/server
COPY ./templates ./templates
COPY ./static ./static

# Definition of this variable is used by 'skaffold debug' to identify a golang binary.
# Default behavior - a failure prints a stack trace for the current goroutine.
# See https://golang.org/pkg/runtime/
# ENV GOTRACEBACK=single

EXPOSE 8080
ENTRYPOINT ["/src/server"]

# Build the manager binary
ARG GOLANG_VERSION=1.20
FROM golang:${GOLANG_VERSION} as builder

# Copy in the go src
WORKDIR /go/src/github.com/kubeflow/kubeflow/components/admission-webhook
COPY pkg/  pkg/
COPY . .

ENV GO111MODULE=on

# Build
RUN if [ "$(uname -m)" = "aarch64" ]; then \
    CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o webhook -a . ; \
    else \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o webhook -a . ; \
    fi

# Copy the controller-manager into a distroless image
FROM gcr.io/distroless/static-debian12:d88145e15699304b1b1dcbfbd5d516e5ff71dbcb
WORKDIR /
COPY --from=builder /go/src/github.com/kubeflow/kubeflow/components/admission-webhook/webhook .
ENTRYPOINT ["/webhook"]

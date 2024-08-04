GIT_VERSION ?= $(shell git describe --tags --always --dirty="-dev")
DATE ?= $(shell date -u '+%Y-%m-%d %H:%M UTC')
VERSION_FLAGS := -s -w -X "main.version=$(GIT_VERSION)" -X "main.date=$(DATE)"
CGO_ENABLED ?= 0
.PHONY: build
build:
	go build -trimpath --ldflags '$(VERSION_FLAGS) -extldflags "-static"' -o cloudflare_exporter .
lint:
	golangci-lint run
clean:
	rm cloudflare_exporter venom*.log basic_tests.* pprof_cpu*
test:
	./run_e2e.sh

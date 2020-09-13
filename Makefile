.PHONY: build run test clean help all

NAME = socat
IMAGE = simonrupf/$(NAME)
PORT = 255

build: ## Build the container image (default).
	DOCKER_BUILDKIT=1 docker build -t $(IMAGE) .

run: ## Run a container from the image.
	docker run -d --init --name $(NAME) -p=$(PORT):$(PORT) --read-only --restart=always $(IMAGE) TCP6-LISTEN:$(PORT),reuseaddr,fork TCP4:127.0.0.1:$(PORT)

test: ## Launch tests to verify that the service works as expected, requires a running container.
	@sleep 1
	nc -z localhost $(PORT)

clean: ## Stops and removes the running container.
	docker stop $(NAME)
	docker rm $(NAME)

help: ## Displays these usage instructions.
	@echo "Usage: make <target(s)>"
	@echo
	@echo "Specify one or multiple of the following targets and they will be processed in the given order:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "%-16s%s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: build run test clean ## Equivalent to "make build run test clean"

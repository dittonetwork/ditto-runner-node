.PHONY: setup up down logs

setup:
	git submodule update --init --recursive

up: setup
	docker-compose up -d --build

down:
	docker-compose down

logs:
	docker-compose logs -f 
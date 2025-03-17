include .env

stop_containers:
	@echo "Stopping other docker container"
	if [ $$(docker ps -q) ]; then \
		echo "found and stopped containers"; \
		docker stop $$(docker ps -q); \
	else \
		echo "no containers running..."; \
	fi

create_container:
	docker run --name ${DB_DOCKER_CONTAINER} -p 5432:5432 -e POSTGRES_USER=${USER} -e POSTGRES_PASSWORD=${PASSWORD} -d postgres:12-alpine

create_db:
	docker exec -it ${DB_DOCKER_CONTAINER} createdb --username=${USER} --owner=${USER} ${DB_NAME}

start_container:
	docker start ${DB_DOCKER_CONTAINER}

create_migrations:
	migrate create -ext sql -dir migrations -seq init

migrate_up:
	migrate -database "postgres://${USER}:${PASSWORD}@${HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -path migrations up

migrate_down:
	migrate -database "postgres://${USER}:${PASSWORD}@${HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -path migrations down

build:
	@if exist "${BINARY}" del /F "${BINARY}"
	@echo "Building binary..."
	go build -o ${BINARY} cmd/server/main.go

run: build
	./${BINARY}
# @echo "api started..."

stop:
	@echo "stopping server.."
	@-pkill -SIGTERM -f "./${BINARY}"
	@echo "server stopped..."
build:
	docker build -t swift --rm .

run: build
	docker run -d -P --env-file env -p 8080:8080 swift

attach:
	docker exec -it -t `docker ps -q` bash

logs:
	docker logs `docker ps -qa`

clean:
	docker stop `docker ps -aq`; docker rm `docker ps --no-trunc -aq`

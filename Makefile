IMAGE_NAME=local/pagi-server
CONTAINER_NAME=pagi-server
HOST_PORT=5089

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run --detach --publish $(HOST_PORT):8080 --name=$(CONTAINER_NAME) $(IMAGE_NAME)

bash:
	docker exec -it $(CONTAINER_NAME) /bin/bash || true

start:
	docker start $(CONTAINER_NAME)

stop:
	docker stop $(CONTAINER_NAME)

rm:	stop
	docker rm $(CONTAINER_NAME)

firewall:
	sudo firewall-cmd --zone=public --permanent --add-port=$(HOST_PORT)/tcp
	sudo firewall-cmd --reload


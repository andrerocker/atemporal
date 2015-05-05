package-bootstrap:
	docker build -t atemporal/coreimg devops/bricky/containers/images/coreimg
	docker build -t atemporal/builder devops/bricky/containers/images/builder

package-builder:
	docker-compose -p atemporal -f devops/bricky/atemporal-builder.yml run builder /scripts/builder
	docker build -t atemporal/runtime devops/bricky/containers/images/runtime

package-runtime:
	docker-compose -p atemporal -f devops/bricky/atemporal-runtime.yml run \
	       	-e AWS_ACCESS_KEY=$(shell head -1 .credentials) \
		-e AWS_SECRET_ACCESS_KEY=$(shell tail -1 .credentials) \
		-e AWS_REGION=us-west-1 -e AWS_IMAGE_ID=ami-4df91b09 -e AWS_INSTANCE_TYPE=t1.micro \
		-e AWS_KEY_NAME=atemporal -e AWS_SECURITY_GROUP=atemporal-worker \
	       	--service-ports runtime /start

package-registry:
	docker tag -f atemporal/runtime $(shell cat .docker-username)/atemporal
	docker push $(shell cat .docker-username)/atemporal

servers-bootstrap:
	cd devops/terraform; terraform apply \
	       	-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
	       	-var "access_key=$(shell head -1 .credentials)" \
	       	-var "secret_key=$(shell tail -1 .credentials)" \
	       	-var "docker_username=$(shell cat .docker-username)" \
	       	-var "cluster_discovery=$(shell curl -s http://discovery.etcd.io/new)"

servers-terminate:
	cd devops/terraform; terraform destroy -force \
	       	-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
	       	-var "access_key=$(shell head -1 .credentials)" \
	       	-var "secret_key=$(shell tail -1 .credentials)" \
	       	-var "docker_username=1337" \
	       	-var "cluster_discovery=1337"

application-deploy: package-builder package-registry
	devops/deploy

application-fullstack-deploy: package-bootstrap package-builder package-registry servers-bootstrap
	echo "\o/"

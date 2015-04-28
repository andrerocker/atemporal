package-bootstrap:
	docker build -t atemporal/coreimg bricky/containers/images/coreimg
	docker build -t atemporal/builder bricky/containers/images/builder

package-builder:
	docker-compose -p atemporal -f bricky/atemporal-builder.yml up 
	docker build -t atemporal/runtime bricky/containers/images/runtime

package-runtime:
	docker-compose -p atemporal -f bricky/atemporal-runtime.yml up #run runtime /scripts/runtime

package-registry:
	docker tag -f atemporal/runtime $(shell cat .docker-username)/atemporal
	docker push $(shell cat .docker-username)/atemporal

servers-bootstrap:
	cd terraform; terraform apply \
	       	-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
	       	-var "access_key=$(shell head -1 .credentials)" \
	       	-var "secret_key=$(shell tail -1 .credentials)"

servers-terminate:
	cd terraform; terraform destroy -force \
	       	-var "public_key=$(shell cat ~/.ssh/id_rsa.pub)" \
	       	-var "access_key=$(shell head -1 .credentials)" \
	       	-var "secret_key=$(shell tail -1 .credentials)"

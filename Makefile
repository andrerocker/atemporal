package-bootstrap:
	docker build -t atemporal/builder bricky/containers/images/builder
	docker build -t atemporal/runtime bricky/containers/images/runtime

package-builder:
	docker-compose -p atemporal -f bricky/atemporal-builder.yml \
	       	run builder /scripts/builder

package-runtime:
	docker-compose -p atemporal -f bricky/atemporal-runtime.yml \
		run runtime /scripts/runtime

package-upload:
	curl -F package=@bricky/containers/tmp/build/atemporal_0.0.2_amd64.deb \
		https://4DSoHeowovJgJ2LvG-p4@push.fury.io/deploy42/

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

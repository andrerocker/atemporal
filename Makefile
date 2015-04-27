bootstrap:
	docker build -t atemporal/builder bricky/containers/images/builder
	docker build -t atemporal/runtime bricky/containers/images/runtime

builder:
	docker-compose -p atemporal -f bricky/atemporal-builder.yml run builder /scripts/builder

runtime:
	docker-compose -p atemporal -f bricky/atemporal-runtime.yml run runtime /scripts/runtime

bootstrap-infra:
	cd terraform; terraform apply -var "public_key=$(shell cat ~/.ssh/id_rsa.pub)"

destroy-infra:
	cd terraform; terraform destroy -force -var "public_key=$(shell cat ~/.ssh/id_rsa.pub)"

upload-package:
	curl -F package=@bricky/containers/tmp/build/atemporal_0.0.2_amd64.deb \
		https://4DSoHeowovJgJ2LvG-p4@push.fury.io/deploy42/

bootstrap:
	docker build -t atemporal/builder bricky/containers/images/builder
	docker build -t atemporal/runtime bricky/containers/images/runtime

builder:
	docker-compose -p atemporal -f bricky/atemporal-builder.yml run builder /scripts/builder

runtime:
	docker-compose -p atemporal -f bricky/atemporal-runtime.yml run runtime /scripts/runtime

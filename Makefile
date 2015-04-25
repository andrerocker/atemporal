bootstrap:
	docker build -t atemporal/builder bricky/containers/images/builder
	docker build -t atemporal/runtime bricky/containers/images/runtime

builder:
	docker run \
                -v $(CURDIR):/source \
                -v $(CURDIR)/bricky/containers/scripts:/scripts \
                -v $(CURDIR)/bricky/containers/tmp/build:/build \
                -v $(CURDIR)/bricky/containers/tmp/cache:/opt/source/vendor/bundle \
                -i -t atemporal/builder /scripts/builder

runtime:
	docker run \
                -v $(CURDIR)/bricky/containers/scripts:/scripts \
                -v $(CURDIR)/bricky/containers/tmp/build:/build \
                -i -t atemporal/runtime /scripts/runtime

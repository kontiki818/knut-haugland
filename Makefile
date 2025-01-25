ci: clean lint test

clean:
	cd examples/static-redirect/ && \
	  make -f ../../src/Makefile-knut-haugland clean

lint:
	checkmake src/Makefile-knut-haugland

test:
	cd examples/static-redirect/ && \
	  make -f ../../src/Makefile-knut-haugland ci update-to-latest update-to-main && \
		make -f ../../src/Makefile-knut-haugland update-to-version TARGET_KNUT_HAUGLAND_VERSION=0.10.0
	cd examples/static-content/ && \
	  make -f ../../src/Makefile-knut-haugland ci update-to-latest update-to-main && \
		make -f ../../src/Makefile-knut-haugland update-to-version TARGET_KNUT_HAUGLAND_VERSION=0.10.0

release-major:
	rtk release --release-increment-type major

release-minor:
	rtk release --release-increment-type minor

release-patch:
	rtk release --release-increment-type patch

release: release-minor

.PHONY: ci clean lint test release-major release-minor release-patch release

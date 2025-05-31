MOON_ARGS := --target native

build:
	moon $@ $(MOON_ARGS)

test:
	moon $@ $(MOON_ARGS)

debug:
	moon build -g $(MOON_ARGS)

clean:
	moon $@ && rm -rf md-docs

run:
	moon $@ $(MOON_ARGS) src/main init

.PHONY: build test clean debug run
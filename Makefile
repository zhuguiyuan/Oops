MOON_ARGS := --target native

build:
	moon $@ $(MOON_ARGS)

test:
	moon $@ $(MOON_ARGS)

clean:
	moon $@

.PHONY: build test clean
MOON_ARGS := --target native

run:
	moon $@ $(MOON_ARGS) src/main init

build:
	moon $@ $(MOON_ARGS)

test:
	moon $@ $(MOON_ARGS)

debug:
	moon build -g $(MOON_ARGS)

clean:
	moon $@

.PHONY: run build test clean debug
# This makefile creates json files from yml input
# We are attempting to standardize on yml configuration
# for all input, at least where possible.
# To do this, we need to convert many of these files into
# the standard format required for cromwell which is 
# json. This directory is a "cache" directory, namely
# a series of constructed json file source yml in the
# parent directory. You should not normally need
# to modify this directory but it must exist to
# perform the conversions, etc.

# Glob yml files from the previous directory and determine
# the corresponding json filename.
SRC=$(patsubst %.yml,cache/%.json,$(wildcard *.yml))
CACHEDIR=cache

# Default target, remake all json files if needed
all: $(CACHEDIR) $(SRC)

$(CACHEDIR):
	-mkdir -p $(CACHEDIR)

# default rule to make json from parent yml
cache/%.json: %.yml
	../bin/yq $< > $@

clean:
	rm cache/*.json

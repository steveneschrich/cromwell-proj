SRC=$(patsubst %.yml,%.json,$(wildcard *.yml))

all: $(SRC)

%.json: %.yml
	../bin/cromwell-yq $< > $@

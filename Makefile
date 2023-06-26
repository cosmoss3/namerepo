.PHONY: # ignore

help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build-local-accumulator: # build a Hadoop Single Node Cluster as a Docker image
	cd accumulator/infra/hadoop-single-node-cluster; \
	rm -rf .git; \
	docker build -t hadoop .

up-local-accumulator: # stand up a Hadoop Single Node Cluster conatainer
	docker run --rm -it --name mina-accumulator -p 9864:9864 -p 9870:9870 -p 8088:8088 -p 9000:9000 --hostname localhost hadoop

build-map-reduce-steps: # builds mapper and reducer nodejs sripts to be uploaded to Hadoop
	cd accumulator/steps/steps; \
	yarn build; \
	cd ..; \
	rm mapper.js reducer.js; \
	echo '#!/usr/bin/env node\n' > mapper.js; \
	echo '#!/usr/bin/env node\n' > reducer.js; \
	cat steps/build/src/mapper/index.js >> mapper.js; \
	cat steps/build/src/reducer/index.js >> reducer.js;

generate-demo-files:
	rm data/demo-0/tmp.txt 2> /dev/null
	for number in {0..99} ; do \
    	echo "2" >> data/demo-0/tmp.txt; \
	done

run-demo:
	make build-map-reduce-steps
	cd sequencer; \
	yarn build && yarn start
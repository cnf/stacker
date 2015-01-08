.PHONY: clean restore depend binary 
.DEFAULT: test

# GOPATH=$(shell godep path):$(shell echo $$GOPATH)
GODEP=GOPATH=$(shell godep path):${GOPATH}

binary:
	godep go build -o bin/stacker

test: binary run

setup:
	@echo "\033[32mChecking Dependencies\033[m"

	@type go >/dev/null 2>&1|| { \
		echo "\033[1;33mGo is required to build this application\033[m"; \
		echo "\033[1;33mIf you are using homebrew on OSX, run\033[m"; \
		echo "$$ brew install go --cross-compile-all"; \
		exit 1; \
	}

ifndef GOPATH
	@echo "\033[1;33mGOPATH is not set.\033[m"
	exit 1;
endif

	@type godep >/dev/null 2>&1|| { \
		echo "go get github.com/tools/godep"; \
		go get github.com/tools/godep; \
	}

	@type gox >/dev/null 2>&1 || { \
		echo "godep go install github.com/mitchellh/gox"; \
		$(GODEP) godep get github.com/mitchellh/gox; \
		$(GODEP) godep go install github.com/mitchellh/gox; \
	}

	godep restore

linux64:
	$(GODEP) gox -osarch="linux/amd64" -output="image_builder/stacker"

dockerbuild:
	cd image_builder; \
		docker build -t frosquin/stacker:dev .

run:
	./bin/stacker -config_file=test.toml -logtostderr ${DEBUG}

debug: DEBUG = -v=2
debug: binary run

image: linux64 dockerbuild

push: image
	docker push frosquin/stacker:dev

clean:
	rm bin/stacker
	rm image_builder/stacker


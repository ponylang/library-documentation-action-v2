config ?= public

ifdef config
	ifeq (,$(filter $(config),public private))
		$(error Unknown configuration "$(config)")
	endif
endif

ifeq ($(config),private)
	IMAGE := ghcr.io/ponylang/library-documentation-action-v2-insiders
	PACKAGE = "git+https://${MATERIAL_INSIDERS_ACCESS}@github.com/squidfunk/mkdocs-material-insiders.git"
else
	IMAGE = ponylang/library-documentation-action-v2
	PACKAGE = "mkdocs-material"
endif

all: pylint

build:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="${version}-alpine" -t "${IMAGE}:${version}" .

build-latest:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="alpine" -t "${IMAGE}:latest" .

build-release:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="release-alpine" -t "${IMAGE}:release" .

push:
	docker push "${IMAGE}:${version}"

push-latest:
	docker push "${IMAGE}:latest"

push-release:
	docker push "${IMAGE}:release"

pylint: build-latest
	docker run --entrypoint pylint --rm "${IMAGE}:latest" /entrypoint.py

.PHONY: build pylint

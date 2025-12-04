IMAGE = ghcr.io/ponylang/library-documentation-action-v2
PACKAGE = "mkdocs-material"

all: pylint

build:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="${version}" -t "${IMAGE}:${version}" .

build-nightly:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="nightly" -t "${IMAGE}:nightly" .

build-release:
	docker build --pull --build-arg PACKAGE="${PACKAGE}" --build-arg FROM_TAG="release" -t "${IMAGE}:release" .

push:
	docker push "${IMAGE}:${version}"

push-nightly:
	docker push "${IMAGE}:nightly"

push-release:
	docker push "${IMAGE}:release"

pylint: build-nightly
	docker run --entrypoint pylint --rm "${IMAGE}:nightly" /entrypoint.py

.PHONY: build pylint

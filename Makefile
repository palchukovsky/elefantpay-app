.PHONY: \
	build-relase build-dev
.DEFAULT_GOAL := build-dev

build-dev:
	flutter build apk --debug -t lib/main_dev.dart

build-relase:
	flutter build appbundle -t lib/main_prod.dart

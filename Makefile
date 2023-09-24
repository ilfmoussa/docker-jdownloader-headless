run:
	docker buildx build --platform linux/arm64 . -t ghcr.io/ilfmoussa/jdownloader-headless:devel --push

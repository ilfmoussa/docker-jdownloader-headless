run:
	docker buildx build --platform linux/arm64 -t fifounet75/ubuntu:arm . -t ghcr.io/ilfmoussa/jdownloader-headless:devel --push

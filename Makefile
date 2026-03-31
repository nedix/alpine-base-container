setup:
	@docker build --progress=plain -f Containerfile -t alpine-base .

run:
	@docker run \
		-i \
		-t \
		--name="alpine-base" \
		--rm \
		alpine-base

test:
	@$(CURDIR)/tests/index.sh

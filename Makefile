.DEFAULT_GOAL:=ansible-lint
MAKEFLAGS=--warn-undefined-variables

playbooks:=$(wildcard playbooks/*.yml)
kaniko_img:=gcr.io/kaniko-project/executor:v1.21.1-debug

ifneq ("$(shell command -v podman)", "")
CONTAINER?=podman
else ifneq ("$(shell command -v docker)", "")
CONTAINER?=docker
else
$(warning no container platform found. Cannot run test targets.)
endif

define build_image
	@# $1 is the OS
	@# $2 is the OS_VERSION
	$(CONTAINER) run \
		--entrypoint='' \
		--name="perobertson-setup-build-$(1)-$(2)" \
		--rm \
		-v "$(shell pwd):/worksapce:z" \
		-w /worksapce \
		$(kaniko_img) \
		./.gitlab/build_image.sh $(1) $(2)
	$(CONTAINER) load -i dockerfiles/dist/$(1)/$(1)-$(2).tar
endef

dockerfiles/dist/centos/centos-stream9.tar: ./.gitlab/build_image.sh
dockerfiles/dist/centos/centos-stream9.tar: dockerfiles/centos.dockerfile
	$(call build_image,centos,stream9)

dockerfiles/dist/fedora/fedora-41.tar: ./.gitlab/build_image.sh
dockerfiles/dist/fedora/fedora-41.tar: dockerfiles/fedora.dockerfile
	$(call build_image,fedora,41)

dockerfiles/dist/fedora/fedora-42.tar: ./.gitlab/build_image.sh
dockerfiles/dist/fedora/fedora-42.tar: dockerfiles/fedora.dockerfile
	$(call build_image,fedora,42)

dockerfiles/dist/fedora/fedora-43.tar: ./.gitlab/build_image.sh
dockerfiles/dist/fedora/fedora-43.tar: dockerfiles/fedora.dockerfile
	$(call build_image,fedora,43)

dockerfiles/dist/ubuntu/ubuntu-24.04.tar: ./.gitlab/build_image.sh
dockerfiles/dist/ubuntu/ubuntu-24.04.tar: dockerfiles/ubuntu.dockerfile
	$(call build_image,ubuntu,24.04)

.PHONY: ansible-lint
ansible-lint:
	ansible-playbook --syntax-check $(playbooks)
	ansible-lint -s -p playbooks

define test_os
	@# $1 is the OS
	@# $2 is the OS_VERSION
	@# TODO: rustup executes files in /tmp. Needed to drop noexec
	if uname -a | grep '\-WSL'; then \
		$(CONTAINER) create \
			--env ANSIBLE_FORCE_COLOR=1 \
			--interactive \
			--name="perobertson-setup-$(1)-$(2)" \
			--rm \
			--tty \
			--volume="$(shell pwd):/setup" \
			--workdir /setup \
			"localhost/perobertson-setup-$(1):$(2)" || true; \
	else \
		$(CONTAINER) create \
			--env ANSIBLE_FORCE_COLOR=1 \
			--interactive \
			--name="perobertson-setup-$(1)-$(2)" \
			--rm \
			--tmpfs="/run:rw,noexec,nosuid,nodev" \
			--tmpfs="/tmp:rw,nosuid,nodev" \
			--tty \
			--volume="/sys/fs/cgroup:/sys/fs/cgroup:ro" \
			--volume="$(shell pwd):/setup" \
			--workdir /setup \
			"localhost/perobertson-setup-$(1):$(2)" /lib/systemd/systemd || true; \
	fi
	$(CONTAINER) start "perobertson-setup-$(1)-$(2)" || true
	@# The container must run as root for systemd
	@# This means we need to explicitly start a different session for the user
	$(CONTAINER) exec "perobertson-setup-$(1)-$(2)" su public --command="./setup.sh"
	$(CONTAINER) exec "perobertson-setup-$(1)-$(2)" su public --command="./.gitlab/check_versions.bash"
	$(CONTAINER) exec "perobertson-setup-$(1)-$(2)" su public --command="./.gitlab/verify_no_changes.sh"
	$(CONTAINER) stop "perobertson-setup-$(1)-$(2)"
endef

.PHONY: test-centos-stream9
test-centos-stream9: dockerfiles/dist/centos/centos-stream9.tar
	$(call test_os,centos,stream9)

.PHONY: test-fedora-41
test-fedora-41: dockerfiles/dist/fedora/fedora-41.tar
	$(call test_os,fedora,41)

.PHONY: test-fedora-42
test-fedora-42: dockerfiles/dist/fedora/fedora-42.tar
	$(call test_os,fedora,42)

.PHONY: test-fedora-43
test-fedora-43: dockerfiles/dist/fedora/fedora-43.tar
	$(call test_os,fedora,43)

.PHONY: test-ubuntu-24.04
test-ubuntu-24.04: dockerfiles/dist/ubuntu/ubuntu-24.04.tar
	$(call test_os,ubuntu,24.04)

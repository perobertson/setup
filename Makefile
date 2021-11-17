.DEFAULT_GOAL:=ansible-lint
plays:=docker gcloud kubernetes razer setup
playbooks:=$(addsuffix .yml, $(plays))

export ANSIBLE_CONFIG="./config/ansible.cfg"

ifneq ($(shell command -v podman), '')
CONTAINER?=podman
else ifneq ($(shell command -v docker), '')
CONTAINER?=docker
else
$(warning no container platform found. Cannot run test targets.)
endif

.git/hooks/pre-commit: .pre-commit-config.yaml
	pre-commit install

.PHONY: ansible-lint
ansible-lint:
	ansible-playbook --syntax-check $(playbooks)
	ansible-lint -p .

.PHONY: git_hooks
git_hooks: .git/hooks/pre-commit

.PHONY: install
install:
	./setup.sh

.PHONY: install_docker
install_docker:
	ansible-playbook --ask-become-pass -v docker.yml

.PHONY: install_flatpaks
install_flatpaks:
	ansible-playbook -v flatpaks.yml

.PHONY: install_gcloud
install_gcloud:
	ansible-playbook --ask-become-pass -v gcloud.yml

.PHONY: install_kubernetes
install_kubernetes:
	ansible-playbook --ask-become-pass -v kubernetes.yml

.PHONY: install_razer
install_razer:
	ansible-playbook --ask-become-pass -v razer.yml

.PHONY: install_rust_crates
install_rust_crates:
	./extras.sh

.PHONY: install_setup
install_setup:
	ansible-playbook --ask-become-pass -v setup.yml

.PHONY: test-arch
test-arch:
	$(CONTAINER) pull archlinux:latest
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-arch \
		archlinux:latest bash || true
	$(CONTAINER) exec scripts-arch ./.gitlab/setup_archlinux.bash
	$(CONTAINER) exec scripts-arch ./.gitlab/build.bash
	$(CONTAINER) exec scripts-arch su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-arch

.PHONY: stop-arch
stop-arch:
	$(CONTAINER) stop scripts-arch

.PHONY: test-centos-8
test-centos-8:
	$(CONTAINER) pull quay.io/centos/centos:stream8
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-centos-8 \
		quay.io/centos/centos:stream8 bash || true
	$(CONTAINER) exec scripts-centos-8 ./.gitlab/setup_centos.bash
	$(CONTAINER) exec scripts-centos-8 ./.gitlab/build.bash
	$(CONTAINER) exec scripts-centos-8 su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-centos-8

.PHONY: stop-centos-8
stop-centos-8:
	$(CONTAINER) stop scripts-centos-8

.PHONY: test-debian-11
test-debian:
	$(CONTAINER) pull debian:11
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-debian-11 \
		debian:11 bash || true
	$(CONTAINER) exec scripts-debian-11 ./.gitlab/setup_debian.bash
	$(CONTAINER) exec scripts-debian-11 ./.gitlab/build.bash
	$(CONTAINER) exec scripts-debian-11 su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-debian

.PHONY: stop-debian-11
stop-debian-11:
	$(CONTAINER) stop scripts-debian-11

.PHONY: test-fedora-35
test-fedora-35:
	$(CONTAINER) pull fedora:35
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-fedora-35 \
		fedora:35 bash || true
	$(CONTAINER) exec scripts-fedora-35 ./.gitlab/setup_fedora.bash
	$(CONTAINER) exec scripts-fedora-35 ./.gitlab/build.bash
	$(CONTAINER) exec scripts-fedora-35 su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-fedora

.PHONY: stop-fedora-35
stop-fedora-35:
	$(CONTAINER) stop scripts-fedora-35

.PHONY: test-manjaro
test-manjaro:
	$(CONTAINER) pull manjarolinux/base:latest
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-manjaro \
		manjarolinux/base:latest bash || true
	$(CONTAINER) exec scripts-manjaro ./.gitlab/setup_archlinux.bash
	$(CONTAINER) exec scripts-manjaro ./.gitlab/build.bash
	$(CONTAINER) exec scripts-manjaro su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-manjaro

.PHONY: stop-manjaro
stop-manjaro:
	$(CONTAINER) stop scripts-manjaro

.PHONY: test-ubuntu-18
test-ubuntu-18:
	$(CONTAINER) pull ubuntu:18.04
	$(CONTAINER) run \
		-ditv "$(shell pwd):/scripts" \
		-w /scripts \
		-e ANSIBLE_FORCE_COLOR=1 \
		--rm \
		--name scripts-ubuntu-18 \
		ubuntu:18.04 bash || true
	$(CONTAINER) exec scripts-ubuntu-18 ./.gitlab/setup_ubuntu.bash
	$(CONTAINER) exec scripts-ubuntu-18 ./.gitlab/build.bash
	$(CONTAINER) exec scripts-ubuntu-18 su public --command="./.gitlab/check_versions.bash"
	$(MAKE) stop-ubuntu-18

.PHONY: stop-ubuntu-18
stop-ubuntu-18:
	$(CONTAINER) stop scripts-ubuntu-18

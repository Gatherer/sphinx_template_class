# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build
WATCHEXTRA    =
WATCHIGNORE   = $(BUILDDIR)/* Dockerfile texinputs/* venv/* *.swp

define watch-extra
$(foreach WATCH_ARG,$(WATCHEXTRA),--watch "$(WATCH_ARG)")
endef

define watch-ignore
$(foreach IGNORE_ARG,$(WATCHIGNORE),--ignore "$(IGNORE_ARG)")
endef

# Virtual environment variables
VENVDIR       = venv
VENVACTIVATE  = $(VENVDIR)/bin/activate

# Docker variables
SPHINXDOCKER  ?=
DOCKERIMGNAME  = sphinxdoc
DOCKEROPTS     = --interactive --user $(shell id --user):$(shell id --group) \
	--tty --rm --volume $(PWD)/..:/proj

ifneq ($(SPHINXDOCKER),)
LIVEHTMLPORT ?= 8000
else
LIVEHTMLPORT ?= 0
endif

# Put it first so that "make" without argument is like "make help".
ifneq ($(SPHINXDOCKER),)
help: docker
	@docker run $(DOCKEROPTS) $(DOCKERIMGNAME) \
		$(SPHINXBUILD) -M help "$(SOURCEDIR)" \
		"$(BUILDDIR)" $(SPHINXOPTS) $(O)
else
help: venv
	@. $(VENVACTIVATE) && $(SPHINXBUILD) -M help "$(SOURCEDIR)" \
		"$(BUILDDIR)" $(SPHINXOPTS) $(O)
endif
.PHONY: help

# $(O) is meant as a shortcut for $(SPHINXOPTS).
ifneq ($(SPHINXDOCKER),)
latexpdf html: docker
	@docker run $(DOCKEROPTS) $(DOCKERIMGNAME) \
		$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" \
		"$(BUILDDIR)" $(SPHINXOPTS) -v $(O)
else
latexpdf html: venv
	@. $(VENVACTIVATE) && $(SPHINXBUILD) -M $@ "$(SOURCEDIR)" \
		"$(BUILDDIR)" $(SPHINXOPTS) -v $(O)
endif

ifneq ($(SPHINXDOCKER),)
livehtml: docker
	@docker run $(DOCKEROPTS) --publish $(LIVEHTMLPORT):$(LIVEHTMLPORT) \
		$(DOCKERIMGNAME) \
		sphinx-autobuild -b html --port $(LIVEHTMLPORT) --host '*' \
		$(call watch-ignore) -E --poll $(SOURCEDIR) $(call watch-extra) \
		$(BUILDDIR)/html
else
livehtml: venv
	@. $(VENVACTIVATE) && sphinx-autobuild -b html --port $(LIVEHTMLPORT) \
		--host '*' $(call watch-ignore) -E --poll $(SOURCEDIR) \
		$(call watch-extra) $(BUILDDIR)/html
endif

# Virtual environment setup
venv: $(VENVACTIVATE)

$(VENVACTIVATE): */requirements.txt
	test -d $(VENVDIR) || python3 -m venv $(VENVDIR) && \
	. $(VENVACTIVATE) && \
	pip install wheel && \
	pip install -r */requirements.txt && \
	touch $(VENVACTIVATE)

# Docker setup
docker:
	docker build --tag $(DOCKERIMGNAME) .

clean:
	rm -rf _build
.PHONY: clean

mrproper: clean
	rm -rf venv
ifneq ($(SPHINXDOCKER),)
	docker rmi --force $(DOCKERIMGNAME)
endif

.PHONY: mrproper

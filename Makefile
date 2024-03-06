VENV_BIN = python3 -m venv
VENV_DIR ?= .venv
VENV_ACTIVATE = $(VENV_DIR)/bin/activate
VENV_RUN = . $(VENV_ACTIVATE)
ROOT_MODULE = circleci_test

venv: $(VENV_ACTIVATE)

$(VENV_ACTIVATE): pyproject.toml
	test -d .venv || $(VENV_BIN) .venv
	$(VENV_RUN); pip install --upgrade pip setuptools wheel build
	$(VENV_RUN); pip install -e .[dev]
	touch $(VENV_DIR)/bin/activate

install: venv

clean:
	rm -rf .venv
	rm -rf build/
	rm -rf .eggs/
	rm -rf *.egg-info/

format:
	$(VENV_RUN); python -m ruff check --output-format=full --fix .; python -m black .

lint:
	$(VENV_RUN); python -m ruff check --output-format=full . && python -m black --check .

test: venv
	$(VENV_RUN); python -m pytest tests

test-coverage: venv
	$(VENV_RUN); coverage run --source=$(ROOT_MODULE) -m pytest tests && coverage lcov -o .coverage.lcov

coveralls: venv
	$(VENV_RUN); coveralls

dist: venv
	$(VENV_RUN); python -m build

upload: clean-dist venv test dist
	$(VENV_RUN); pip install --upgrade twine; twine upload dist/*

clean-dist: clean
	rm -rf dist/

.PHONY: clean clean-dist

#!/bin/bash

set -e
set -x

python -m venv test_env
source test_env/bin/activate

python -m pip install dist/*.tar.gz
python -m pip install -r requirements/test_requirements.txt

# Run the tests on the installed source distribution
mkdir tmp_for_test
cd tmp_for_test

# TODO(thomasjpfan): use `--pyargs sklearn`
pytest --pyargs sklearn.tests.test_dummy

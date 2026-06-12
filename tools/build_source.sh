#!/bin/bash

set -e
set -x

python -m venv build_venv
source build_venv/bin/activate

python -m pip install -r requirements/sdist_build_requirements.txt
python -m build scikit-learn-src --sdist --outdir dist

# Check whether the source distribution will render correctly
twine check dist/*.tar.gz

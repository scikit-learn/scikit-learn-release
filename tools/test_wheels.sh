#!/bin/bash

set -e
set -x

PROJECT_DIR="$1"
SCIKIT_LEARN_CONFIG=$(
    python -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' \
    "$PROJECT_DIR/../scikit-learn-src/pyproject.toml"
)


python $PROJECT_DIR/tools/check_license.py

python -c "import joblib; print(f'Number of cores (physical): \
{joblib.cpu_count()} ({joblib.cpu_count(only_physical_cores=True)})')"

FREE_THREADED_BUILD="$(python -c"import sysconfig; print(bool(sysconfig.get_config_var('Py_GIL_DISABLED')))")"
if [[ $FREE_THREADED_BUILD == "True" ]]; then
    # TODO: delete when importing numpy no longer enables the GIL
    # setting to zero ensures the GIL is disabled while running the
    # tests under free-threaded python
    export PYTHON_GIL=0
fi

# Test that there are no links to system libraries in the
# threadpoolctl output section of the show_versions output:
python -c "import sklearn; sklearn.show_versions()"

if pip show -qq pytest-xdist; then
    XDIST_WORKERS=$(python -c "import joblib; print(joblib.cpu_count(only_physical_cores=True))")
    pytest -c $SCIKIT_LEARN_CONFIG --pyargs sklearn -n $XDIST_WORKERS
else
    pytest -c $SCIKIT_LEARN_CONFIG --pyargs sklearn
fi

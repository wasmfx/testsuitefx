#!/bin/bash

# Use this script to export/copy the tests in this repo to the spec repo
# Usage: ./export_to_spec.sh SPEC_REPO_PATH

# A commit we expect to see in the spec repo.
# Just used as a check to see that the repo path is valid.
SPEC_REPO_COMMIT="ec38c06717612db984314ceef08878838e1fd9ee"

function error() {
  echo "Error: $1"
  exit 1
}

if [[ $# -ne 1 ]] ; then
  error "invalid arguments argument. Usage: ./export_to_spec.sh SPEC_REPO_PATH"
fi

spec_repo_dir=$(readlink -f $1)


if [[ ! -d "$spec_repo_dir" ]] ; then
  echo 123
fi

pushd "$spec_repo_dir" || error "could not cd to $spec_repo_dir"

git rev-parse --verify "$SPEC_REPO_COMMIT" ||
    error "Did not find expected commit $SPEC_REPO_COMMIT in $spec_repo_dir. Is it really a spec repo?"

popd

cp spec/validation.wast $spec_repo_dir/test/core/wasmfx_validation.wast
cp spec/validation_gc.wast $spec_repo_dir/test/core/wasmfx_validation_gc.wast


# Let's make sure that our tests actually work
cd "$spec_repo_dir"/interpreter
make || error "failed to build reference interpreter"
make test || error "New tests caused failure?"

#!/usr/bin/env bash
# FILES=./functional/*.spec.coffee
FILES=`find ./functional -type f -name "*.spec.coffee"`

DEFAULT_REPORTER='xunit'

REPORTER=${1:-$DEFAULT_REPORTER}

for f in $FILES
do
  if [ "$REPORTER" == "$DEFAULT_REPORTER" ]
  then
    filename=$(basename "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    report="$filename.xml"
    # echo "Processing $filename file... to $report"
    NODE_ENV=test ./node_modules/.bin/mocha \
      --compilers coffee:coffee-script/register \
      --ui bdd  \
      --timeout 10000 \
      --reporter $REPORTER \
      $f > "test_reports/$report"
  else
    filename=$(basename "$f")
    extension="${filename##*.}"
    filename="${filename%.*}"
    report="$filename.xml"
    echo "Processing $filename file..."
    NODE_ENV=test ./node_modules/.bin/mocha \
      --compilers coffee:coffee-script/register \
      --ui bdd  \
      --timeout 10000 \
      --reporter $REPORTER $f
    if [ $? -ne 0 ]
    then
      exit 1
    fi
  fi

done

# NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --ui bdd --recursive --reporter xunit ./functional/**/*.spec.coffee > test_reports/functional-test-report.xml

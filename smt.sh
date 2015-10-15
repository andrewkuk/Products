#!/usr/bin/env bash
# Single Mocha Test :)
filename=$(basename "$1")
extension="${filename##*.}"
filename="${filename%.*}"
report="$filename.xml"
echo "Processing $filename file..."
NODE_ENV=test ./node_modules/.bin/mocha \
  --compilers coffee:coffee-script/register \
  --ui bdd  \
  --reporter spec $1
# NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script/register --ui bdd --recursive --reporter xunit ./functional/**/*.spec.coffee > test_reports/functional-test-report.xml

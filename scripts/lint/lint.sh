#!/bin/sh
OLDPATH="$PATH"
WHEREAMI="`pwd`"


# $HYBRIXD/node/scripts/npm  => $HYBRIXD
SCRIPTDIR="`dirname \"$0\"`"
HYBRIXD="`cd \"$SCRIPTDIR/../../..\" && pwd`"

# Move to provided directory
if [ -z "$2" ]; then
    cd "$HYBRIXD/$1"
else
    cd "$1"
fi

IFS=$'\n'
STAGED_FILES=$(git diff --stat --cached --name-only master | grep ".jsx\{0,1\}$" | grep "^[^node_;]")
ESLINT="$(git rev-parse --show-toplevel)/../common/node_modules/.bin/eslint"

echo "\nPre Push:\n"

if [[ "$STAGED_FILES" = "" ]]; then
  echo "\033[42mNO CHANGES\033[0m\n"
  exit 0
fi

PASS=true

echo "\nValidating Javascript:\n"

# Check for eslint
if [[ ! -x "$ESLINT" ]]; then
  echo "\t\033[41mPlease install ESlint and dependencies\033[0m (npm i eslint-plugin-promise eslint-plugin-standard eslint-plugin-react)"
  echo "\t\033[41mPlease install ESlint Standard config\033[0m (npm i eslint-config-standard)"
  echo "\t\033[41mPlease install ESlint Semi-standard config\033[0m (npm i eslint-config-semistandard)"
  exit 1
fi

for FILE in $STAGED_FILES
do
  $ESLINT "$FILE" -c "$HYBRIXD/common/hooks/eslintrc.js"

  if [[ "$?" == 0 ]]; then
    echo "\t\033[32mESLint Passed: $FILE\033[0m"
  else
    echo "\t\033[41mESLint Failed: $FILE\033[0m"
    PASS=false
  fi
done

echo "\nJavascript validation completed!\n"

if ! $PASS; then
  echo "\033[41mCOMMIT FAILED:\033[0m Your commit contains files that should pass ESLint but do not. Please fix the ESLint errors and try again.\n"
  exit 1
else
  echo "\033[42mCOMMIT SUCCEEDED\033[0m\n"
fi


export PATH="$OLDPATH"
cd "$WHEREAMI"
exit $?
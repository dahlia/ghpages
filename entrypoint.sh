#!/bin/sh

set -e

echo "#################################################"
echo "Prepare a temporary Git repository ..."
REMOTE_REPO="https://${GH_PAT}@github.com/${GITHUB_REPOSITORY}.git"
REPONAME="$(echo "$GITHUB_REPOSITORY"| cut -d'/' -f 2)"
OWNER="$(echo "$GITHUB_REPOSITORY"| cut -d'/' -f 1)"
GHIO="${OWNER}.github.io"
if [ "$REPONAME" = "$GHIO" ]; then
  REMOTE_BRANCH="master"
else
  REMOTE_BRANCH="gh-pages"
fi
if [ "$NO_SQUASH" = "" ]; then
  cd "$(mktemp -d)"
  git init
  git remote add origin "$REMOTE_REPO"
  git checkout -b "$REMOTE_BRANCH"
else
  repo_dir="$(mktemp -d)"
  git clone --branch="$REMOTE_BRANCH" "$REMOTE_REPO" "$repo_dir"
  cd "$repo_dir"
fi
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"

echo "#################################################"
echo "Copy contents from 'BUILD_DIR' $BUILD_DIR ..."
cp -rf "$GITHUB_WORKSPACE/$BUILD_DIR/." ./

echo "#################################################"
echo "Now deploying to GitHub Pages..."
if [ -z "$(git status --porcelain)" ]; then
    echo "Nothing to commit" && \
    exit 0
fi && \
git add . && \
git commit -m 'Deploy to GitHub pages' && \
git push --force origin "$REMOTE_BRANCH" && \
rm -fr .git && \
cd "$GITHUB_WORKSPACE" && \
echo "Content of $BUILD_DIR has been deployed to GitHub Pages."

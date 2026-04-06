#!/usr/bin/env bash
set -euo pipefail

GEM_NAME="lariconv"
VERSION=$(ruby -e "puts Gem::Specification.load('${GEM_NAME}.gemspec').version")
GEM_FILE="${GEM_NAME}-${VERSION}.gem"
OTP="${1:-}"

echo "==> Version: ${VERSION}"

if [[ -z "${GEM_HOST_API_KEY:-}" ]] && [[ ! -f "${HOME}/.gem/credentials" ]]; then
  echo "ERROR: RubyGems API key not found."
  exit 1
fi

echo "==> Running tests..."
bundle exec rspec --format progress
echo "==> Tests passed."

rm -f "${GEM_NAME}"-*.gem

echo "==> Building ${GEM_FILE}..."
gem build "${GEM_NAME}.gemspec"

if [[ ! -f "${GEM_FILE}" ]]; then
  echo "ERROR: ${GEM_FILE} not found after build."
  exit 1
fi

if [[ -z "${OTP}" ]]; then
  read -rp "==> Enter OTP code: " OTP
fi

echo "==> Publishing to RubyGems.org..."
gem push "${GEM_FILE}" --otp "${OTP}"

echo ""
echo "==> ${GEM_NAME} ${VERSION} published!"
echo "    https://rubygems.org/gems/${GEM_NAME}"

rm -f "${GEM_FILE}"

#!/usr/bin/env bash
cd "$(dirname "$0")"

# Cleanup older documentation
mkdir -p docs
rm -f docs/*.md

# Generate new documentation
directories=$(ls -d */ | grep -v "docs\|tests\|examples")
for dx in ${directories}; do
    find ${dx} -type f -name "*.sh" -exec shdoc {} \; > docs/$(dirname ${dx}.).md
done

# Overwrite README.md
cp -f README.md README.bak
cp -f README.template README.md
for dx in ${directories}; do
    d=$(dirname ${dx}.)
    sed -i "/The following set of functions are available at present:/a * [${d}](docs/${d}.md)" README.md
done

#!/bin/bash
# Script to update version numbers across all SDKs and generate release notes

# Exit on first error
set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <new_version>"
  echo "Example: $0 0.2.0"
  exit 1
fi

NEW_VERSION=$1
RELEASE_DATE=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

echo "Updating version to $NEW_VERSION across all SDKs..."

# Update Node.js SDK version
echo "Updating Node.js SDK version..."
sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$NEW_VERSION\"/" sdks/node-sdk/package.json

# Update Python SDK version
echo "Updating Python SDK version..."
sed -i "s/version=\"[0-9]*\.[0-9]*\.[0-9]*\"/version=\"$NEW_VERSION\"/" sdks/python-sdk/setup.py
sed -i "s/__version__ = \"[0-9]*\.[0-9]*\.[0-9]*\"/__version__ = \"$NEW_VERSION\"/" sdks/python-sdk/vaultarq/__init__.py

# Update Rust SDK version
echo "Updating Rust SDK version..."
sed -i "s/version = \"[0-9]*\.[0-9]*\.[0-9]*\"/version = \"$NEW_VERSION\"/" sdks/rust-sdk/Cargo.toml

# Update Go SDK version (in readme and documentation)
# Note: Go uses git tags for versioning, so we don't need to update any files

# Update CHANGELOG.md with release date
echo "Updating CHANGELOG.md with release date..."
sed -i "s/## \[$NEW_VERSION\] - YYYY-MM-DD/## \[$NEW_VERSION\] - $RELEASE_DATE/" CHANGELOG.md

# Generate release notes
echo "Generating release notes..."
RELEASE_NOTES_FILE="RELEASE_NOTES.md"

# Extract the content for this version from CHANGELOG.md
awk -v version="$NEW_VERSION" '
  BEGIN { found=0; output=0; }
  /^## \['"$NEW_VERSION"'\]/ { found=1; output=1; }
  /^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ && !/^## \['"$NEW_VERSION"'\]/ { if (found) output=0; }
  { if (output) print; }
' CHANGELOG.md > "$RELEASE_NOTES_FILE"

# Add links to packages at the bottom
cat >> "$RELEASE_NOTES_FILE" << EOF

## Available Packages

- **Node.js**: \`npm install @vaultarq/node@$NEW_VERSION\`
- **Python**: \`pip install vaultarq==$NEW_VERSION\`
- **Rust**: Add \`vaultarq = "$NEW_VERSION"\` to your \`Cargo.toml\`
- **Go**: Add \`github.com/Vaultarq/go v$NEW_VERSION\` to your imports
EOF

echo "All SDK versions updated to $NEW_VERSION"
echo "Release notes generated in $RELEASE_NOTES_FILE"
echo ""
echo "Next steps:"
echo "1. Review and update CHANGELOG.md if needed"
echo "2. Review generated release notes in $RELEASE_NOTES_FILE"
echo "3. Commit these changes:"
echo "   git add ."
echo "   git commit -m \"Bump version to $NEW_VERSION\""
echo ""
echo "4. Tag the release:"
echo "   git tag v$NEW_VERSION"
echo ""
echo "5. Push to GitHub to trigger release workflow:"
echo "   git push && git push --tags"
echo ""
echo "The GitHub Actions workflow will handle publishing to all registries." 
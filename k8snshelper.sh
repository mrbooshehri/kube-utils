#!/bin/bash
set -e

usage() {
  echo "Usage: $0 -s <source-base-dir> -n <new-namespace>"
  echo "Example: $0 -s exports -n stage"
  exit 1
}

while getopts ":s:n:" opt; do
  case $opt in
    s) SRC_DIR="$OPTARG" ;;
    n) NEW_NS="$OPTARG" ;;
    \?) usage ;;
  esac
done

if [[ -z "$SRC_DIR" || -z "$NEW_NS" ]]; then
  echo "❌ Both -s <source-base-dir> and -n <new-namespace> are required."
  usage
fi

if ! command -v yq >/dev/null; then
  echo "❌ yq (mikefarah) is required but not found. Please install it."
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Source directory '$SRC_DIR' does not exist."
  exit 1
fi

DST_DIR="${SRC_DIR}_converted"

echo "📁 Source directory: $SRC_DIR"
echo "📁 Destination directory: $DST_DIR"
echo "🔄 Updating namespace and component label to '$NEW_NS' in all YAML files..."

find "$SRC_DIR" -type f -name '*.yaml' | while read -r file; do
  relpath="${file#$SRC_DIR/}"
  dstfile="$DST_DIR/$relpath"
  mkdir -p "$(dirname "$dstfile")"

  echo " - Processing $relpath"

  # Apply changes using yq
  {
    yq eval ".metadata.namespace = \"$NEW_NS\"" "$file" |
    yq eval ".metadata.labels.\"app.kubernetes.io/component\" = \"$NEW_NS\"" - > "$dstfile"
  } || {
    echo "❌ Failed to process $relpath — likely invalid YAML"
    continue
  }
done

echo "✅ Namespace and label update complete. Files saved to: $DST_DIR"

#!/bin/bash
set -e

# === Function to print usage ===
usage() {
  echo "Usage: $0 [-d <base-directory>]"
  echo "If -d is not provided, current directory is used."
  exit 1
}

# === Parse arguments ===
BASE_DIR="."
while getopts ":d:" opt; do
  case $opt in
    d) BASE_DIR="$OPTARG" ;;
    \?) usage ;;
  esac
done

if [[ ! -d "$BASE_DIR" ]]; then
  echo "❌ Error: Directory '$BASE_DIR' does not exist."
  exit 1
fi

echo "🚀 Applying resources from: $BASE_DIR"
echo

# === Recursively apply YAML files ===
find "$BASE_DIR" -type f -name '*.yaml' | while read -r yaml_file; do
  filename="$(basename "$yaml_file")"
  relpath="${yaml_file#$BASE_DIR/}"

  # Skip kube-root-ca.crt.yaml
  if [[ "$filename" == "kube-root-ca.crt.yaml" ]]; then
    echo "⏭️ Skipping $relpath"
    continue
  fi

  echo "📄 Applying $relpath ..."
  if ! kubectl apply -f "$yaml_file"; then
    echo "⚠️  Failed to apply: $relpath — skipping"
  fi
done

echo
echo "✅ All applicable resources have been applied."

#!/bin/bash

set -e

# === Function to print usage ===
usage() {
  echo "Usage: $0 -n <namespace> -r <resource-type> [resource-name]"
  exit 1
}

# === Parse arguments ===
while getopts ":n:r:" opt; do
  case ${opt} in
    n ) NAMESPACE="$OPTARG" ;;
    r ) RESOURCE="$OPTARG" ;;
    \? ) usage ;;
  esac
done
shift $((OPTIND -1))
NAME=$1

# === Validate inputs ===
if [[ -z "$NAMESPACE" || -z "$RESOURCE" ]]; then
  echo "❌ Error: -n <namespace> and -r <resource-type> are required."
  usage
fi

# === Check and install mikefarah's yq if needed ===
check_yq() {
  if ! command -v yq >/dev/null; then
    echo "🔍 yq not found. Installing mikefarah's yq..."
    wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
  fi

  if ! yq --version | grep -qi 'mikefarah'; then
    echo "❌ Incorrect yq version detected. Please uninstall other versions and rerun."
    exit 1
  fi
}
check_yq

# === Common clean filter for yq ===
CLEAN_FILTER='del(
  .metadata.creationTimestamp,
  .metadata.generation,
  .metadata.resourceVersion,
  .metadata.selfLink,
  .metadata.uid,
  .metadata.managedFields,
  .metadata.annotations,
  .status,
  .spec.template.metadata.creationTimestamp,
  .spec.template.metadata.annotations."kubectl.kubernetes.io/restartedAt"
)'

# === Output directory ===
OUT_DIR="./exports/${NAMESPACE}/${RESOURCE}"
mkdir -p "$OUT_DIR"

# === Export logic ===
if [[ -z "$NAME" ]]; then
  echo "📦 Exporting ALL $RESOURCE resources from namespace '$NAMESPACE'..."

  RAW_YAML=$(kubectl -n "$NAMESPACE" get "$RESOURCE" -o yaml)

  # Detect if it's a list
  if ! echo "$RAW_YAML" | yq eval '.kind' - | grep -q "List"; then
    echo "❌ Expected a list of resources but got single. Aborting."
    exit 1
  fi

  COUNT=$(echo "$RAW_YAML" | yq eval '.items | length' -)
  for i in $(seq 0 $((COUNT - 1))); do
    ITEM_NAME=$(echo "$RAW_YAML" | yq eval ".items[$i].metadata.name" -)
    echo "🔹 Exporting $RESOURCE/$ITEM_NAME..."

    echo "$RAW_YAML" \
    | yq eval ".items[$i] | $CLEAN_FILTER" - \
    > "${OUT_DIR}/${ITEM_NAME}.yaml"
  done

else
  echo "📦 Exporting $RESOURCE/$NAME in namespace $NAMESPACE..."
  kubectl -n "$NAMESPACE" get "$RESOURCE" "$NAME" -o yaml \
  | yq eval "$CLEAN_FILTER" - \
  > "${OUT_DIR}/${NAME}.yaml"
fi

echo "✅ Export complete. Files saved to: $OUT_DIR"

#!/bin/bash

# Check if at least one argument is passed
if [ $# -eq 0 ]; then
  echo "Usage: $0 <namespace1> [namespace2 ... namespaceN]"
  exit 1
fi

# Loop through all arguments
for ns in "$@"; do
  echo "Creating namespace: $ns"
  kubectl create namespace "$ns" 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "✅ Namespace '$ns' created."
  else
    echo "⚠️  Namespace '$ns' may already exist or an error occurred."
  fi
done

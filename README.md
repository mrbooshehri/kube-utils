# kube-utils

**kube-utils** is a collection of CLI tools and scripts designed to streamline working with Kubernetes. It simplifies tasks like exporting, transforming, applying, and managing resources—making it easier to build, maintain, and automate Kubernetes workflows across environments.

## Features

- Export Kubernetes resources as clean YAML files with unnecessary metadata removed
- Batch update namespaces and labels in YAML manifests for environment migration
- Apply multiple YAML files at once from any directory
- Quickly create one or multiple Kubernetes namespaces
- Easily extendable with new scripts to support common Kubernetes operations

## Included Scripts

---

### 1. `k8sgetter.sh`

Export Kubernetes resources by namespace and resource type, optionally filtering by resource name. Cleans YAML metadata for reuse.

#### How to use

```bash
# Export all resources of a given type from a namespace
./k8sgetter.sh -n <namespace> -r <resource-type>

# Export a specific resource by name
./k8sgetter.sh -n <namespace> -r <resource-type> <resource-name>
````

Example:

```bash
./k8sgetter.sh -n default -r deployment
./k8sgetter.sh -n kube-system -r svc kube-dns
```

---

### 2. `k8snshelper.sh`

Batch update the namespace and component labels in exported YAML files to adapt them to new environments.

#### How to use

```bash
./k8snshelper.sh -s <source-base-dir> -n <new-namespace>
```

Example:

```bash
./k8snshelper.sh -s exports/default/deployment -n staging
```

Creates a new directory `exports/default/deployment_converted` with updated files.

---

### 3. `k8snscreate.sh`

Create one or more Kubernetes namespaces in a single command.

#### How to use

```bash
./k8snscreate.sh <namespace1> [namespace2 ... namespaceN]
```

Example:

```bash
./k8snscreate.sh dev staging prod
```

---

### 4. `k8sapply.sh`

Recursively apply all valid `.yaml` files in a directory (excluding `kube-root-ca.crt.yaml`).

#### How to use

```bash
./k8sapply.sh [-d <base-directory>]
```

* If `-d` is not provided, the current directory is used.
* Skips invalid files and continues applying the rest.

Example:

```bash
./k8sapply.sh -d exports/staging
```

---

## Requirements

* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [yq (mikefarah)](https://github.com/mikefarah/yq) — required by `k8sgetter.sh` and `k8snshelper.sh`

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/kube-utils.git
cd kube-utils
chmod +x *.sh
```

Ensure `kubectl` and `yq` are installed and accessible via `PATH`.

## Contributing

Contributions and new utility scripts are welcome! Please open issues or pull requests.

## License

This project is licensed under the [MIT License](LICENSE).

---

> Simplify your Kubernetes workflow, one script at a time.

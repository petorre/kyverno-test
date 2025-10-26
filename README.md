# Sylva \ WG2 Validation \ Flavor Validation \ Kyverno test

## Target

Deploy a flavour cluster with Kyverno as policy management.  How to confirm it is in use?

## Prerequisites

bash, kubectl, jq, md5sum, awk.

## (Optional) Install Kyverno

Assumption is that Kyverno was installed on k8s cluster with something like

```
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.15.2/install.yaml
```

## Test

Check and optionally edit configuration lines in [config](./config) file.

```
./kyverno-test.sh
```

should give

```
SUCCESS: Kyverno tests worked (scheduled with, and stopped scheduling test without resource requests and limits)
```

and

```
./kyverno-test.sh --debug
```

should give

```
Debug: Apply cluster policy YAML
Debug: Sleep 5 seconds
Debug: Cluster policy loaded
Debug: Create namespace YAML
Debug: Sleep 2 seconds
Debug: Apply test1 YAML
Debug: Sleep 5 seconds
Debug: Test1 YAML applied
Debug: Apply test2 YAML
SUCCESS: Kyverno tests worked (scheduled with, and stopped scheduling test without resource requests and limits)
Debug: Delete namespace
Debug: Delete cluster policy
```

## Validated OS and k8s distribution

Rocky Linux 9.6, k3s v1.31.6+k3s1.

# Module 01 — Foundation

**Goal:** create the two things every other module builds on top of: a
namespace to live in, and a way to get persistent disk.

## What's in this module

| File | Kubernetes object | What it's for |
|---|---|---|
| `namespace.yaml` | `Namespace` | `digitalwitch-market` — every object in every later module lists this as its namespace. |
| `storageclass.yaml` | `StorageClass` | `digitalwitch-market-gp3` — tells Kubernetes *how* to create disks (AWS EBS, `gp3`) when a later module asks for one. |
| `pv-postgres-static-example.yaml` | `PersistentVolume` (reference only) | Shows the *other* way to provide storage — pointing at a specific, pre-existing disk instead of creating one on demand. Not applied here; see the comments inside the file. |

## Why this comes first

A `Namespace` is just a named boundary — you can't create anything "in"
`digitalwitch-market` until the namespace itself exists. A `StorageClass`
works the same way for storage: it's a *template* for creating disks, not a
disk itself. Nothing needs a disk yet in this module — but module 03
(Databases) will ask for one by name, so the template has to exist first.

## Deploy it

```bash
kubectl apply -f .
```

(This applies `namespace.yaml` and `storageclass.yaml`. It will also try to
apply the static-PV example — that's fine, `PersistentVolume` objects aren't
namespaced and this one doesn't conflict with anything; it just sits there
unused until something explicitly claims it.)

## Verify

```bash
kubectl get namespace digitalwitch-market
kubectl get storageclass digitalwitch-market-gp3
```

You should see both listed with `STATUS: Active` (namespace) and a
`PROVISIONER` of `ebs.csi.aws.com` (storage class). If the storage class
command errors with "not found", the `apply` didn't work — re-run it and
read the error it prints.

**If your cluster doesn't have the AWS EBS CSI driver installed**, the
`StorageClass` will still create successfully (it's just a template), but
every `PersistentVolumeClaim` in later modules will stay stuck in `Pending`
forever. Ask your trainer to confirm the driver is installed before you hit
module 03.

## Next

[Module 02 — Configuration](../02-configuration/)

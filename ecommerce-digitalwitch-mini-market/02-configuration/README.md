# Module 02 — Configuration

**Goal:** load every service's settings into the cluster *before* any service
that reads them exists. In Kubernetes, config lives separately from the code
that uses it — a `ConfigMap` or `Secret` object, mounted into a Pod later.

## What's in this module

| Kind | Count | Examples |
|---|---|---|
| `ConfigMap` | 11 | `common-config` (shared settings nearly every service reads — ports, service addresses, feature-flag host), plus one per service that needs a config *file* mounted in (Postgres's init SQL, flagd's flag definitions, the OTel Collector's 4 pipeline configs, Grafana's dashboards, ...). |
| `Secret` | 3 | `postgres-secret`, `llm-secret`, `flagd-ui-secret` — same idea as a ConfigMap, but for values you don't want sitting around in plain YAML in a real deployment. |

## Why this comes before everything else

Every Pod you deploy from module 03 onward has a line like:

```yaml
envFrom:
  - configMapRef: {name: common-config}
```

or mounts a `ConfigMap` as a file (Postgres does this for its init script,
flagd for its flag definitions). If `common-config` doesn't exist yet when a
Pod tries to start, the Pod won't start at all — Kubernetes will show you a
`CreateContainerConfigError`. Deploying config *first* means you never see
that error.

## A note on the Secrets here

This is a **training environment**, so the "secrets" are deliberately
visible plaintext in the YAML — the same demo passwords already baked into
the app's own database-init script. That's normal for learning; it is
**not** how you'd manage secrets in a real deployment (you'd use something
like Sealed Secrets, External Secrets, or a cloud secret manager instead).
`llm-secret`'s `API_KEY` ships empty on purpose — the AI assistant in module
10 replays pre-recorded responses until you fill in a real key.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get configmaps -n digitalwitch-market
kubectl get secrets -n digitalwitch-market
```

You should see 11 ConfigMaps and 3 Secrets (plus one extra `Secret` of type
`kubernetes.io/service-account-token` Kubernetes creates automatically —
ignore that one). Spot-check the big one:

```bash
kubectl describe configmap common-config -n digitalwitch-market
```

You should see a wall of `Data` keys like `FLAGD_HOST`, `KAFKA_ADDR`,
`POSTGRES_HOST` — every one of those is a Service DNS name that won't
actually resolve to anything until you deploy the module that creates it.
That's expected at this point.

## Next

[Module 03 — Databases](../03-databases/)

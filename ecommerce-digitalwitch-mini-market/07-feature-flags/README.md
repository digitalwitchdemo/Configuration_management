# Module 07 — Feature Flags

**Goal:** deploy the feature-flag service almost every business service in
module 08 checks against — before those services exist.

## What's in this module

| File | What it deploys |
|---|---|
| `deployment-flagd.yaml` | **flagd** — reads flag definitions from the `flagd-config` ConfigMap (module 02) and serves them over the network on ports 8013 (flag evaluation) and 8016 (OFREP protocol). |
| `deployment-flagd-ui.yaml` | **flagd-ui** — a small web UI for viewing/toggling those flags. |

## Why this matters here

Feature flags in this platform aren't just on/off switches for new
features — several of them deliberately **inject faults**: slow responses,
elevated error rates, a product page that returns the wrong currency. That's
what makes this a useful platform to practice observability on — you can
flip a flag and then go watch the effect show up in Jaeger traces or
Grafana dashboards once modules 08–09 are deployed and sending real traffic.

`cart`, `payment`, `ad`, `recommendation`, `shipping`, `product-catalog`,
`checkout` and `frontend` (all coming in modules 08–09) each check flagd at
startup and on an ongoing basis — deploying flagd first means none of them
have to wait or retry to find it.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in (flagd,flagd-ui)'
```

Both should reach `1/1 Running`. To actually browse the flags once you have
network access to the cluster:

```bash
kubectl -n digitalwitch-market port-forward deploy/flagd-ui 4000:4000
```

then open `http://localhost:4000` — you should see the demo's list of
feature flags, all currently defaulted off.

## Next

[Module 08 — Core Services](../08-core-services/)

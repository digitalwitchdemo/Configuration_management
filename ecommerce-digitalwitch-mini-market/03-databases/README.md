# Module 03 — Databases

**Goal:** stand up the platform's two datastores. This is the first module
that actually claims storage from the `StorageClass` module 01 created.

## What's in this module

| File | What it deploys | Used by |
|---|---|---|
| `pvc-postgres-data.yaml` + `statefulset-postgres.yaml` | **astronomy-db** — a Postgres 18 `StatefulSet`, seeded on first boot from the `postgres-init-sql` ConfigMap (module 02) | `product-catalog` and `accounting` (modules 08 & 04) |
| `pvc-valkey-data.yaml` + `statefulset-valkey.yaml` | **valkey-cart** — a Valkey (Redis-compatible) `StatefulSet` | `cart` (module 08) |

## New concept: `StatefulSet`, not `Deployment`

Every service in modules 04–10 is a plain `Deployment` — replace the Pod,
lose nothing that matters, because it doesn't keep data. A database is
different: if you replace its Pod, you need the **same disk** to come back
with it, not a fresh empty one. That's what `StatefulSet` gives you — a
stable identity paired with a specific `PersistentVolumeClaim`, so a
restarted Postgres pod reattaches to the same data instead of starting
empty.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pvc -n digitalwitch-market
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in (astronomy-db,valkey-cart)'
```

Both PVCs should reach `STATUS: Bound` (if they sit in `Pending`, see the
EBS CSI driver note in module 01) and both pods should reach `1/1 Running`.
Postgres takes the longest to go Ready — it's running the init script from
module 02 on first boot. Watch it directly:

```bash
kubectl logs -n digitalwitch-market -l app.kubernetes.io/name=astronomy-db --follow
```

Look for `database system is ready to accept connections` near the end.

## Next

[Module 04 — Kafka](../04-kafka/)

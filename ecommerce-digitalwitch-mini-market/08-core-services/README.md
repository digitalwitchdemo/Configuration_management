# Module 08 — Core Services

**Goal:** deploy the 11 business microservices the storefront (module 09) is
built out of. This is the biggest module in file count — and the payoff for
everything before it: every one of these services can now find its
dependencies (config, flags, databases, telemetry collector) on the first
try, because modules 01–07 are already up.

## What's in this module

| Service | Language | Job |
|---|---|---|
| `product-catalog` | Go | Product data, backed by Postgres (module 03). |
| `currency` | C++ | Currency conversion. |
| `cart` | C# | Cart storage, backed by Valkey (module 03). |
| `recommendation` | Python | "You might also like" — calls `product-catalog`. |
| `ad` | Java | Contextual ads. |
| `image-provider` | — | Serves product images. |
| `payment` | Node.js | Mock payment processing. |
| `email` | Ruby | Order confirmation emails. |
| `shipping` | Rust | Shipping cost calculation, calls `quote`. |
| `quote` | PHP | Shipping rate quotes. |
| `telemetry-docs` | Python | Serves this platform's generated telemetry schema docs — not on any request path, just a reference service. |

## Why these, and not checkout/frontend, come first

Every one of these is a **backend** service — none of them is meant to be
opened in a browser. Deploying them before the storefront means that when
you deploy `checkout` and `frontend` in module 09, every service they call
(`GET product`, `POST charge`, `GET shipping quote`, ...) already exists and
answers immediately, instead of you watching the storefront fail because
half its dependencies aren't there yet.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in \
  (product-catalog,currency,cart,recommendation,ad,image-provider,payment,email,shipping,quote,telemetry-docs)'
```

All 11 should reach `1/1 Running` — give it a couple of minutes, `ad` and
`recommendation` (JVM/Python startup) are usually the slowest. If any one
stays in `Init:0/1`, `kubectl describe pod <name> -n digitalwitch-market`
will name the exact dependency it's still waiting on (most commonly:
module 07's flagd, or module 03's astronomy-db for `product-catalog`).

Spot-check one end-to-end:

```bash
kubectl -n digitalwitch-market port-forward deploy/product-catalog 3550:3550
grpcurl -plaintext localhost:3550 list   # if you have grpcurl installed
```

## Next

[Module 09 — Storefront](../09-storefront/)

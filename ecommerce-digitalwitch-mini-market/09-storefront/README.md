# Module 09 — Storefront

**Goal:** deploy the application itself — the part a shopper actually sees
and clicks through — now that every backend it depends on (modules 03–08)
is already running.

## What's in this module

| File | What it deploys | Role |
|---|---|---|
| `deployment-checkout.yaml` | **checkout** | Orchestrates a purchase: calls `cart`, `currency`, `payment`, `product-catalog` and `shipping` in sequence, then publishes an order-placed event to Kafka (module 04). |
| `deployment-frontend.yaml` | **frontend** | The storefront UI (Next.js). Calls `product-catalog`, `recommendation`, `ad`, `image-provider`, `currency` and `shipping` directly to render pages, and calls `checkout` to place an order. |
| `deployment-frontend-proxy.yaml` | **frontend-proxy** | Envoy — the single public entry point (`LoadBalancer` Service). Everything a shopper's browser talks to goes through here first. |
| `deployment-load-generator.yaml` | **load-generator** | Locust, playing the role of shoppers automatically — useful for generating traffic to actually watch in Grafana/Jaeger once module 05 has something to show. |

## Why this is module 09, not module 01

Every arrow in the [architecture diagram](../ARCHITECTURE.md) points *out*
from these four services toward something deployed earlier — the storefront
is the thing that **uses** the platform, not part of the platform itself.
Deploy it last (before the AI layer) and it comes up clean on the first try:
no missing database, no missing flag service, no missing Kafka topic.

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in (checkout,frontend,frontend-proxy,load-generator)'
kubectl get svc frontend-proxy -n digitalwitch-market
```

All four pods should reach `1/1 Running`. The `frontend-proxy` Service is
`type: LoadBalancer` — on most clusters its `EXTERNAL-IP` column takes a
minute or two to populate. Once it does:

```bash
open http://<EXTERNAL-IP>:8080     # or just paste it into a browser
```

You should see the Astronomy Shop storefront, be able to browse products,
add one to your cart, and complete checkout. If `EXTERNAL-IP` stays
`<pending>` on a cluster without a real load balancer (e.g. a local
cluster), use a port-forward instead:

```bash
kubectl -n digitalwitch-market port-forward svc/frontend-proxy 8080:8080
```

**This is the milestone.** Everything before this module was invisible
plumbing; this is the first point where the platform is something you can
actually click through.

## Next

[Module 10 — AI Assistant](../10-ai-assistant/)

# Module 10 — AI Assistant

**Goal:** add the AI shopping assistant on top of a storefront that's
already fully working without it — the last module, deliberately.

## What's in this module

| File | What it deploys | Role |
|---|---|---|
| `deployment-mcp.yaml` | **mcp** | An MCP (Model Context Protocol) tool server — exposes the storefront's product catalog as tools an LLM can call. Calls back into `frontend` (module 09) to read live catalog data. |
| `deployment-agent.yaml` | **agent** | The LLM-driven agent loop — plans and calls `mcp`'s tools to answer shopping questions. |
| `deployment-chatbot.yaml` | **chatbot** | The chat UI, reachable through `frontend-proxy` at the `/chatbot` path. Talks only to `agent`. |

The dependency chain is `chatbot → agent → mcp → frontend` — each one only
makes sense once the thing to its right already exists, which is exactly
the order modules 09 and 10 were deployed in.

## Why this is last

Every other module makes the *platform* more complete. This module adds a
*feature* on top of a platform that was already a fully working e-commerce
site without it. That's a distinction worth sitting with: in a real
internship, "ship the AI feature" is very often the last item on a roadmap
for exactly this reason — it's additive, not foundational.

## About the API key

`agent` reads `OPENAI_API_KEY` from the `llm-secret` Secret (module 02),
which ships empty. Left empty, `USE_VCR=True` (set in `common-config`) makes
the agent replay pre-recorded responses from the `agent-fixtures` ConfigMap
instead of calling a real model — so this module works out of the box for
learning the *deployment*, even with no LLM access. Ask your trainer whether
your exercise calls for a real key:

```bash
kubectl create secret generic llm-secret -n digitalwitch-market \
  --from-literal=API_KEY='sk-...' --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout restart deployment/agent -n digitalwitch-market
```

## Deploy it

```bash
kubectl apply -f .
```

## Verify

```bash
kubectl get pods -n digitalwitch-market -l 'app.kubernetes.io/name in (mcp,agent,chatbot)'
```

All three should reach `1/1 Running`. Then, through `frontend-proxy`'s
external address from module 09:

```bash
open http://<frontend-proxy-EXTERNAL-IP>:8080/chatbot
```

Ask it something like "what telescopes do you have under $200?" — with
`USE_VCR=True` you'll get a real (if pre-recorded) response.

## You're done

That's the full platform: infrastructure, data, messaging, observability,
the application, and the AI layer on top of it — ten modules, each one
verified before the next. From here, a good next exercise is picking a
flagd flag from module 07 and watching its effect show up in Grafana or
Jaeger.

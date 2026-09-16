# Architecture

The same system the 10 modules deploy, drawn as one picture. Solid arrows are
the request a shopper's order actually takes; dashed arrows are telemetry
converging on the collector, and feature-flag reads from flagd.

```mermaid
flowchart TB
    client(["Browser / load-generator"])

    subgraph ns["Kubernetes namespace: digitalwitch-market"]
        proxy["frontend-proxy<br/>(Envoy · edge · module 09)"]
        frontend["frontend<br/>(storefront UI · module 09)"]

        subgraph ai["AI assistant · module 10"]
            direction LR
            chatbot --> agent --> mcp
        end

        subgraph browse["Browse-time services · module 08"]
            direction LR
            catalog["product-catalog"]
            rec["recommendation"]
            ad["ad"]
            img["image-provider"]
        end

        checkout["checkout<br/>(order orchestrator · module 09)"]

        subgraph fulfill["Called by checkout · module 08"]
            direction LR
            cart["cart"]
            currency["currency"]
            payment["payment"]
            shipping["shipping"]
            email["email"]
        end
        quote["quote"]

        kafka["kafka · module 04"]
        accounting["accounting"]
        fraud["fraud-detection"]

        subgraph data["Databases · module 03"]
            direction LR
            postgres[("astronomy-db<br/>Postgres")]
            valkey[("valkey-cart")]
        end

        flagd["flagd · module 07"]

        subgraph telemetry["Telemetry plane · modules 05 + 06"]
            collector["otel-collector"]
            jaeger["Jaeger"]
            prometheus["Prometheus"]
            opensearch["OpenSearch"]
            grafana["Grafana"]
        end
    end

    client -->|HTTPS| proxy
    proxy -->|"/*"| frontend
    proxy -.->|"/chatbot"| chatbot
    mcp -.->|reads catalog| frontend

    frontend -->|browse & render| browse
    frontend -->|place order| checkout

    checkout -->|get cart| cart
    checkout -->|convert| currency
    checkout -->|charge| payment
    checkout -->|price check| catalog
    checkout -->|quote| shipping
    checkout -->|confirm| email
    shipping -->|rate| quote

    checkout -->|order placed event| kafka
    kafka -->|consumes: orders| accounting
    kafka -->|consumes: orders| fraud

    cart --> valkey
    accounting --> postgres
    catalog -. reads .-> postgres

    flagd -.->|flag evaluation| checkout
    flagd -.->|flag evaluation| frontend

    proxy -.-> collector
    checkout -.-> collector
    accounting -.-> collector
    collector -.->|traces| jaeger
    collector -.->|metrics| prometheus
    collector -.->|logs| opensearch
    jaeger -.-> grafana
    prometheus -.-> grafana
    opensearch -.-> grafana
```

## Reading this against the modules

- **Modules 01–02** (foundation, configuration) aren't drawn — they're the
  namespace, storage class, ConfigMaps and Secrets everything else in this
  picture depends on existing first.
- **Module 03** is the `data` group (Postgres, Valkey).
- **Module 04** is `kafka`, `accounting`, `fraud-detection`.
- **Module 05** is the `telemetry` group's four backends (Jaeger, Prometheus,
  OpenSearch, Grafana) plus the OpAMP server (not drawn — it's a control-plane
  detail, see the module 05 README).
- **Module 06** is `collector` — deployed after module 05 because it needs
  those backends running to export to.
- **Module 07** is `flagd`.
- **Module 08** is everything in `browse` and `fulfill`.
- **Module 09** is `frontend`, `checkout`, `proxy`, plus the load-generator
  (not drawn — it just plays the same role as the browser at the top).
- **Module 10** is the `ai` group — deployed last, on top of a storefront
  that already works without it.

Left off the diagram entirely: `telemetry-docs` (serves generated schema
docs, not part of any request path) and `opamp-server` (remotely
reconfigures the collector, cart, product-catalog and chatbot — real, but
mostly adds crossing lines to boxes already shown).

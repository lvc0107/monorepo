How Jenkins + k8 agent work together
------------------------------

```
+-------------------+             +--------------------+
|                   |             |                    |
| Jenkins Controller|             |  Jenkins Agent     |
|   (docker-compose)|             |  (docker container)|
|                   |             |                    |
+---------+---------+             +---------+----------+
          |                                 |
          | HTTP/WebSocket (JNLP)           |
          +---------------->----------------+
                    conecta agente
                    con controller

          +------------------------------------+
          |                                    |
          |         Kubernetes Cluster         |
          |                                    |
          |  +------------+   +------------+  |
          |  | kubelet    |   | kubelet    |  |
          |  | Node 1     |   | Node 2     |  |
          |  +------------+   +------------+  |
          |          ^                           ^
          |          |                           |
          +----------|---------------------------+
                     |
              API Server (server: https://192.168.65.3:6443)
                     |
                   etcd


```
Real flow:
```

+----------------------------+
|    Jenkins Controller      |
|  (docker-compose, host)    |
| - Admin UI: 8080           |
| - JNLP port: 50000         |
+-------------+--------------+
              |
              | HTTP/WebSocket (JNLP)
              v
+----------------------------+
|      Jenkins Agent         |
|  (docker container)        |
| - Ejecuta jobs             |
| - Tiene kubectl + helm     |
| - Usa kubeconfig (~/.kube) |
| - Conectado a network:     |
|   jenkins-ci-net           |
+-------------+--------------+
              |
              | 
              | 
    +---------v---------+
    |       helm        |
    | - Genera YAML     |
    | - Llama a kubectl |
    +---------+---------+
              |
              v
    +---------v---------+
    |     kubectl       |
    | - Aplica recursos |
    | - Conecta API     |
    |   Server          |
    +---------+---------+
              |
              | HTTPS (IP: 192.168.64.1 / o la definida en kubeconfig)
              v
+----------------------------+
|   Kubernetes Cluster       |
| - API Server (192.168.64.1)|
| - Kubelets / nodos         |
| - etcd                      |
| - Pods / Deployments        |
+----------------------------+


```

Using only webSocket (no more legacy JNLP TCP port):
```

                           ┌──────────────────────────┐
                           │     Jenkins Controller   │
                           │  (docker-compose)        │
                           │                          │
                           │  UI:  http://:8080      │
                           │  WebSocket Agents: 8080 │
                           └─────────────┬────────────┘
                                         │
                                         │ HTTP + WebSocket
                                         │ (modo moderno)
                                         ▼
                           ┌──────────────────────────┐
                           │      Jenkins Agent       │
                           │   (docker container)     │
                           │                          │
                           │  - java agent.jar        │
                           │  - -webSocket            │
                           │  - kubectl               │
                           │  - helm                  │
                           │  - ~/.kube/config        │
                           └─────────────┬────────────┘
                                         │
                                         │
                          ┌──────────────┴──────────────┐
                          │                             │
                          ▼                             ▼
                  ┌───────────────┐             ┌───────────────┐
                  │     helm      │             │    kubectl     │
                  │               │────────────►│               │
                  │ genera YAML   │             │ aplica recursos│
                  └───────────────┘             └───────┬───────┘
                                                         │
                                                         │ HTTPS
                                                         │ kubeconfig
                                                         ▼
                                       ┌──────────────────────────┐
                                       │   Kubernetes Cluster     │
                                       │                          │
                                       │  API Server:             │
                                       │  host.docker.internal:6443│
                                       │                          │
                                       │  - etcd                  │
                                       │  - kubelets              │
                                       │  - pods                  │
                                       └──────────────────────────┘
```

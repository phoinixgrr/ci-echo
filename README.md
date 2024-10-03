
# CI Load Test

This project automates the deployment and load-testing of HTTP services with **GitHub Actions**, **KinD (Kubernetes in Docker)**, and **Helm**. Load testing is performed by utilizing the **Hey** benchmarking tool. This infrastructure provides also **Prometheus** and **Grafana** for monitoring resource utilization during load testing.

## How can I trigger a load-test?

Just create a PR. Upon submission, the pipeline will automatically trigger, deploy all required tooling, execute the load tests and generate performance results for the HTTP Echo service.

The pipeline will comment on the PR, including request performance statistics such as request time, latency, requests distribution, and links to Grafana-generated charts on CPU and Memory usage, during the length of the load-test.

Example:
```

Summary:
  Total:	60.0033 secs
  Slowest:	0.0463 secs
  Fastest:	0.0004 secs
  Average:	0.0046 secs
  Requests/sec:	2176.2648

  Total data:	522332 bytes
  Size/request:	4 bytes

Response time histogram:
  0.000 [1]	|
  0.005 [82169]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.010 [42502]	|■■■■■■■■■■■■■■■■■■■■■
  0.014 [4700]	|■■
  0.019 [819]	|
  0.023 [258]	|
  0.028 [78]	|
  0.033 [25]	|
  0.037 [14]	|
  0.042 [13]	|
  0.046 [4]	|


Latency distribution:
  10% in 0.0015 secs
  25% in 0.0026 secs
  50% in 0.0042 secs
  75% in 0.0060 secs
  90% in 0.0079 secs
  95% in 0.0094 secs
  99% in 0.0139 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0000 secs, 0.0004 secs, 0.0463 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0027 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0025 secs
  resp wait:	0.0045 secs, 0.0004 secs, 0.0462 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0030 secs

Status code distribution:
  [200]	130583 responses
```

![CPU Resource usage](/images/cpu_utilization.png)
![Memory Resource usage](/images/memory_utilization.png)


## Setup and Tooling

### 1. **Kubernetes cluster**

[Kind](https://github.com/kubernetes-sigs/kind) is used, to enable running Kubernetes in Docker containers. It is configured under `deployment/config/infrastructure/kind_config_ci.yaml` file. It has basic/default configuration. In addition we also install an [NGINX ingress controller](https://github.com/kubernetes/ingress-nginx) using [HELM](https://github.com/helm/helm), to be able to route traffic, into the Kind k8s cluster.

### 2. **HTTP Echo Service**

The [Http-Echo](https://github.com/hashicorp/http-echo) service, is a simple service that provides a customizable HTTP response. Helm is also used for installation, in which we have created a helm chart to deploy multiple http-echo installations. The Helm chart is located under the `chart/http-echo` directory and includes Kubernetes templates for deployment, service, and a unified ingress. It is configured under `deployment/config/application/values_ci.yaml` file.

### 3. **Load Testing with Hey**

The [Hey](https://github.com/rakyll/hey) tool simulates HTTP traffic to `foo.localhost` and `bar.localhost`, providing stats such as request durations and request rates.

### 4. **Monitoring with Prometheus & Grafana**

For Observability, [Prometheus](https://github.com/prometheus/prometheus) and [Grafana](https://github.com/grafana/grafana) are installed via Helm with basic configuration. Specifically to monitor resource consumption. Grafana dashboards are set up to demonstrate resource utilization during the load tests. It is configured under `deployment/config/observability/values_ci.yaml` file.

These metrics are used in conjuction with [grafana-image-renderer](https://github.com/grafana/grafana-image-renderer) to generate resource usage graphs, to be used in the GitHub comment.

### 5. **Orcherstrating the CI Load Test**

The following tasks are orcherstrated and automated using CI, with a GitHub Actions pipeline:
- Setting up the KinD cluster.
- Deploying the HTTP Echo services.
- Installing Prometheus and Grafana for metrics collection.
- Running load tests using `hey`.
- Generating Grafana screenshots of resource usage.
- Posting results and screenshots as a comment on the PR.

The pipeline configuration exists under `.github/workflow/CI.yaml` file.

Load Testing configuration is decoupled as Env Variables for easy config, along with other settings:
```
env:
  # Load-testing Configuration
  LOAD_TEST_DURATION: 5m
  LOAD_TEST_CONCURRENCY: 20
```

## Project Structure

```plaintext
.
├── .github
│   └── workflows
│       └── CI.yaml               # CI pipeline definition
├── .gitignore                    # Git ignore file
├── README.md                     # Project documentation (this file)
├── chart
│   └── http-echo                 # Helm chart for HTTP Echo application
│       ├── Chart.yaml            # Helm chart definition
│       ├── templates
│       │   ├── deployments.yaml  # Kubernetes deployment template for HTTP Echo
│       │   ├── ingresses.yaml    # Kubernetes ingress template for HTTP Echo
│       │   └── services.yaml     # Kubernetes service template for HTTP Echo
│       └── values.yaml           # Default values for the HTTP Echo Helm chart
├── deployment
│   └── config
│       ├── application
│       │   └── values_ci.yaml      # Values for HTTP Echo CI environment
│       ├── infrastructure
│       │   └── kind_config_ci.yaml # KinD configuration for CI environment
│       └── observability
│           └── values_ci.yaml      # Prometheus and Grafana configuration for CI environment
└── tests
    └── tests-http-deployments.bats # Bats tests for the HTTP Echo deployments
```

## Contributing

To contribute:
1. Fork the repository.
2. Create a branch.
3. Make your changes.
4. Open a PR.


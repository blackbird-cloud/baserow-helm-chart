# Blackbird Cloud Kubernetes Application Bootstrap

[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://www.blackbird.cloud)

A handy helm template for bootstraping k8s applications. This template creates a space for kubernetes applications and some small bootstrap components such as secrets, namespace, and ArgoCD application.

## Installing the Chart

```bash
$ helm repo add blackbird-cloud https://blackbird-cloud.github.io/helm-charts
$ helm install my-application blackbird-cloud/application-bootstrap
```
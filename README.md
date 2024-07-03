# Blackbird Cloud Helm Template

[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://www.blackbird.cloud)

A handy helm template for making more helm template

## Terraform Example
```hcl
module "my-application-bootstrap" {
  source  = "blackbird-cloud/deployment/helm"
  version = ">= 1.1.2"

  name        = "my-application"
  description = "my-application"
  namespace   = "xxxxxx"

  cleanup_on_fail = true
  force_update    = true
  wait            = true
  wait_for_jobs   = true

  values = [
    yamlencode({
      namespace: {
        name: "my-application"
      },
      role: {
        create: true
      }
    })
  ]
}
```


## About

We are [Blackbird Cloud](https://blackbird.cloud), Amsterdam based cloud consultancy, and cloud management service provider. We help companies build secure, cost efficient, and scale-able solutions.

Checkout our other :point\_right: [terraform modules](https://registry.terraform.io/namespaces/blackbird-cloud)

## Copyright

Copyright © 2017-2024 [Blackbird Cloud](https://www.blackbird.cloud)

data "terraform_remote_state" "state" {
  backend = "azurerm"

  config = {
      resource_group_name  = "terraform-infrastructure"
      storage_account_name = "arcroweterraformstate"
      container_name       = "tfstate"
      key                  = "local.terraform.tfstate"
      subscription_id      = "e1fec9f3-3d89-4113-8eaf-d8915babcf59"
      tenant_id            = "c894abff-2699-4efc-a196-8e1565ec8b93"
      client_id            = "cfb23b33-17f6-475c-b1b0-f3cfaeb5446a"
      #use_oidc             = true
  }
}

data "google_client_config" "default" {
}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.state.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.state.outputs.region
}

provider "kubernetes" {
  #host = azurerm_kubernetes_cluster.default.kube_config.0.host
  host = "https://${data.terraform_remote_state.state.outputs.kubernetes_cluster_host}"

  token = data.google_client_config.default.access_token
  
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)

  #client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  #client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  #cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_deployment" "helloapp" {
  metadata {
    name = "helloapp"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "helloapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "helloapp"
        }
      }

      spec {
        container {
          name  = "helloapp"
          image = "${data.terraform_remote_state.state.outputs.login_server}/helloapp:latest"
          #image = "arcroweterraformaaddemoregistry.azurecr.io/helloapp:latest"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name = "APP_ID"
            value = "${azuread_application.app-registration.application_id}"
          }

          env {
            name = "CLIENT_SECRET"
            value = "${azuread_application_password.client-secret.value}"
          }
        }

        #node_selector = {
        #  "beta.kubernetes.io/os" = "linux"
        #}
      }
    }
  }

  #depends_on = [
  #  null_resource.push
  #]
}

resource "kubernetes_service" "helloapp" {
  metadata {
    name = "helloapp"
  }

  spec {
    port {
      port        = 80
      target_port = 8080
    }

    selector = {
      app = "helloapp"
    }

    type = "LoadBalancer"
  }
}


output "lb_ip" {
  value = kubernetes_service.helloapp.status.0.load_balancer.0.ingress.0.ip
}

resource "kubernetes_ingress_v1" "managed_cert_ingress" {
  metadata {
    name = "managed-cert-ingress"

    annotations = {
      "kubernetes.io/ingress.class" = "gce"

      "kubernetes.io/ingress.global-static-ip-name" = "hashiconf-app-address"

      #"networking.gke.io/managed-certificates" = "managed-cert"
      "ingress.gcp.kubernetes.io/pre-shared-cert"   = google_compute_managed_ssl_certificate.managed-cert.name
    }
  }

  spec {
    default_backend {
      service {
        name = "helloapp"

        port {
          number = 80
        }
      }
    }
  }
  depends_on = [
    google_compute_managed_ssl_certificate.managed-cert
  ]
}

resource "google_compute_managed_ssl_certificate" "managed-cert" {
  name = "managed-cert"

  managed {
    domains = ["terraform-entra-demo.app"]
  }
}

resource "kubernetes_service_account" "kube-service-account" {
  metadata {
    name      = "kube-service-account"
    namespace = "sa-namspace"

    labels = {
      "azure.workload.identity/use" = "true"
    }

    annotations = {
      "azure.workload.identity/client-id" = azuread_application.app-registration.application_id
    }
  }
}

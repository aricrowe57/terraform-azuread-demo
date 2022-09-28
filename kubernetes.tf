provider "kubernetes" {
  host = azurerm_kubernetes_cluster.default.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_deployment" "azure_vote_back" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-back"
      }
    }

    template {
      metadata {
        labels = {
          app = "azure-vote-back"
        }
      }

      spec {
        container {
          name  = "azure-vote-back"
          image = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"

          port {
            name           = "redis"
            container_port = 6379
          }

          env {
            name  = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "azure_vote_back" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "azure-vote-back"
    }
  }
}

resource "kubernetes_deployment" "azure_vote_front" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-front"
      }
    }

    template {
      metadata {
        labels = {
          app = "azure-vote-front"
        }
      }

      spec {
        container {
          name  = "azure-vote-front"
          image = "${azurerm_container_registry.acr.login_server}/azure-vote-front:latest"

          port {
            container_port = 80
          }

          env {
            name  = "REDIS"
            value = "azure-vote-back"
          }

          resources {
            limits = {
              cpu = "500m"
            }

            requests = {
              cpu = "250m"
            }
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }

    strategy {
      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }

    min_ready_seconds = 5
  }

  depends_on = [
    null_resource.push
  ]
}

resource "kubernetes_service" "azure_vote_front" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
    port {
      port = 80
    }

    selector = {
      app = "azure-vote-front"
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.azure_vote_front.status.0.load_balancer.0.ingress.0.ip
}

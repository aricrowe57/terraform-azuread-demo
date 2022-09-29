provider "kubernetes" {
  host = azurerm_kubernetes_cluster.default.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
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
          image = "${azurerm_container_registry.acr.login_server}/helloapp:latest"

          port {
            container_port = 8080
          }

          env {
            name  = "PORT"
            value = "8080"
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

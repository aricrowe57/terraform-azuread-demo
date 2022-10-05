
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
      }
    }
  }
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

#resource "kubernetes_service_account" "kube-service-account" {
#  metadata {
#    name      = "kube-service-account"
#    namespace = "sa-namspace"
#
#    labels = {
#      "azure.workload.identity/use" = "true"
#    }
#
#    annotations = {
#      "azure.workload.identity/client-id" = azuread_application.app-registration.application_id
#    }
#  }
#}

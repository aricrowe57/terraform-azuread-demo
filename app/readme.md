Steps to reproduce on GCP:

Install gcloud sdk.

```bash
gcloud components install kubectl
```

Create GCP project.

Enable APIs:
- Artifact Registry
- Cloud Build
- Kubernetes Engine

Create cluster:

```bash
gcloud container clusters create-auto helloworld-gke \
  --region REGION
```

Create service:

```bash
kubectl apply -f service.yaml
```

Create static reserved IP address:

```bash
gcloud compute addresses create ADDRESS_NAME --global
```

Buy a domain on Google Domains.

Add a zone and a record set in GCP DNS:

```tf
resource "google_dns_managed_zone" "parent-zone" {
  name        = "sample-zone"
  dns_name    = "hashicorptest.com."
  description = "Test Description"
}

resource "google_dns_record_set" "default" {
  managed_zone = google_dns_managed_zone.parent-zone.name
  name         = "test-record.sample-zone.hashicorptest.com."
  type         = "A"
  rrdatas      = ["10.0.0.1", "10.1.0.1"]
  ttl          = 86400
}
```

Go back to Google Domains and configure DNS records with all four custom name servers from GCP DNS.

Create managed cert in cluster:

```bash
kubectl apply -f managed-cert.yaml
```

Update ingress manifest with IP address name, then create ingress with TLS termination using managed cert:

```bash
kubectl apply -f ingress.yaml
```

Wait a long time for the load balancer to be created and the managed certificate to be provisioned and become active. Check for status with:

```bash
kubectl describe managedcertificate managed-cert
```

Create container repo:

```bash
gcloud artifacts repositories create hello-repo \
    --project=PROJECT_ID \
    --repository-format=docker \
    --location=REGION \
    --description="Docker repository"
```

Register app in AAD. Copy config values into `aad-config.json`.

Build image and push to container registry:

```bash
gcloud builds submit \
  --tag REGION-docker.pkg.dev/PROJECT_ID/hello-repo/helloworld-gke .
```

Update deployment manifest with correct pointer to container image. Then trigger deployment:

```bash
kubectl apply -f deployment.yaml
```

Wait for deployment to complete. Check status with:

```bash
kubectl get deployments
```
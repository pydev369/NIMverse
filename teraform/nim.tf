# Kubernetes ConfigMap for NVIDIA NIM configuration
resource "kubernetes_config_map" "nim_config" {
  metadata {
    name      = "nim-config"
    namespace = "nvidia-nim"
  }

  data = {
    "nim-config.yaml" = <<-EOT
    inference:
      model: "nvidia/Llama-3.1-Nemotron-Nano-8B-v1"
      retriever: "nvidia/llama-3_2-nemoretriever-300m-embed-v1"
      precision: "bfloat16"
      max_tokens: 1024
      temperature: 0.7
    storage:
      s3_bucket: "${aws_s3_bucket.nvidia_models.bucket}"
      s3_region: "${var.aws_region}"
    EOT
  }

  depends_on = [aws_eks_node_group.gpu_nodes]
}

# Kubernetes Namespace for NVIDIA NIM
resource "kubernetes_namespace" "nvidia_nim" {
  metadata {
    name = "nvidia-nim"
    labels = {
      purpose = "nvidia-nim-inference"
    }
  }

  depends_on = [aws_eks_node_group.gpu_nodes]
}

# NVIDIA Device Plugin for Kubernetes
resource "kubernetes_daemonset" "nvidia_device_plugin" {
  metadata {
    name      = "nvidia-device-plugin"
    namespace = "nvidia-nim"
  }

  spec {
    selector {
      match_labels = {
        name = "nvidia-device-plugin"
      }
    }

    template {
      metadata {
        labels = {
          name = "nvidia-device-plugin"
        }
      }

      spec {
        toleration {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "nvidia-device-plugin"
          image = "nvcr.io/nvidia/k8s-device-plugin:v0.14.1"

          security_context {
            privileged = true
          }

          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }
        }

        volume {
          name = "device-plugin"
          host_path {
            path = "/var/lib/kubelet/device-plugins"
          }
        }

        node_selector = {
          "node.kubernetes.io/instance-type" = "g4dn.xlarge"
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.nvidia_nim]
}
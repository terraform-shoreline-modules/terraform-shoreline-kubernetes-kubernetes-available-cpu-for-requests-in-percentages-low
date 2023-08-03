resource "shoreline_notebook" "kubernetes_cpu_availability_low" {
  name       = "kubernetes_cpu_availability_low"
  data       = file("${path.module}/data/kubernetes_cpu_availability_low.json")
  depends_on = [shoreline_action.invoke_get_pod_cpu_usage,shoreline_action.invoke_cpu_usage_check,shoreline_action.invoke_update_nodegroup,shoreline_action.invoke_pods_cpu_threshold_remediation]
}

resource "shoreline_file" "get_pod_cpu_usage" {
  name             = "get_pod_cpu_usage"
  input_file       = "${path.module}/data/get_pod_cpu_usage.sh"
  md5              = filemd5("${path.module}/data/get_pod_cpu_usage.sh")
  description      = "Resource limits were not set properly in containers, leading to overconsumption of CPU resources."
  destination_path = "/agent/scripts/get_pod_cpu_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cpu_usage_check" {
  name             = "cpu_usage_check"
  input_file       = "${path.module}/data/cpu_usage_check.sh"
  md5              = filemd5("${path.module}/data/cpu_usage_check.sh")
  description      = "Inadequate resource allocation by the Kubernetes cluster, leading to insufficient CPU resources being available."
  destination_path = "/agent/scripts/cpu_usage_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_nodegroup" {
  name             = "update_nodegroup"
  input_file       = "${path.module}/data/update_nodegroup.sh"
  md5              = filemd5("${path.module}/data/update_nodegroup.sh")
  description      = "Increase the resources allocated to the Kubernetes cluster to avoid CPU contention."
  destination_path = "/agent/scripts/update_nodegroup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "pods_cpu_threshold_remediation" {
  name             = "pods_cpu_threshold_remediation"
  input_file       = "${path.module}/data/pods_cpu_threshold_remediation.sh"
  md5              = filemd5("${path.module}/data/pods_cpu_threshold_remediation.sh")
  description      = "Identify and terminate idle or unused containers to free up resources."
  destination_path = "/agent/scripts/pods_cpu_threshold_remediation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_pod_cpu_usage" {
  name        = "invoke_get_pod_cpu_usage"
  description = "Resource limits were not set properly in containers, leading to overconsumption of CPU resources."
  command     = "`chmod +x /agent/scripts/get_pod_cpu_usage.sh && /agent/scripts/get_pod_cpu_usage.sh`"
  params      = ["DEPLOYMENT","NAMESPACE"]
  file_deps   = ["get_pod_cpu_usage"]
  enabled     = true
  depends_on  = [shoreline_file.get_pod_cpu_usage]
}

resource "shoreline_action" "invoke_cpu_usage_check" {
  name        = "invoke_cpu_usage_check"
  description = "Inadequate resource allocation by the Kubernetes cluster, leading to insufficient CPU resources being available."
  command     = "`chmod +x /agent/scripts/cpu_usage_check.sh && /agent/scripts/cpu_usage_check.sh`"
  params      = ["CPU_THRESHOLD","DEPLOYMENT","NAMESPACE"]
  file_deps   = ["cpu_usage_check"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_usage_check]
}

resource "shoreline_action" "invoke_update_nodegroup" {
  name        = "invoke_update_nodegroup"
  description = "Increase the resources allocated to the Kubernetes cluster to avoid CPU contention."
  command     = "`chmod +x /agent/scripts/update_nodegroup.sh && /agent/scripts/update_nodegroup.sh`"
  params      = ["NODE_COUNT","NODE_INSTANCE_TYPE","CLUSTER_NAME"]
  file_deps   = ["update_nodegroup"]
  enabled     = true
  depends_on  = [shoreline_file.update_nodegroup]
}

resource "shoreline_action" "invoke_pods_cpu_threshold_remediation" {
  name        = "invoke_pods_cpu_threshold_remediation"
  description = "Identify and terminate idle or unused containers to free up resources."
  command     = "`chmod +x /agent/scripts/pods_cpu_threshold_remediation.sh && /agent/scripts/pods_cpu_threshold_remediation.sh`"
  params      = ["DEPLOYMENT","NAMESPACE"]
  file_deps   = ["pods_cpu_threshold_remediation"]
  enabled     = true
  depends_on  = [shoreline_file.pods_cpu_threshold_remediation]
}


# Kubernetes JSON Schemas

```bash
wget https://raw.githubusercontent.com/sabre1041/k8s-manifest-validation/main/scripts/build_schema.py -O /tmp/build_schema.py
pip3 install -r https://raw.githubusercontent.com/sabre1041/k8s-manifest-validation/main/scripts/requirements.txt

python3 /tmp/build_schema.py \
    --destination "./" \
    --url $(oc whoami --show-server) --token $(oc whoami -t) --strict STRICT
```

## Notes

The following API resources do not have valid OpenAPI specifications:

- dev.tekton.dashboard.v1alpha1.Extension
- dev.tekton.operator.v1alpha1.OpenShiftPipelinesAsCode
- dev.tekton.operator.v1alpha1.TektonAddon
- dev.tekton.operator.v1alpha1.TektonChain
- dev.tekton.operator.v1alpha1.TektonConfig
- dev.tekton.operator.v1alpha1.TektonDashboard
- dev.tekton.operator.v1alpha1.TektonHub
- dev.tekton.operator.v1alpha1.TektonInstallerSet
- dev.tekton.operator.v1alpha1.TektonPipeline
- dev.tekton.operator.v1alpha1.TektonResult
- dev.tekton.operator.v1alpha1.TektonTrigger
- dev.tekton.pipelinesascode.v1alpha1.Repository
- dev.tekton.resolution.v1alpha1.ResolutionRequest
- dev.tekton.resolution.v1beta1.ResolutionRequest
- dev.tekton.triggers.v1alpha1.ClusterInterceptor
- dev.tekton.triggers.v1alpha1.ClusterTriggerBinding
- dev.tekton.triggers.v1alpha1.EventListener
- dev.tekton.triggers.v1alpha1.Interceptor
- dev.tekton.triggers.v1alpha1.Trigger
- dev.tekton.triggers.v1alpha1.TriggerBinding
- dev.tekton.triggers.v1alpha1.TriggerTemplate
- dev.tekton.triggers.v1beta1.ClusterTriggerBinding
- dev.tekton.triggers.v1beta1.EventListener
- dev.tekton.triggers.v1beta1.Trigger
- dev.tekton.triggers.v1beta1.TriggerBinding
- dev.tekton.triggers.v1beta1.TriggerTemplate
- dev.tekton.v1.Pipeline
- dev.tekton.v1.PipelineRun
- dev.tekton.v1.Task
- dev.tekton.v1.TaskRun
- dev.tekton.v1alpha1.PipelineResource
- dev.tekton.v1alpha1.Run
- dev.tekton.v1alpha1.VerificationPolicy
- dev.tekton.v1beta1.ClusterTask
- dev.tekton.v1beta1.CustomRun
- dev.tekton.v1beta1.Pipeline
- dev.tekton.v1beta1.PipelineRun
- dev.tekton.v1beta1.Task
- dev.tekton.v1beta1.TaskRun

## REF

- <https://github.com/sabre1041/k8s-manifest-validation>

# Kubernetes JSON Schemas

```bash
wget https://raw.githubusercontent.com/sabre1041/k8s-manifest-validation/main/scripts/build_schema.py -O ./build_schema.py

python3 -m venv .venv
source .venv/bin/activate

pip3 install setuptools==69.2.0 && pip3 install "cython<3.0.0" wheel && pip3 install pyyaml==5.4.1 --no-build-isolation
pip3 install -r https://raw.githubusercontent.com/sabre1041/k8s-manifest-validation/main/scripts/requirements.txt

# python3 build_schema.py \
#     --destination "./" \
#     --url $(oc whoami --show-server) --token $(oc whoami -t) --strict STRICT

# Temporary workaround, need to figure out how to use openapi spec to generate.
#### Vendor Latest K8s CRDs
bash ./k8s.sh

#### Custom CRDS
wget https://raw.githubusercontent.com/yannh/kubeconform/refs/heads/master/scripts/openapi2jsonschema.py
chmod +x openapi2jsonschema.py

# Custom Files
cp custom_crds/oauthclient-oauth.openshift.io-v1.json custom-standalone-strict
export FILENAME_FORMAT='{kind}-{fullgroup}-{version}'
./openapi2jsonschema.py custom_crds/groups.yaml
mv group-user.openshift.io-v1.json custom-standalone-strict
export FILENAME_FORMAT='{kind}-{fullgroup}-{version}'
./openapi2jsonschema.py custom_crds/users.yaml
mv user-user.openshift.io-v1.json custom-standalone-strict
./openapi2jsonschema.py https://raw.githubusercontent.com/openshift/router/refs/heads/master/deploy/route_crd.yaml
mv route-route.openshift.io-v1.json custom-standalone-strict

# Dumping From a Cluster (Do not dump from a cluster that doesn't have the latest versions of the stuff installed OCP + Addons, generally sb0100 is the newest)
cd custom-standalone-strict
kubectl get crd -A -o yaml > dump.yaml
export FILENAME_FORMAT='{kind}-{fullgroup}-{version}'
../openapi2jsonschema.py dump.yaml
rm dump.yaml
cd ../

# Fixing Bad CRD
yq eval '.properties.metadata.additionalProperties = true' -i ./custom-standalone-strict/hyperconverged-hco.kubevirt.io-v1beta1.json
yq eval '.properties.metadata.additionalProperties = true' -i ./custom-standalone-strict/egressfirewall-k8s.ovn.org-v1.json
yq eval '.properties.metadata.additionalProperties = true' -i ./custom-standalone-strict/logfilemetricexporter-logging.openshift.io-v1alpha1.json

# Importing Some Other CRD Manually
kubectl get crd myCRD.yaml > myCRD.yaml # If needing to pull from a cluster
# Grab CRD from where it needs to be grabbed from.

export FILENAME_FORMAT='{kind}-{fullgroup}-{version}'
./openapi2jsonschema.py myCRD.yaml
mv myCRD.json custom-standalone-strict
rm myCRD.yaml
```

```bash
    ./kubeconform -n 1 -verbose --summary -strict -debug \
      -schema-location="../kubernetes-json-schema/master-standalone-strict/{{.ResourceKind}}-{{.Group}}-{{.ResourceAPIVersion}}.json" \
      -schema-location 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/{{.ResourceKind}}{{.KindSuffix}}.json' \
      -schema-location "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json" \
      -output text "${DIR}" | grep -v "is valid"
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
````

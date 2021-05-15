# This will copy local state for the pipeline state resources (folders / projects / GCS) by pointing to GCS and then doing a terragrunt apply
#cp templates/bootstrap/bootstrap-state-nonp.hcl bootstrap/
#cp templates/bootstrap/bootstrap-state-prod.hcl bootstrap/

#sleep 2;

targets=(
  resources/platform/folders/root/
  resources/platform/projects/terragrunt-states/
  resources/platform/projects/terragrunt-states/common/multi-region/gcs-platform-1/
  )
for state_path in "${targets[@]}"
do
  terragrunt plan --terragrunt-working-dir "${state_path}" --terragrunt-log-level debug --terragrunt-non-interactive
done;

# Reminder:  to run this Terraform code successfully, 
# you must be logged into the Azure CLI as an Entra principal that has adequate permissions to manipulate 
# both Azure and Entra.

Push-Location("$PsScriptRoot")

terraform apply `
    -var entra_tenant_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id', 'User'))" `
    -var az_sub_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))" `
    -var workload_nickname="$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))-mcplimit" `
    -input=false `
    -auto-approve

Pop-Location
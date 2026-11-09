Push-Location "$PsScriptRoot"

# # https://katiekodes.com/package-consumption-starter/#installation-from-lockfiles
# # BEGIN:  uncomment me when trying to upgrade the package-lock.json in this repo
# # npm install --save-dev --save-exact --min-release-age=7 '@modelcontextprotocol/sdk' '@types/node' 'typescript' 'vitest' # FIRST TIME
# # REMAINING TIMES BELOW
# npm update --package-lock-only --save-exact --min-release-age=7
# npm audit
# npm audit signatures
# # END:  uncomment me when trying to upgrade the package-lock.json in this repo

# # BEGIN:  Run if haven't yet
# npm ci
# # END:  Run if haven't yet

$terraform_root = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'AA-tf'))
$gateway_scope = 'https://azure-api.net/aigateway/Data.All'
$gateway_token = $null
try {
    $gateway_token = az account get-access-token --scope $gateway_scope --query accessToken --output tsv
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gateway_token)) {
        throw "Could not acquire the AI Gateway token. Sign in with consent for '$gateway_scope' using az login --scope '$gateway_scope'."
    }
    $gateway_token = $gateway_token.Trim()

    $gateway_url = (terraform "-chdir=$terraform_root" output -raw mcp_server_gateway_url).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read mcp_server_gateway_url from Terraform output."
    }
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', $gateway_url, 'Process')
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BEARER_TOKEN', $gateway_token, 'Process')
    npm run test
}
finally {
    $terraform_root = $null
    $gateway_url = $null
    $gateway_scope = $null
    $gateway_token = $null
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', $null, 'Process')
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BEARER_TOKEN', $null, 'Process')
    Pop-Location
}
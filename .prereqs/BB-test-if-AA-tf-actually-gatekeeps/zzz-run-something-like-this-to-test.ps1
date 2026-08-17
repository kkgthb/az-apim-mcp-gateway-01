Push-Location("$PsScriptRoot")

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

# BEGIN:  actually run the smoke test
$tfstate_file = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'AA-tf', 'terraform.tfstate'))
Try {
    $apim_name = (jq -r '.outputs.apim_name.value' $tfstate_file)
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', "https://$apim_name.azure-api.net/mslearn-mcp/mcp", 'Process')
    [Environment]::GetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL')
    npm run test
}
Finally {
    $tfstate_file = $null
    $apim_name = $null
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', $null, 'Process')
}
# END:  actually run the smoke test

Pop-Location
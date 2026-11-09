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
$tfstate_file_parent_folder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '..', 'AA-tf'))
Try {
    $gateway_url = (terraform "-chdir=$tfstate_file_parent_folder" output -raw 'mcp_server_gateway_url').Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read mcp_server_gateway_url from Terraform output."
    }
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', $gateway_url, 'Process')
    Write-Host "Gateway URL is now set to: $([Environment]::GetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL'))"
    npm run test
}
Finally {
    $tfstate_file_parent_folder = $null
    $gateway_url = $null
    [Environment]::SetEnvironmentVariable('MSLEARN_MCP_GATEKEPT_BASE_URL', $null, 'Process')
}
# END:  actually run the smoke test

Pop-Location
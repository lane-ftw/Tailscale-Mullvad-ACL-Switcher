# Set OAuth client ID and client secret
$clientID = "your_client_ID"
$clientSecret = "your_client_secret"

# Predefined IP addresses
$defaultIPAddress1 = "100.100.100.100"
$defaultIPAddress2 = "101.101.101.101"

# Log start of the script
Write-Output "Starting Tailscale ACL update script..."

# Send request to obtain an access token
Write-Output "Requesting access token..."
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://api.tailscale.com/api/v2/oauth/token" -Body @{
    client_id = $clientID
    client_secret = $clientSecret
}
Write-Output "Token response: $($tokenResponse | ConvertTo-Json)"

# Extract access token from the response
$accessToken = $tokenResponse.access_token
Write-Output "Access token obtained: $accessToken"

# Function to update ACL policy
function Update-ACL {
    param (
        [string]$oldIP,
        [string]$newIP
    )

    Write-Output "Updating ACL policy for IP address: $oldIP -> $newIP"

    # Retrieve current ACL policy
    $aclPolicyResponse = Invoke-RestMethod -Method Get -Uri "https://api.tailscale.com/api/v2/tailnet/-/acl" -Headers @{
        Authorization = "Bearer $accessToken"
    }
#    Write-Output "ACL policy response: $($aclPolicyResponse | ConvertTo-Json)"

    # Modify ACL policy
    $modifiedPolicy = $aclPolicyResponse -replace $oldIP, $newIP

    # Send modified ACL policy back to Tailscale
    $response = Invoke-RestMethod -Method Post -Uri "https://api.tailscale.com/api/v2/tailnet/-/acl" -Headers @{
        Authorization = "Bearer $accessToken"
        "Content-Type" = "application/json"
    } -Body $modifiedPolicy
#    Write-Output "ACL update response: $($response | ConvertTo-Json)"

    # Log end of the function
    Write-Output "ACL update completed."
}

# Display options to the user
Write-Output "Choose an option:"
Write-Output "1. Use $defaultIPAddress1 as old IP and $defaultIPAddress2 as new IP"
Write-Output "2. Use $defaultIPAddress2 as old IP and $defaultIPAddress1 as new IP"
$choice = Read-Host "Enter your choice (1 or 2)"

switch ($choice) {
    1 {
        $oldIPAddress = $defaultIPAddress1
        $newIPAddress = $defaultIPAddress2
    }
    2 {
        $oldIPAddress = $defaultIPAddress2
        $newIPAddress = $defaultIPAddress1
    }
    default {
        Write-Output "Invalid choice. Exiting."
        exit 1
    }
}

# Call the Update-ACL function with the chosen IP addresses
Update-ACL $oldIPAddress $newIPAddress

# Pause to keep PowerShell window open
#pause

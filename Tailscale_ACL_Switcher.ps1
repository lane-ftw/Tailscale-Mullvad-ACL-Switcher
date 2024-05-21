# Set OAuth client ID and client secret
$clientID = "your_client_id"
$clientSecret = "your_client_secret"

# Log start of the script
Write-Output "Starting Tailscale ACL update script..."

try {
    # Send request to obtain an access token
    Write-Output "Requesting access token..."
    $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://api.tailscale.com/api/v2/oauth/token" -Body @{
        client_id = $clientID
        client_secret = $clientSecret
    }

    # Extract access token from the response
    $accessToken = $tokenResponse.access_token
    Write-Output "Access token obtained: $accessToken"

    # Set IP address you want to update
    $oldIPAddress = "current_IP_in_ACL"
    $newIPAddress = "IP_wants_Mullvad_access"
    Write-Output "Updating ACL policy for IP address: $oldIPAddress -> $newIPAddress"

    # Retrieve current ACL policy
    try {
        $aclPolicyResponse = Invoke-RestMethod -Method Get -Uri "https://api.tailscale.com/api/v2/tailnet/-/acl" -Headers @{
            Authorization = "Bearer $accessToken"
        }
    }
    catch {
        Write-Host "Error retrieving ACL policy: $_"
    }

    # Log retrieved ACL policy
#####Write-Output "Retrieved ACL policy:"
#####Write-Output $aclPolicyResponse

    # Modify ACL policy 
    $modifiedPolicy = $aclPolicyResponse -replace $oldIPAddress, $newIPAddress

    # Send modified ACL policy back to Tailscale
    try {
        $response = Invoke-RestMethod -Method Post -Uri "https://api.tailscale.com/api/v2/tailnet/-/acl" -Headers @{
            Authorization = "Bearer $accessToken"
            "Content-Type" = "application/json"
        } -Body $modifiedPolicy
        Write-Output "ACL update response:"
        Write-Output $response
    }
    catch {
        Write-Host "Error sending updated ACL policy: $_"
    }

    # Log end of the script
    Write-Output "ACL update completed."
}
catch {
    # Log any errors that occur
    Write-Output "An error occurred: $_"
}

	# Pause to keep PowerShell window open
#####pause


###POWERSHELL###
# Set OAuth client ID and client secret
$clientID = "your_client_ID"
$clientSecret = "your_client_secret"

# Define IP address pairs with names
$ipPairs = @{
    "1" = @{
        Name = "OPTION 1"
        OldIPAddress = "100.100.100.100"
        NewIPAddress = "101.101.101.101"
    }
    "2" = @{
        Name = "OPTION 2"
        OldIPAddress = "101.101.101.101"
        NewIPAddress = "100.100.100.100"
    }
}

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
    #Write-Output "ACL policy response: $($aclPolicyResponse | ConvertTo-Json)"

    # Modify ACL policy
    $modifiedPolicy = $aclPolicyResponse -replace $oldIP, $newIP

    # Send modified ACL policy back to Tailscale
    $response = Invoke-RestMethod -Method Post -Uri "https://api.tailscale.com/api/v2/tailnet/-/acl" -Headers @{
        Authorization = "Bearer $accessToken"
        "Content-Type" = "application/json"
    } -Body $modifiedPolicy
    Write-Output "ACL update response: $($response | ConvertTo-Json)"

    # Log end of the function
    Write-Output "ACL update completed."
}

# Display options to the user
Write-Output "Choose an option:"
$ipPairs.GetEnumerator() | ForEach-Object {
    Write-Output "$($_.Key). Use $($_.Value.Name) ($($_.Value.OldIPAddress) -> $($_.Value.NewIPAddress))"
} | Sort-Object { [int] $_.Key } -Descending
$choice = Read-Host "Enter your choice"

if ($ipPairs.ContainsKey($choice)) {
    $selectedIPs = $ipPairs[$choice]
    $oldIPAddress = $selectedIPs.OldIPAddress
    $newIPAddress = $selectedIPs.NewIPAddress
} else {
    Write-Output "Invalid choice. Exiting."
    exit 1
}

# Call the Update-ACL function with the chosen IP addresses
Update-ACL $oldIPAddress $newIPAddress

# Pause to keep PowerShell window open
#pause

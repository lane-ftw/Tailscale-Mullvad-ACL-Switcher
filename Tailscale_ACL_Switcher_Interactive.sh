#!/bin/bash

###NEEDS JQ TO RUN###

# Set OAuth client ID and client secret
clientID="your_client_ID"
clientSecret="your_client_secret"

# Predefined IP addresses
defaultIPAddress1="100.100.100.100"
defaultIPAddress2="101.101.101.101"

# Log start of the script
echo "Starting Tailscale ACL update script..."

# Send request to obtain an access token
echo "Requesting access token..."
tokenResponse=$(curl -s -X POST -d "client_id=$clientID" -d "client_secret=$clientSecret" "https://api.tailscale.com/api/v2/oauth/token")
echo "Token response: $tokenResponse"

# Extract access token from the response
accessToken=$(echo "$tokenResponse" | jq -r '.access_token')
echo "Access token obtained: $accessToken"

# Function to update ACL policy
updateACL() {
    local oldIP=$1
    local newIP=$2

    echo "Updating ACL policy for IP address: $oldIP -> $newIP"

    # Retrieve current ACL policy
    aclPolicyResponse=$(curl -s -X GET -H "Authorization: Bearer $accessToken" "https://api.tailscale.com/api/v2/tailnet/-/acl")
    #echo "ACL policy response: $aclPolicyResponse"

    # Modify ACL policy
    modifiedPolicy=$(echo "$aclPolicyResponse" | sed "s/$oldIP/$newIP/g")

    # Send modified ACL policy back to Tailscale
    response=$(curl -s -X POST -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json" -d "$modifiedPolicy" "https://api.tailscale.com/api/v2/tailnet/-/acl")
    #echo "ACL update response: $response"

    # Log end of the function
    echo "ACL update completed."
}

# Display options to the user
echo "Choose an option:"
echo "1. Use $defaultIPAddress1 as old IP and $defaultIPAddress2 as new IP"
echo "2. Use $defaultIPAddress2 as old IP and $defaultIPAddress1 as new IP"
read -rp "Enter your choice: " choice

case $choice in
    1)
        oldIPAddress="$defaultIPAddress1"
        newIPAddress="$defaultIPAddress2"
        ;;
    2)
        oldIPAddress="$defaultIPAddress2"
        newIPAddress="$defaultIPAddress1"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Call the updateACL function with the chosen IP addresses
updateACL "$oldIPAddress" "$newIPAddress"

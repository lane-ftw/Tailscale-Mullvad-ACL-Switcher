#!/bin/bash

###NEEDS JQ TO RUN###

# Set OAuth client ID and client secret
clientID="your_client_ID"
clientSecret="your_client_secret"

# Log start of the script
echo "Starting Tailscale ACL update script..."

# Send request to obtain an access token
echo "Requesting access token..."
tokenResponse=$(curl -s -X POST -d "client_id=$clientID" -d "client_secret=$clientSecret" "https://api.tailscale.com/api/v2/oauth/token")
echo "Token response: $tokenResponse"

# Extract access token from the response
accessToken=$(echo "$tokenResponse" | jq -r '.access_token')
echo "Access token obtained: $accessToken"

# Set IP address you want to update
oldIPAddress="current_IP_in_ACL"
newIPAddress="IP_wants_Mullvad_access"
echo "Updating ACL policy for IP address: $oldIPAddress -> $newIPAddress"

# Retrieve current ACL policy
aclPolicyResponse=$(curl -s -X GET -H "Authorization: Bearer $accessToken" "https://api.tailscale.com/api/v2/tailnet/-/acl")
#echo "ACL policy response: $aclPolicyResponse"

# Modify ACL policy
modifiedPolicy=$(echo "$aclPolicyResponse" | sed "s/$oldIPAddress/$newIPAddress/g")

# Send modified ACL policy back to Tailscale
response=$(curl -s -X POST -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json" -d "$modifiedPolicy" "https://api.tailscale.co>#echo "ACL update response: $response"

# Log end of the script
echo "ACL update completed."

# Pause to keep the terminal window open
#read -rp "Press Enter to continue..."

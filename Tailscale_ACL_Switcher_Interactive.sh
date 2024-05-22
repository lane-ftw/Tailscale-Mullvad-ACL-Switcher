#!/bin/bash

###NEEDS JQ TO RUN###

# Set OAuth client ID and client secret
clientID="your_client_ID"
clientSecret="your_client_secret"

# Define IP address pairs with names
declare -A ipPairs=(
    [1]="OPTION 1 (100.100.100.100 -> 101.101.101.101)"
    [2]="OPTION 2 (101.101.101.101 -> 100.100.100.100)"
)

# Log start of the script
echo "Starting Tailscale ACL update script..."

# Function to obtain an access token
getAccessToken() {
    echo "Requesting access token..."
    tokenResponse=$(curl -s -X POST -d "client_id=$clientID" -d "client_secret=$clientSecret" "https://api.tailscale.com/api/v2/oauth/token")
    echo "Token response: $tokenResponse"

    # Extract access token from the response
    accessToken=$(echo "$tokenResponse" | jq -r '.access_token')
    echo "Access token obtained: $accessToken"
}

# Function to update ACL policy
updateACL() {
    local oldIP=$1
    local newIP=$2

    echo "Updating ACL policy for IP address: $oldIP -> $newIP"

    # Retrieve current ACL policy
    aclPolicyResponse=$(curl -s -X GET -H "Authorization: Bearer $accessToken" "https://api.tailscale.com/api/v2/tailnet/-/acl")

    # Modify ACL policy
    modifiedPolicy=$(echo "$aclPolicyResponse" | sed "s/$oldIP/$newIP/g")

    # Send modified ACL policy back to Tailscale
    response=$(curl -s -X POST -H "Authorization: Bearer $accessToken" -H "Content-Type: application/json" -d "$modifiedPolicy" "https://api.tailscale.com/api/v2/tailnet/-/acl")

    # Log end of the function
    echo "ACL update completed."
}

# Call the function to obtain an access token
getAccessToken

# Display options to the user
echo "Choose an option:"
for key in $(seq 1 ${#ipPairs[@]}); do
    ip_pair="${ipPairs[$key]}"
    echo "$key. ${ip_pair%)*})"  # Add the closing parenthesis
done

read -rp "Enter your choice: " choice

# Validate user input and set IP addresses accordingly
if [[ -z "${ipPairs[$choice]}" ]]; then
    echo "Invalid choice. Exiting."
    exit 1
fi

# Extract old and new IP addresses from the chosen option
ip_pair="${ipPairs[$choice]}"
#echo "Selected IP pair: $ip_pair"
# Extracting old IP address
oldIPAddress=$(echo "$ip_pair" | awk -F '[()]|->' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
# Extracting new IP address
newIPAddress=$(echo "$ip_pair" | awk -F '[()]|->' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
#echo "Extracted old IP: $oldIPAddress, new IP: $newIPAddress"

# Call the updateACL function with the chosen IP addresses
#echo "Calling updateACL function with old IP: $oldIPAddress and new IP: $newIPAddress"
updateACL "$oldIPAddress" "$newIPAddress"

# Pause to keep the terminal window open
#read -rp "Press Enter to continue..."

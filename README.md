# Tailscale-Mullvad-ACL-Switcher
Switches devices in your Tailscale ACL to use Mullvad nodes without having to use the admin panel, using OAuth and the Tailscale API.

Assumptions: You have a Mullvad subscription through Tailscale. You can create an OAuth client with permissions to read/write to your tailnet's ACL. You have an ACL with entries for devices to use Mullvad exit nodes.

<b><u>HOW TO</u></b>:</br>
Download a script from ^^^ up there ^^^

Go to https://login.tailscale.com/admin/machines and note the IPs of the machines you want to switch. <s>I assume this would work with device names/MagicDNS, but haven't tried anything other than IPs yet.</s> Only works with IPV4/IPV6 addresses, Tailscale ACL limitation.  

Go to https://login.tailscale.com/admin/settings/oauth and create an Oauth client with at least ACL read/write access.

Copy the client ID and Secret, and in the script, replace `$clientID = "your_client_id" $clientSecret = "your_client_secret"` with the ID and Secret you just generated. MAKE SURE TO KEEP THE QUOTES.


MAKE SURE YOU ALREADY HAVE DEVICES IN YOUR ACL, OR THIS SCRIPT WILL DO NOTHING. They should look like this under `"nodeAttrs": [`
I like to comment mine, you don't have to.

```
// machine 1
{"target": ["100.100.100.100"], "attr": ["mullvad"]},
// machine 2
{"target": ["101.101.101.101"], "attr": ["mullvad"]},
// machine 3
{"target": ["102.102.102.102"], "attr": ["mullvad"]},
```

<b>[NON INTERACTIVE VERSION]</b> Copy the IP of the machine currently in the ACL. Copy the IP of the machine to be put into the ACL (wants mullvad access). In the script replace them in  `$oldIPAddress = "current_IP_in_ACL" $newIPAddress = "IP_wants_Mullvad_access"` MAKE SURE TO KEEP THE QUOTES</br>
<b>[INTERACTIVE VERSION]</b> Copy the IP of the machine currently in the ACL. Copy the IP of the machine to be put into the ACL (wants mullvad access). In the script replace them in  `    [1]="OPTION 1 (100.100.100.100 -> 101.101.101.101)" [2]="OPTION 2 (101.101.101.101 -> 100.100.100.100)"` MAKE SURE TO KEEP THE QUOTES</br>

Save the script.</br>
<b>[NON INTERACTIVE VERSION]</b> Make a copy of the script with the values of  `$oldIPAddress` and `$newIPAddress` switched around, so you can change back and forth.</br>
<b>[BASH]</b> install `jq`, don't forget to `chmod +x` your script!</br>
Run the script.</br>
<b>[INTERACTIVE VERSION]</b> Select what IP you're coming from/going to.</br>
If you'd like some basic logging, uncomment the lines:</br>
<b>[POWERSHELL]</b>
```
#####Write-Output "Retrieved ACL policy:"
#####Write-Output $aclPolicyResponse
#####pause
```
<b>[BASH]</b>
```
#echo "ACL policy response: $aclPolicyResponse"
#echo "ACL update response: $response"
#read -rp "Press Enter to continue..."
```

Notes:</br>
<s>Currently you need two versions of the script, as it's only one way. IE: I have one script that changes from my computer to my phone, and one that changes from my phone to my computer, I'll try to get a version that doesn't need two copies.</br>
Can only change 1 IP per script, will work on getting multiple in the same script.</s></br>
Interactive version now up! Can set names for each pair.</br>
You have to restart tailscale to get it to recognize the ACL changes.</br>
Bash version needs `jq` installed to parse JSON.</br>
Android app soon?

# Purpose 

[Script|provisioning.sh] to quickly provision a stubbed backend service on GCP with a private IP address, to be referenced as a target via its host name from an Apigee X instance in the same project using private DNS. 

# Get Started

Clone the repo, then run the following commands.

```
chmod +x provision.sh
./provision.sh myprojectid mynetwork
```

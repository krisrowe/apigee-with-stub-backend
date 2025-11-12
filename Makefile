include .env

.PHONY: all get-token get-apigee-host invoke-proxy show-curl-command find-dallas-stations export-proxy

all: invoke-proxy

get-token:
	@echo "Generating GCP access token..."
	@gcloud auth print-access-token > .gcp_token
	@echo "GCP access token generated and saved to .gcp_token"

get-apigee-host: get-token
	@echo "Getting Apigee host details..."
	@APIGEE_TOKEN=$$(cat .gcp_token); \
	APIGEE_ORG_NAME=$$(grep -E '^GCP_PROJECT_ID=' .env | cut -d '=' -f2); \
	APIGEE_ENV_NAME="eval"; \
	echo "Using Apigee Organization: $${APIGEE_ORG_NAME}"; \
	echo "Using Apigee Environment: $${APIGEE_ENV_NAME}"; \
	APIGEE_HOST_RESPONSE=$$(curl -s -H "Authorization: Bearer $$APIGEE_TOKEN" \
		"https://apigee.googleapis.com/v1/organizations/$${APIGEE_ORG_NAME}/envgroups"); \
	echo "Raw Apigee envgroups response: $${APIGEE_HOST_RESPONSE}"; \
	APIGEE_HOST=$$(echo "$${APIGEE_HOST_RESPONSE}" | jq -r '.environmentGroups[] | select(.name == "eval-group") | .hostnames[] | select(endswith(".nip.io")) | .'); \
	if [ -z "$${APIGEE_HOST}" ]; then \
		echo "Error: Could not find a hostname for environment '$${APIGEE_ENV_NAME}' in organization '$${APIGEE_ORG_NAME}'."; \
		exit 1; \
	fi; \
	echo "$${APIGEE_HOST}" > .apigee_host; \
	echo "Apigee host retrieved and saved to .apigee_host: $${APIGEE_HOST}"

invoke-proxy: get-apigee-host
	@echo "Invoking Apigee proxy..."
	@APIGEE_HOST=$$(cat .apigee_host); \
	echo "Proxy URL: https://$${APIGEE_HOST}/weather/v1/stations"; \
	curl -v -H "User-Agent: (apigee-demo.google.com, kdrowe@google.com)" "https://$${APIGEE_HOST}/weather/v1/stations"

show-curl-command: get-apigee-host
	@APIGEE_HOST=$$(cat .apigee_host); \
	echo "curl -v \"https://$${APIGEE_HOST}/weather/v1/stations\""

find-dallas-stations: get-apigee-host
	@echo "Searching for Dallas stations..."
	@APIGEE_HOST=$$(cat .apigee_host); \
	curl -sS -H "User-Agent: (apigee-demo.google.com, kdrowe@google.com)" "https://$${APIGEE_HOST}/weather/v1/stations" | jq '.features[] | select(.properties.name | contains("Dallas"))'

export-proxy: get-token
	@echo "Exporting proxy 'weather_service' revision '2'..."
	@APIGEE_TOKEN=$$(cat .gcp_token); \
	curl -s -H "Authorization: Bearer $$APIGEE_TOKEN" \
	"https://apigee.googleapis.com/v1/organizations/$(GCP_PROJECT_ID)/apis/weather_service/revisions/2?format=bundle" \
	-o weather_service.zip
	@echo "Proxy bundle downloaded to weather_service.zip"
	@unzip -o weather_service.zip -d weather_service_proxy
	@echo "Proxy bundle unzipped to weather_service_proxy/"

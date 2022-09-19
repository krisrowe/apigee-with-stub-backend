if [ $# -lt 2 ] 
  then
    echo "No project ID and/or network specified."
    exit
fi

export PROJECT_ID=$1
export NETWORK=$2
export RUNTIME_LOCATION=us-central1
export ANALYTICS_LOCATION=us-central1
export BACKENDZONE=us-central1-a

export GACCT=$(gcloud config get-value account)
echo $GACCT

if [ -z "${GACCT}" ]; then
  gcloud auth login
fi

gcloud config set project $PROJECT_ID
export PROJECT_NUMBER=$(gcloud projects describe $1 --format="value(projectNumber)")

retVal=$?
if [ $retVal -ne 0 ]; then
   echo "Error setting project"
else
   echo "Project set"
fi

sudo docker pull gcr.io/apijamkr/stubbed-service

# The --no-address prevents an external IP from being assigned. Not only
# is this the intention, but it's also required by some organizations' policies.
# The --shielded-secure-boot is also required by some organizations' policies.
gcloud compute instances create-with-container stubvm --network=$NETWORK --zone=$BACKENDZONE \
  --container-image=gcr.io/apijamkr/stubbed-service --no-address --shielded-secure-boot

export STATIC_IP=$(gcloud compute instances describe stubvm --zone=$BACKENDZONE --format='get(networkInterfaces[0].networkIP)')

gcloud beta dns --project=$ managed-zones create hipster-zone --description="" --dns-name="hipster.net." --visibility="private" --networks="${NETWORK}"

gcloud beta dns --project=$PROJECT_ID record-sets transaction start --zone=hipster-zone
gcloud beta dns --project=$PROJECT_ID record-sets transaction add $STATIC_IP \
	--name=catalog.hipster.net. --ttl=300 --type=A --zone=hipster-zone
gcloud beta dns --project=$PROJECT_ID record-sets transaction execute --zone=hipster-zone
gcloud beta services peered-dns-domains create hipster-internal --network=$NETWORK --dns-suffix=hipster.net.

if [ $# -lt 2 ] 
  then
    echo "No project ID and/or network specified."
    exit
fi

export RUNTIME_LOCATION=us-central1
export ANALYTICS_LOCATION=us-central1

export GACCT=$(gcloud config get-value account)
echo $GACCT

if [ -z "${GACCT}" ]; then
  gcloud auth login
fi

gcloud config set project $1
export PROJECT_NUMBER=$(gcloud projects describe $1 --format="value(projectNumber)")

retVal=$?
if [ $retVal -ne 0 ]; then
   echo "Error setting project"
else
   echo "Project set"
fi

#sudo docker pull gcr.io/apijamkr/stubbed-service

# The --no-address prevents an external IP from being assigned. Not only
# is this the intention, but it's also required by some organizations' policies.
# The --shielded-secure-boot is also required by some organizations' policies.
gcloud compute instances create-with-container stubvm --network=$2 --zone=us-central1-a \
  --container-image=gcr.io/apijamkr/stubbed-service --subnet=default --no-address --shielded-secure-boot

export STATIC_IP=$(gcloud compute instances describe stubvm --zone=us-central1-a --format='get(networkInterfaces[0].networkIP)')
echo $STATIC_IP





echo "Done" 

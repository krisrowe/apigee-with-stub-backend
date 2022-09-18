if [ $# -lt 2 ] 
  then
    echo "No project ID and/or network specified."
    exit
fi

export RUNTIME_LOCATION=us-central1
export ANALYTICS_LOCATION=us-central1

export user=$(gcloud config get-value account)
exit
if [ -z "${user}" ]; then
  gcloud auth login
fi

gcloud config set project $1
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

retVal=$?
if [ $retVal -ne 0 ]; then
   echo "Error setting project"
else
   echo "Project set"
fi

sudo docker pull gcr.io/apijamkr/stubbed-service

gcloud compute instances create-with-container stubvm --network $1 \
    --container-image sudo docker pull gcr.io/apijamkr/stubbed-service

export STATIC_IP=$(gcloud compute addresses describe stubvm --region $RUNTIME_LOCATION --format='value(address)')
echo $STATIC_IP





echo "Done" 

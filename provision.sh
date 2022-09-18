if [ $# -eq 0 ] 
  then
    echo "No project ID specified."
    exit
fi

gcloud auth login

gcloud config set project PROJECT_ID

retVal=$?
if [ $retVal -ne 0 ]; then
   echo "Error setting project"
else
   echo "Project set"
fi

echo "Done" 

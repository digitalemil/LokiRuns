

docker build --platform=${PLATFORM} -t ${GCP_REPO}/${GCP_PROJECTID}/lokiruns-v${VERSION} .
docker push ${GCP_REPO}/${GCP_PROJECTID}/lokiruns-v${VERSION}



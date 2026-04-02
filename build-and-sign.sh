#!/bin/bash
#https://codelabs.developers.google.com/signed-container-image-codelab#2
BUILD_ID="build20260401-02"
docker images |grep pkg.dev| awk '{print $1 ":" $2}' |xargs docker rmi
docker build --no-cache -t us-docker.pkg.dev/amber-gcp-hybrid/ita-repo/nginx-ita:$BUILD_ID .
docker push us-docker.pkg.dev/amber-gcp-hybrid/ita-repo/nginx-ita:$BUILD_ID

PUB=$(cat pub.pem | openssl base64)
PUB=$(echo $PUB | tr -d '[:space:]' | sed 's/[=]*$//')
export COSIGN_REPOSITORY=us-docker.pkg.dev/amber-gcp-hybrid/ita-signed-repo/nginx-ita
IMAGE_REFERENCE=us-docker.pkg.dev/amber-gcp-hybrid/ita-repo/nginx-ita:$BUILD_ID

#Cosign sign will automatically upload signatures to the specified COSIGN_REPOSITORY
cosign sign --key gcpkms://projects/amber-gcp-hybrid/locations/global/keyRings/ita-keyring/cryptoKeys/ita-workload-key/cryptoKeyVersions/1 $IMAGE_REFERENCE \
 -a dev.cosignproject.cosign/sigalg=ECDSA_P256_SHA256 \
 -a dev.cosignproject.cosign/pub=$PUB

# Manifests for AKS cluster

## Setup of the container registry

- Export the following environment variables
  ```shell script
  export TF_VAR_SUBSCRIPTION_ID=a38f7abc-cf60-4076-8a22-15b47e89fa41
  export RESOURCE_GROUP=notepadResources
  export KEY_VAULT_NAME=notepadKeyvault
  export ACR_VAULT_NAME=notepadacr
  export ACR_SPA_NAME=notepad-acr-spa
  ```

- create a container registry to store the Docker containers, and an SPA to access it
  ```shell script
  az acr create \
    --subscription ${TF_VAR_SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${ACR_VAULT_NAME} \
    --sku Basic

  ACR_SPA_PASSWORD=$(az ad sp create-for-rbac \
    --name ${ACR_SPA_NAME} \
    --years 99 \
    --role Contributor \
    --scopes /subscriptions/${TF_VAR_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.ContainerRegistry/registries/${ACR_VAULT_NAME} \
    --query password \
    --output tsv)

  # store the password of the SPA in the Key Vault
  az keyvault secret set \
    --subscription ${TF_VAR_SUBSCRIPTION_ID} \
    --vault-name ${KEY_VAULT_NAME} \
    --name "${ACR_SPA_NAME}-secret" \
    --value ${ACR_SPA_PASSWORD}

  ACR_SPA_ID=$(az ad sp list \
    --filter "displayname eq '"${ACR_SPA_NAME}"'" \
    --query "[0].appId" \
    --output tsv
  )
  ```

### Credentials for the container registry

Store the `ACR_SPA_ID` and `ACR_SPA_PASSWORD` variables in the GitHub repository as secrets with the same name.

- save the credentials as Kubernetes secret
  ```shell script
  ENCODED_SPA_CREDS=$(echo "${ACR_SPA_ID}:${ACR_SPA_PASSWORD}" | base64)
  ENCODED_SPA_K8S_SECRET=$(echo "{\"auths\": {\"${ACR_VAULT_NAME}.azurecr.io\": {\"email\": \"user@example.com\", \"auth\": \"${ENCODED_SPA_CREDS}\"}}}" | base64)
  sed \
    -e "s/###ACR_CREDENTIALS###/${ENCODED_SPA_K8S_SECRET}/" \
    secret.yaml-template > secret.yaml
  ```

## Kubernetes namespace

With kubectl you can create the application's namespace and the secret to access the container registry

  ```shell script
  kubectl apply \
    --filename=namespace.yaml
  
  kubectl apply \
    --filename=secret.yaml
  ```
The other YAML files will be applied by the pipeline

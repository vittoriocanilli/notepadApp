# Terraform automation

## Prerequisites

- Export the following environment variables
  ```shell script
  export TF_VAR_TENANT_ID=09827276-aa13-4b63-a468-ca2deabd9212
  export TF_VAR_SUBSCRIPTION_ID=a38f7abc-cf60-4076-8a22-15b47e89fa41
  export RESOURCE_GROUP=notepadResources
  export KEY_VAULT_NAME=notepadKeyvault
  export MY_USER_OBJECT_ID=287de295-02d2-4e39-8d6f-867442ea5b1a
  export TF_SPA_NAME=notepad-terraform-spa
  ```

- login to Azure
  ```shell script
  az login

  az account set \
    --subscription="${TF_VAR_SUBSCRIPTION_ID}"
  ```

- create a resource group
  ```shell script
  az group create \
    --name ${RESOURCE_GROUP} \
    --location "West Europe"
  ```

- create a Key Vault to store the secrets
  ```shell script
  az keyvault create \
    --subscription ${TF_VAR_SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${KEY_VAULT_NAME} \
    --location "West Europe" \
    --sku standard

  az keyvault set-policy \
    --subscription ${TF_VAR_SUBSCRIPTION_ID} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${KEY_VAULT_NAME} \
    --object-id ${MY_USER_OBJECT_ID} \
    --secret-permissions backup delete get list purge recover restore set
  ```

- create the SPA to run the Terraform automation
  ```shell script
  TF_SPA_PASSWORD=$(az ad sp create-for-rbac \
    --name ${TF_SPA_NAME} \
    --years 99 \
    --role Owner \
    --scopes /subscriptions/${TF_VAR_SUBSCRIPTION_ID} \
    --query password \
    --output tsv)

  # store the password of the SPA in the Key Vault
  az keyvault secret set \
    --subscription ${TF_VAR_SUBSCRIPTION_ID} \
    --vault-name ${KEY_VAULT_NAME} \
    --name "${TF_SPA_NAME}-secret" \
    --value ${TF_SPA_PASSWORD}
  ```

## Deploy the cluster 

- initialize the Terraform providers
  ```shell script
  terraform init
  ```

- set credentials of Terraform SPA as Terraform variables
  ```shell script
  export TF_VAR_TF_SPA_ID=$(az ad sp list \
    --filter "displayname eq '"${TF_SPA_NAME}"'" \
    --query "[0].appId" \
    --output tsv
  )
  export TF_VAR_TF_SPA_SECRET=$(az keyvault secret show \
    --vault-name ${KEY_VAULT_NAME} \
    --name "${TF_SPA_NAME}-secret" \
    --query 'value' \
    --output tsv
  )
  ```

  - plan and apply
  ```shell script
  terraform plan \
    -var "resource_group=${RESOURCE_GROUP}"

  terraform apply \
    -var "resource_group=${RESOURCE_GROUP}"
  ```

## Kubeconfig

Store the `kube_config` Terraform output both in the GitHub repository as *KUBE_CONFIG* secret and locally to use kubectl; if you save it in `~/.kube/config_notepad`, you can set up kubectl as follows:
  ```shell script
  export KUBECONFIG=~/.kube/config_notepad
  ```

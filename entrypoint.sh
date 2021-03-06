#!/bin/sh

set -e

if [ -z "$BUILD_DIR" ]; then
  echo "BUILD_DIR is not set. Quitting."
  exit 1
fi

cd ${BUILD_DIR}
echo '👍 ENTRYPOINT HAS STARTED—INSTALLING THE GEM BUNDLE'
bundle install
bundle list | grep "jekyll ("
echo '👍 BUNDLE INSTALLED—BUILDING THE SITE'
bundle exec jekyll build
echo '👍 THE SITE IS BUILT—PUSHING IT BACK TO GITHUB-PAGES'


if [ -z "$AZURE_SUBSCRIPTION_ID" ]; then
  echo "AZURE_SUBSCRIPTION_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AZURE_CLIENT_ID" ]; then
  echo "AZURE_CLIENT_ID is not set. Quitting."
  exit 1
fi
if [ -z "$AZURE_SECRET" ]; then
  echo "AZURE_SECRET is not set. Quitting."
  exit 1
fi
if [ -z "$AZURE_TENANT_ID" ]; then
  echo "AZURE_TENANT_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AZURE_STORAGE_ACCOUNT_NAME" ]; then
  echo "AZURE_STORAGE_ACCOUNT_NAME is not set. Quitting."
  exit 1
fi

if [ -z "$AZURE_INDEX_DOCUMENT_NAME" ]; then
  echo "AZURE_INDEX_DOCUMENT_NAME is not set. Quitting."
  exit 1
fi

if [ -z "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR is not set. Quitting."
  exit 1
fi

curl -sL https://aka.ms/InstallAzureCLIDeb | bash
echo '👍 AZ-CLI INSTALLED!'

# Login
az login --service-principal --username ${AZURE_CLIENT_ID} --password ${AZURE_SECRET} --tenant ${AZURE_TENANT_ID}
echo '👍 az login'


# Set subscription id
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
echo '👍 az account set'

# Enable Static Website
if [ -z "$AZURE_ERROR_DOCUMENT_NAME" ]; then
    az storage blob service-properties update --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --static-website true --index-document ${AZURE_INDEX_DOCUMENT_NAME} --auth-mode login
else
    az storage blob service-properties update --account-name ${AZURE_STORAGE_ACCOUNT_NAME} --static-website true --404-document ${AZURE_ERROR_DOCUMENT_NAME} --index-document ${AZURE_INDEX_DOCUMENT_NAME} --auth-mode login
fi
echo '👍 az storage blob service-properties update'

# Upload source to storage
az storage blob upload-batch -s ${SOURCE_DIR} -d \$web --account-name ${AZURE_STORAGE_ACCOUNT_NAME}
echo '👍 az storage blob upload-batch'

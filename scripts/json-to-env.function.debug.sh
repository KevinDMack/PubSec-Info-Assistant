# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

#!/bin/bash
set -e

source ./scripts/load-env.sh > /dev/null 2>&1

if [ -n "${IN_AUTOMATION}" ]; then
    if [ -n "${AZURE_ENVIRONMENT}" ] && [[ $AZURE_ENVIRONMENT == "AzureUSGovernment" ]]; then
        az cloud set --name AzureUSGovernment > /dev/null 2>&1
    fi

    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" > /dev/null 2>&1
    az account set -s "$ARM_SUBSCRIPTION_ID" > /dev/null 2>&1
fi

jq -r  '
    [
        {
            "path": "AZURE_STORAGE_ACCOUNT",
            "env_var": "BLOB_STORAGE_ACCOUNT"
        },
        {
            "path": "AZURE_BLOB_DROP_STORAGE_CONTAINER",
            "env_var": "BLOB_STORAGE_ACCOUNT_UPLOAD_CONTAINER_NAME"
        },
        {
            "path": "AZURE_STORAGE_CONTAINER",
            "env_var": "BLOB_STORAGE_ACCOUNT_OUTPUT_CONTAINER_NAME"
        },
        {
            "path": "AZURE_BLOB_LOG_STORAGE_CONTAINER",
            "env_var": "BLOB_STORAGE_ACCOUNT_LOG_CONTAINER_NAME"
        },
        {
            "path": "CHUNK_TARGET_SIZE",
            "env_var": "CHUNK_TARGET_SIZE"
        },
        {
            "path": "FR_API_VERSION",
            "env_var": "FR_API_VERSION"
        },
        {
            "path": "TARGET_PAGES",
            "env_var": "TARGET_PAGES"
        },
        {
            "path": "AZURE_FORM_RECOGNIZER_ENDPOINT",
            "env_var": "AZURE_FORM_RECOGNIZER_ENDPOINT"
        },
        {
            "path": "AZURE_COSMOSDB_URL",
            "env_var": "COSMOSDB_URL"
        },
        {
            "path": "AZURE_COSMOSDB_LOG_DATABASE_NAME",
            "env_var": "COSMOSDB_LOG_DATABASE_NAME"
        },
        {
            "path": "AZURE_COSMOSDB_LOG_CONTAINER_NAME",
            "env_var": "COSMOSDB_LOG_CONTAINER_NAME"
        },
        {
            "path": "FUNC_AzureWebJobsStorage__accountName",
            "env_var": "AzureWebJobsStorage__accountName"
        },
        {
            "path": "FUNC_AzureWebJobsStorage__blobServiceUri",
            "env_var": "AzureWebJobsStorage__blobServiceUri"
        },
        {
            "path": "FUNC_STORAGE_CONNECTION_STRING__accountName",
            "env_var": "STORAGE_CONNECTION_STRING__accountName"
        },
        {
            "path": "FUNC_STORAGE_CONNECTION_STRING__queueServiceUri",
            "env_var": "STORAGE_CONNECTION_STRING__queueServiceUri"
        },
        {
            "path": "FUNC_STORAGE_CONNECTION_STRING__blobServiceUri",
            "env_var": "STORAGE_CONNECTION_STRING__blobServiceUri"
        },
        {
            "path": "AZURE_AI_ENDPOINT",
            "env_var": "AZURE_AI_ENDPOINT"
        },
        {
            "path": "ENRICHMENT_NAME",
            "env_var": "ENRICHMENT_NAME"
        },
        {
            "path": "TARGET_TRANSLATION_LANGUAGE",
            "env_var": "TARGET_TRANSLATION_LANGUAGE"
        },
        {
            "path": "ENABLE_DEV_CODE",
            "env_var": "ENABLE_DEV_CODE"
        },
        {
            "path": "BLOB_STORAGE_ACCOUNT_ENDPOINT",
            "env_var": "BLOB_STORAGE_ACCOUNT_ENDPOINT"
        },
        {
            "path": "AZURE_QUEUE_STORAGE_ENDPOINT",
            "env_var": "AZURE_QUEUE_STORAGE_ENDPOINT"
        },
        {
            "path": "AZURE_LOCATION",
            "env_var": "AZURE_AI_LOCATION"
        },
        {
            "path": "AZURE_SEARCH_INDEX",
            "env_var": "AZURE_SEARCH_INDEX"
        },
        {
            "path": "AZURE_SEARCH_SERVICE_ENDPOINT",
            "env_var": "AZURE_SEARCH_SERVICE_ENDPOINT"
        },
        {
            "path": "AZURE_AI_LOCATION",
            "env_var": "AZURE_AI_LOCATION"
        },
        {
            "path": "AZURE_AI_CREDENTIAL_DOMAIN",
            "env_var": "AZURE_AI_CREDENTIAL_DOMAIN"
        },
        {
            "path": "AZURE_OPENAI_AUTHORITY_HOST",
            "env_var": "AZURE_OPENAI_AUTHORITY_HOST"
        }
    ] 
        as $env_vars_to_extract
        |
        with_entries(
            select (
                .key as $a
                |
                any( $env_vars_to_extract[]; .path == $a)
            )
            |
            .key |= . as $old_key | ($env_vars_to_extract[] | select (.path == $old_key) | .env_var)
        )
        |
        to_entries
        | 
        map({key: .key, value: .value.value})
        |
        reduce .[] as $item ({}; .[$item.key] = $item.value)
        |
    {"IsEncrypted": false, "Values": (. + {"FUNCTIONS_WORKER_RUNTIME": "python",
            "AzureWebJobs.parse_html_w_form_rec.Disabled": "true", 
            "MAX_SECONDS_HIDE_ON_UPLOAD": "30", 
            "MAX_SUBMIT_REQUEUE_COUNT": "10",
            "POLL_QUEUE_SUBMIT_BACKOFF": "60",
            "PDF_SUBMIT_QUEUE_BACKOFF": "60",
            "MAX_POLLING_REQUEUE_COUNT": "10",
            "SUBMIT_REQUEUE_HIDE_SECONDS": "1200",
            "POLLING_BACKOFF": "30",
            "MAX_READ_ATTEMPTS": "5",
            "MAX_ENRICHMENT_REQUEUE_COUNT": "10",
            "ENRICHMENT_BACKOFF": "60",
            "EMBEDDINGS_QUEUE": "embeddings-queue",
            "MEDIA_SUBMIT_QUEUE": "media-submit-queue",
            "NON_PDF_SUBMIT_QUEUE": "non-pdf-submit-queue",
            "PDF_POLLING_QUEUE": "pdf-polling-queue",
            "PDF_SUBMIT_QUEUE": "pdf-submit-queue",
            "EMBEDDINGS_QUEUE": "embeddings-queue",
            "TEXT_ENRICHMENT_QUEUE": "text-enrichment-queue",
            "IMAGE_ENRICHMENT_QUEUE": "image-enrichment-queue",
            "LOCAL_DEBUG": "true",
            "AzureWebJobsStorage": "",
            "STORAGE_CONNECTION_STRING": ""
            }
             
    )}
    '

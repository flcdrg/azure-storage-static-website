# Hosting a static website in Azure Storage

An example of deploying a simple vanilla Vite static website to an Azure Storage account, deployed with GitHub Actions.

[Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website?WT.mc_id=DOP-MVP-5001655) supports a simple static website hosting.

It is important to note that static website hosting [needs to be enabled via the portal, Azure CLI or PowerShell](https://learn.microsoft.com/azure/storage/blobs/storage-blob-static-website-how-to?WT.mc_id=DOP-MVP-5001655). Surprisingly it isn't something you can do via Bicep.

## Development notes

## Infrastructure

```bash
az group create --location australiaeast --resource-group rg-storage-web-australiaeast
```

```bash
# Prepare a service principal for Login with OIDC
az ad sp create-for-rbac --name sp-storage-web-australiaeast --role Contributor --scopes /subscriptions/<yoursubscription>/resourceGroups/rg-storage-web-australiaeast
```

Make a note of the appId value, as you'll enter that as the `--id` parameter.

<https://learn.microsoft.com/entra/workload-id/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp&WT.mc_id=DOP-MVP-5001655#github-actions>

Create credential.json

```json
{
    "name": "main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:octo-org/octo-repo:ref:refs/heads/main",
    "description": "Main branch",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
```

```bash
az ad app federated-credential create --id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --parameters credential.json
```

Get the Azure subscription ID:

```bash
az account subscription list
```

and then set the following as GitHub secrets

- AZURE_CLIENT_ID the Application (client) ID
- AZURE_TENANT_ID the Directory (tenant) ID
- AZURE_SUBSCRIPTION_ID your subscription ID

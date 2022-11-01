# Set up function to use for API calls
# This is to avoid encoding issues with Invoke-RestMethod/WebRequest
function Invoke-AzStorageWebRequest {
    param (
        $Uri,
        $Token
    )

    # Create WebRequest object
    $Request = [System.Net.WebRequest]::Create($Uri)

    $Request.Headers.Add('Authorization', "Bearer $Token")
    $Request.Headers.Add('x-ms-version', '2021-08-06')

    # Execute request, save response
    $Response = $Request.GetResponse()
   
    # Read response with a streamreader
    $ResponseStream = $Response.GetResponseStream()
    $StreamReader = [System.IO.StreamReader]::new($ResponseStream)

    # Output the data
    $StreamReader.ReadToEnd()
}

# Set tenant, storage account name and blob uri
$TenantId = '<tenant-id>'
$StorageAccountName = '<storage-account-name>'
$Uri = "https://$StorageAccountName.blob.core.windows.net"

# Requires AzAuth module
# Make sure that you have a Data Blob role
# https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory#azure-built-in-roles-for-blobs
$Token = Get-AzToken -Resource $Uri -TenantId $TenantId -Interactive

# Get ContainerNames by casting result to XML and picking out only the container names
$ContainerNames = ([xml](Invoke-AzStorageWebRequest -Uri "$Uri/?comp=list" -Token $Token)).EnumerationResults.Containers.Container.Name

# Loop through all container names, get blob names and download blobs to files
foreach ($Container in $ContainerNames) {
    $BlobNames = ([xml](Invoke-AzStorageWebRequest -Uri "$Uri/$($Container)?restype=container&comp=list" -Token $Token)).EnumerationResults.Blobs.Blob.Name

    foreach ($Blob in $BlobNames) {
        Invoke-AzStorageWebRequest -Uri "$Uri/$Container/$Blob" -Token $Token | Out-File $Blob -Encoding utf8
    }
}
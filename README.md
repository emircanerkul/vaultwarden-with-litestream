# Vaultwarden with Litestream & Cloudflare R2

This directory contains a Dockerfile setup for running Vaultwarden with Litestream replication to Cloudflare R2. This configuration ensures your SQLite database is continuously backed up to R2.

## Dockerfile Overview

The `Dockerfile` does three main things:
1.  **Starts from the official Vaultwarden image.**
2.  **Installs Litestream:** Downloads and extracts the Litestream binary.
3.  **Configures Litestream:** Creates a `/etc/litestream.yml` configuration file on the fly.
    *   **Crucial Change:** We append `?region=auto&endpoint=${LITESTREAM_ENDPOINT}&force_path_style=true` to the S3 URL. This tells Litestream to talk specifically to your R2 endpoint instead of AWS S3.

## Configuration & Environment Variables

You must set the following environment variables in your deployment platform (e.g., Railway).

### Required Variables

| Variable | Format / Value | Description |
| :--- | :--- | :--- |
| `LITESTREAM_ACCESS_KEY_ID` | `<Your Access Key ID>` | Your Cloudflare R2 Access Key ID. |
| `LITESTREAM_SECRET_ACCESS_KEY` | `<Your Secret Access Key>` | Your Cloudflare R2 Secret Access Key. |
| `LITESTREAM_BUCKET` | `my-bucket-name` | **Only** the name of the bucket (e.g., `vault-backup`). Do **not** include slashes or paths. |
| `LITESTREAM_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` | Your Cloudflare R2 endpoint URL (without the bucket name). |

### Crucial Checks

1.  **No Bucket in Endpoint:** The `LITESTREAM_ENDPOINT` variable must **not** have the bucket name in it. It should just be the account base URL.
    *   ❌ `https://<ACCOUNT_ID>.r2.cloudflarestorage.com/my-bucket`
    *   ✅ `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`
2.  **No "db" path in Bucket Variable:** The `LITESTREAM_BUCKET` variable should just be the bucket name. The Dockerfile automatically adheres `/vaultwarden_db` to the path.
    *   ❌ `my-bucket/database`
    *   ✅ `my-bucket`

## Troubleshooting

### "403 Forbidden" or "Bucket not found"
If you see these errors, Litestream is likely trying to talk to AWS S3 instead of R2.
*   **Cause:** Missing `endpoint` parameter in the S3 URL.
*   **Fix:** Ensure your `Dockerfile` has the updated `RUN echo...` command that includes `endpoint=${LITESTREAM_ENDPOINT}` in the URL generation.

### "Replication failed"
*   Check your Access Key and Secret Key.
*   Ensure the bucket name does not contain slashes.

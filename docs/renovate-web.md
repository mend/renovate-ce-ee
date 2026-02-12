# `Renovate-Web` Service Configuration

Use the following environment variables to run the renovate web server.

> [!NOTE]
> This web server configuration is currently available for Enterprise deployments only and is designed to run with Renovate Enterprise Server.

## Minimal Configuration

Use one of the following minimal sets.

### GitHub

```bash
MEND_RNV_ACCEPT_TOS=true
MEND_RNV_LICENSE_KEY=<your-enterprise-license-key>
MEND_RNV_PLATFORM=github
MEND_RNV_BACKEND_ADDR=http://renovate-ee-server:8080
MEND_RNV_BACKEND_SECRET=<shared-backend-secret>
MEND_RNV_GITHUB_CLIENT_ID=<github-app-client-id>
MEND_RNV_GITHUB_CLIENT_SECRET=<github-app-client-secret>
```

Note: Web UI sign-in uses GitHub OAuth 2.0, and the client ID/secret should come from the same GitHub App configured for Renovate Enterprise Server.

### NoAuth

> [!IMPORTANT]
> `noauth` does not require sign-in for Web UI access.

```bash
MEND_RNV_ACCEPT_TOS=true
MEND_RNV_LICENSE_KEY=<your-license-key>
MEND_RNV_PLATFORM=noauth
MEND_RNV_BACKEND_ADDR=http://renovate-ee-server:8080
MEND_RNV_BACKEND_SECRET=<shared-backend-secret>
```

## Required Configuration

- `MEND_RNV_ACCEPT_TOS`: Confirms Terms of Service acceptance. Allowed input: `y`, `yes`, or `true`.
- `MEND_RNV_LICENSE_KEY`: A valid Mend Renovate Enterprise license key.
- `MEND_RNV_PLATFORM`: Selects authentication/platform mode. Allowed input: `github` or `noauth`.

> [!NOTE]
> If `MEND_RNV_PLATFORM=noauth`, Web UI access does not require sign-in; users who can reach this service can view organization and repository data. Use in trusted environments.
> `noauth` is platform-agnostic and does not depend on which source control platform your Renovate Enterprise Server is configured to use.
- `MEND_RNV_BACKEND_ADDR`: Backend API URL for your Renovate Enterprise Server instance, used by the web server. Allowed input: absolute URL in `scheme://host[:port][/path]` format (for example `http://renovate-ee-server:8080`). If your Renovate Enterprise Server HTTPS endpoint is enabled, use `https://renovate-ee-server:8443`.
- `MEND_RNV_BACKEND_SECRET`: Shared secret for authenticating requests between the web server and Renovate Enterprise Server. Must match the Renovate Enterprise Server API secret (`MEND_RNV_API_SERVER_SECRET`, previously `MEND_RNV_SERVER_API_SECRET`). Allowed input: non-empty string.

## GitHub Configuration

Use this section when `MEND_RNV_PLATFORM=github`.
User sign-in for the Web UI uses GitHub OAuth 2.0.

- `MEND_RNV_GITHUB_CLIENT_ID`: Required when `MEND_RNV_PLATFORM=github`. GitHub App client ID (use the same GitHub App configured for Renovate Enterprise Server).
- `MEND_RNV_GITHUB_CLIENT_SECRET`: Required when `MEND_RNV_PLATFORM=github`. GitHub App client secret (use the same GitHub App configured for Renovate Enterprise Server).
- `MEND_RNV_GITHUB_REDIRECT_URI`: Optional OAuth redirect URL override, useful when the GitHub App has multiple callback URLs configured.
- `MEND_RNV_ENDPOINT`: Endpoint used to resolve platform URLs; when unset it uses public GitHub defaults, and for GitHub Enterprise Server (GHES) it should be set to your GHES endpoint. Default: empty. Allowed input: absolute URL with optional port and path (`scheme://host[:port][/path]`, for example `https://ghe.example.com:8443/api/v3` or `https://ghe.example.com/custom/path`). Required: no (required for GHES deployments).

## HTTPS Configuration

- `MEND_RNV_HTTPS_ENABLED`: Enables HTTPS. Default: `false`. Allowed input: boolean.
- `MEND_RNV_CERT_FILE`: TLS certificate file path. Required: yes when `MEND_RNV_HTTPS_ENABLED=true`.
- `MEND_RNV_KEY_FILE`: TLS private key file path. Required: yes when `MEND_RNV_HTTPS_ENABLED=true`.

## Optional Configuration

- `MEND_RNV_LISTEN_ADDR`: Address and port where the web server listens. Default: `:8080`. Allowed input: listen address (for example `:8080`, `0.0.0.0:8080`).
- `MEND_RNV_CLIENT_CA_CERT`: CA certificate bundle for secure backend connections. Allowed input: path to a PEM CA certificate file.
- `MEND_RNV_SESSION_AGE_OVERRIDE`: Overrides session lifetime. Default: `0` (disabled). Allowed input: duration string (for example `15m`, `2h`).
- `MEND_RNV_PAGE_SIZE`: Default number of items shown in list pages. Default: `20`. Allowed input: integer.
- `MEND_RNV_UI_ENABLE_RUN_JOB`: Shows or hides the Run Job action in the UI. Default: `true`. Allowed input: boolean.
- `MEND_RNV_CSP_FORM_ACTION`: Overrides allowed form submission targets. Default: empty (effective default: `'self'`). Allowed input: Content Security Policy `form-action` value.
- `MEND_RNV_CSP_CONNECT_SRC`: Overrides allowed connection targets. Default: empty (effective default: `'self'`). Allowed input: Content Security Policy `connect-src` value.
- `MEND_RNV_CSP_IMG_SRC`: Overrides allowed image sources. Default: empty (effective default: `'self' data: https:`). Allowed input: Content Security Policy `img-src` value.
- `LOG_LEVEL`: Controls log verbosity. Default: `INFO`. Allowed input: `DEBUG`, `INFO`, `WARN`, `ERROR`.

# HTTPS Configuration

**Table of Contents**

<!-- TOC -->

- [HTTPS Configuration](#https-configuration)
  - [HTTPS Server Configuration](#https-server-configuration)
    - [Example 1](#example-1)
    - [Example 2](#example-2)
    - [Example 3](#example-3)
    - [Example 4](#example-4)
  - [HTTP/S Client Configuration](#https-client-configuration)
    - [Example](#example)
- [Node.js runtime configuration](#nodejs-runtime-configuration)

<!-- TOC -->

## HTTPS Server Configuration

All `Renovate CE/EE` services can be configured to create an `HTTPS` server for secure inbound traffic.

By default, an `HTTP` server is created and listens on port `8080` (configurable via `MEND_RNV_SERVER_PORT`).

`Renovate CE/EE services`:

- `Renovate Enterprise Server`
- `Renovate Enterprise Worker` (health server)
- `Renovate CE`

> [!TIP]
> The HTTP server can be completely disabled by setting the environment variable`MEND_RNV_HTTP_SERVER_DISABLED=true`.

The `HTTPS` server is configured through a `JSON` configuration passed via the environment.
This configuration is resolved and applied when creating the `Node.js` `HTTPS` server.

Available configurations:

**`MEND_RNV_SERVER_HTTPS_PORT`**: Optional – Defaults to `'8443'`.

**`MEND_RNV_SERVER_HTTPS_CONFIG`**: An `JSON` string of type `ServerHttpsConfig`.

**`MEND_RNV_SERVER_HTTPS_CONFIG_PATH`**: A path to a `JSON` file containing `ServerHttpsConfig`.

> [!IMPORTANT]
> To enable `HTTPS`, at least one of `MEND_RNV_SERVER_HTTPS_CONFIG` or `MEND_RNV_SERVER_HTTPS_CONFIG_PATH` must be
> defined.
> If both are provided, the configuration from `MEND_RNV_SERVER_HTTPS_CONFIG` takes precedence.

```typescript
type ServerHttpsConfig = {
  SNIConfig?: Record<string, ServerHttpsOptions>;
  baseConfig?: ServerHttpsOptions;
};
```

The `ServerHttpsOptions` Object accepts configuration options that can be passed via `JSON`, as defined
in [tls.createServer()](https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreateserveroptions-secureconnectionlistener), [tls.createSecureContext()](https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions)
and [http.createServer()](https://nodejs.org/docs/latest-v22.x/api/http.html#httpcreateserveroptions-requestlistener).

- **`SNIConfig`** (optional) – A `JSON` object mapping server names to their specific `HTTPS` configurations, enabling
  `Server Name Indication (SNI)`.

  The `SNIConfig` is used to construct an `SNICallback` – _"A function that is called if the client supports the SNI TLS
  extension"_[^1].

  - The `SNICallback` handles requests that match a server name specified in the `SNIConfig`, using the corresponding
    `ServerHttpsOptions` for that server name.
  - A request that doesnt match any server name will be rejected.

- **`baseConfig`** (optional) – A `JSON` object containing the default `HTTPS` configuration applied when no `SNI` is
  configured
  or when serving a client
  that doesn't support the `SNI TLS extension`.

> [!IMPORTANT]
> At least one of `SNIConfig` or `baseConfig` must be configured.

> [!TIP]
> To load the content of a file into a given configuration option, set its value to `"file://<ABSOLUTE_PATH>"`.

> [!TIP]
> To encode data in base64 for a given configuration option, set its value to `"base64://<BASE64_ENCODED_DATA>"`.

> [!WARNING]
> Inline secrets must be escaped properly, e.g., newlines.

### Example 1

File based configuration, file based secrets, `SNI` only:

`MEND_RNV_SERVER_HTTPS_CONFIG_PATH=/path/to/config.json`

`/path/to/config.json`:

```json
{
  "SNIConfig": {
    "domain1.com": {
      "key": "file:///path/to/key1.pem",
      "cert": ["file:///path/to/cert1.pem"]
    },
    "domain2.com": {
      "key": "file:///path/to/key2.pem",
      "cert": "file:///path/to/cert2.pem"
    }
  },
  "baseConfig": {
    "maxVersion": "TLSv1.3",
    "minVersion": "TLSv1.2"
  }
}
```

### Example 2

File based configuration, file based secrets, `SNI` support with fallback:

`MEND_RNV_SERVER_HTTPS_CONFIG_PATH=/path/to/config.json`

`/path/to/config.json`:

```json
{
  "SNIConfig": {
    "domain1.com": {
      "key": "file:///path/to/key1.pem",
      "cert": "file:///path/to/cert1.pem"
    }
  },
  "baseConfig": {
    "key": "file:///path/to/default/key.pem",
    "cert": "file:///path/to/default/cert.pem",
    "maxVersion": "TLSv1.3",
    "minVersion": "TLSv1.2"
  }
}
```

### Example 3

File based configuration, base64 encoded secrets, `SNI` disabled:
`MEND_RNV_SERVER_HTTPS_CONFIG_PATH=/path/to/config.json`

`/path/to/config.json`:

```json
{
  "baseConfig": {
    "key": "base64://<BASE64_ENCODED_KEY>",
    "cert": "base64://<BASE64_ENCODED_CERT",
    "maxVersion": "TLSv1.3",
    "minVersion": "TLSv1.2"
  }
}
```

### Example 4

String based configuration equivalent to Example 3:

`MEND_RNV_SERVER_HTTPS_CONFIG={"baseConfig":{"key":"base64://<BASE64_ENCODED_KEY>","cert":"base64://<BASE64_ENCODED_CERT","maxVersion":"TLSv1.3","minVersion":"TLSv1.2"}}`

## HTTP/S Client Configuration

All `Renovate CE/EE` services can have their `HTTP/S` client configured.

`Renovate CE/EE services`:

- `Renovate Enterprise Server`: The client is used to communicated with external services, such as `scm`s.
- `Renovate Enterprise Worker`: The client is used to communicated with the `Renovate Enterprise Server` only.
- `Renovate CE`: The client is used to communicated with external services such as `scm`s.

To configure the corresponding Client, provide one of the following:

`MEND_RNV_CLIENT_HTTPS_CONFIG`: An `JSON` string of type `ClientHttpsOptions`

`MEND_RNV_CLIENT_HTTPS_CONFIG_PATH`: A path to a `JSON` file containing `ClientHttpsOptions`

> [!NOTE]
> The `Node.js` runtime uses
> a [hardcoded, statically compiled](https://github.com/nodejs/node/blob/v22.x/src/node_root_certs.h)
> list of default trusted Certificate Authorities.

> [!CAUTION]
> Setting the Certificate Authority (`ca`) will override the default Certificate
> Authorities ([from Mozilla](https://wiki.mozilla.org/CA/Included_Certificates)) used by the `Node.js` runtime. which
> may cause issues with secure connections or certificate validation for public servers.

```typescript
type ClientHttpsOptions = {
  // If not false, the server certificate is verified against the list of supplied CAs. Default: true.
  //
  // For more details, refer to the Node.js documentation on the 'rejectUnauthorized' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlsconnectoptions-callback
  rejectUnauthorized?: boolean | undefined;

  // Optionally override the trusted CA certificates.
  // Default is to trust the well-known CAs curated by Mozilla.
  // Mozilla's CAs are completely replaced when CAs are explicitly specified using this option.
  //
  // For more details, refer to the Node.js documentation on the 'ca' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions
  ca?: string | string[] | undefined;

  // Cert chains in PEM format. One cert chain should be provided per private key.
  //
  // For more details, refer to the Node.js documentation on the 'cert' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions
  cert?: string | string[] | undefined;

  // Private keys in PEM format
  //
  // For more details, refer to the Node.js documentation on the 'key' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions
  key?: string | string[] | undefined;

  // Shared passphrase used for a single private key and/or a PFX.
  //
  // For more details, refer to the Node.js documentation on the 'passphrase' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions
  passphrase?: string | undefined;

  // PFX or PKCS12 encoded private key and certificate chain.
  // pfx is an alternative to providing key and cert individually.
  //
  // For more details, refer to the Node.js documentation on the 'pfx' option in:
  //      https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreatesecurecontextoptions
  pfx?: string | string[] | { buf: string; passphrase?: string }[] | undefined;
};
```

> [!NOTE]
> The `key` + `cert` or `pfx` are required for the client only if the server is configured with`rejectUnauthorized=true`
> and
> `requestCert=true` (Mutual TLS authentication/mTLS).

In most cases, only the `Renovate Enterprise worker's` client needs to be configured only if the corresponding
`Renovate Enterprise Server` is using self-signed certificates. In this case, the worker's client will require the
corresponding `'ca'` to authenticate the server.

### Example

Client configured with a self-signed `'ca'`:

`MEND_RNV_CLIENT_HTTPS_CONFIG={"ca":"file:///path/to/self/signed/ca.pem"}`

# Node.js runtime configuration

The `Node.js` runtime can be configured either individually for the wrapper or globally for both the wrapper and the
wrapped `Node.js` application via the following environment variables:

`NODE_OPTIONS`: Globally define the `NODE_OPTIONS` for both the wrapper `Renovate Enterprise worker/Renovate CE` and the
wrapped `Renovate CLI`.

`MEND_RNV_NODE_OPTIONS`: Define `NODE_OPTIONS` only for the `Renovate Enterprise worker` or `Renovate CE` wrappers.

`RENOVATE_NODE_OPTIONS`: Define `NODE_OPTIONS` individually for the `Renovate CLI`.

[^1]: https://nodejs.org/docs/latest-v22.x/api/tls.html#tlscreateserveroptions-secureconnectionlistener

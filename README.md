# API Umbrella

## What Is API Umbrella?

API Umbrella is an open source API management platform for exposing web service APIs. The basic goal of API Umbrella is to make life easier for both API creators and API consumers. How?

* **Make life easier for API creators:** Allow API creators to focus on building APIs.
  * **Standardize the boring stuff:** APIs can assume the boring stuff (access control, rate limiting, analytics, etc.) is already taken care if the API is being accessed, so common functionality doesn't need to be implemented in the API code.
  * **Easy to add:** API Umbrella acts as a layer above your APIs, so your API code doesn't need to be modified to take advantage of the features provided.
  * **Scalability:** Make it easier to scale your APIs.
* **Make life easier for API consumers:** Let API consumers easily explore and use your APIs.
  * **Unify disparate APIs:** Present separate APIs as a cohesive offering to API consumers. APIs running on different servers or written in different programming languages can be exposed at a single endpoint for the API consumer.
  * **Standardize access:** All your APIs are can be accessed using the same API key credentials.
  * **Standardize documentation:** All your APIs are documented in a single place and in a similar fashion.

## Getting Started

Once you have API Umbrella up and running, there are a variety of things you can do to start using the platform. For a quick tutorial, see [getting started](https://api-umbrella.readthedocs.org/en/latest/getting-started.html).

## API Umbrella Development

Are you interested in working on the code behind API Umbrella? See our [development setup guide](https://api-umbrella.readthedocs.org/en/latest/developer/dev-setup.html) to see how you can get a local development environment setup.

### Docker Development Setup

The easiest way to get a development environment running is with Docker Compose:

```bash
# Clean up any existing Docker resources (optional, for fresh start)
docker compose down -v

# Build and start all services (app, postgres, opensearch)
docker compose build
docker compose up -d

# Watch the logs
docker compose logs -f app
```

**Services and Ports:**
- **App**: HTTP on `localhost:8200`, HTTPS on `localhost:8201`
- **PostgreSQL**: `localhost:14011`
- **OpenSearch**: `localhost:14002`

**Access Points:**
- Admin UI: https://localhost:8201/admin/
- API State: http://localhost:8200/api-umbrella/v1/state

**First-time Setup Notes:**

On first run, the containers will:
1. Generate the Makefile via `./configure`
2. Create the PostgreSQL database and users automatically
3. Run database migrations
4. Build the admin UI (Ember) and example website (Hugo)

This may take several minutes on first startup. Watch the logs with `docker compose logs -f app` to monitor progress.

**Troubleshooting:**

If you encounter issues, try a complete reset:
```bash
docker compose down -v
docker system prune -af --volumes
docker compose build --no-cache
docker compose up -d
```

---

## Admin API Usage

The Admin API allows you to programmatically manage API backends. You'll need two tokens:
- **User API Key**: Sign up at https://api.data.gov/signup
- **Admin Auth Token**: In the Admin UI, click the gear icon → My Account

### Create an API Backend

```bash
curl -sk -X POST "https://localhost:8201/api-umbrella/v1/apis" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_USER_API_KEY" \
  -H "X-Admin-Auth-Token: YOUR_ADMIN_AUTH_TOKEN" \
  -d '{
    "api": {
      "name": "My API Backend",
      "frontend_host": "localhost:8201",
      "backend_host": "api.example.com",
      "backend_protocol": "https",
      "balance_algorithm": "round_robin",
      "servers": [
        {"host": "api.example.com", "port": 443}
      ],
      "url_matches": [
        {"frontend_prefix": "/my-api/", "backend_prefix": "/v1/"}
      ],
      "settings": {
        "disable_api_key": false
      }
    }
  }'
```

### Publish Configuration Changes

After creating or modifying an API, publish the changes to make them live:

```bash
curl -sk -X POST "https://localhost:8201/api-umbrella/v1/config/publish" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_USER_API_KEY" \
  -H "X-Admin-Auth-Token: YOUR_ADMIN_AUTH_TOKEN" \
  -d '{"config": {"apis": {"API_ID_HERE": {"publish": 1}}}}'
```

### Delete an API Backend

```bash
curl -sk -X DELETE "https://localhost:8201/api-umbrella/v1/apis/API_ID_HERE" \
  -H "X-Api-Key: YOUR_USER_API_KEY" \
  -H "X-Admin-Auth-Token: YOUR_ADMIN_AUTH_TOKEN"
```

### Example: GeoPlatform Wildland Fire Data

```bash
# Create the API backend
curl -sk -X POST "https://localhost:8201/api-umbrella/v1/apis" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: YOUR_USER_API_KEY" \
  -H "X-Admin-Auth-Token: YOUR_ADMIN_AUTH_TOKEN" \
  -d '{
    "api": {
      "name": "Federal | GeoPlatform | NIFC Wildland Fire Transmission Lines",
      "frontend_host": "localhost:8201",
      "backend_host": "sit-geoserver.geoplatform.info",
      "backend_protocol": "https",
      "balance_algorithm": "round_robin",
      "servers": [
        {"host": "sit-geoserver.geoplatform.info", "port": 443}
      ],
      "url_matches": [
        {"frontend_prefix": "/federal/geoplatform/nifc/wildland-fire-transmission-lines/", "backend_prefix": "/geoserver/ogc/features/v1/collections/WILDLAND-FIRE:transmission-lines-hifld/"}
      ],
      "settings": {
        "disable_api_key": true
      }
    }
  }'
```

---

## Who's using API Umbrella?

* [api.data.gov](https://api.data.gov/)
* [NREL Developer Network](http://developer.nrel.gov/)
* [api.sam.gov](https://api.sam.gov)

Are you using API Umbrella? [Edit this file](https://github.com/NREL/api-umbrella/blob/master/README.md) and let us know.

## License

API Umbrella is open sourced under the [MIT license](https://github.com/NREL/api-umbrella/blob/master/LICENSE.txt).

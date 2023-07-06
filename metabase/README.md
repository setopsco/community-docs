# Metabase

[Metabase](https://www.metabase.com/) is a self-service data analytics platform.

## SetOps Stage Configuration

This is an extract of the SetOps configuration to run Metabase. The only required env variable is `METABASE_DATABASE_URL` which must be a link to a PostgreSQL or MySQL service.

```
apps:
    metabase:
        container:
            health_check:
                command:
                    - /bin/sh
                    - -c
                    - curl -s http://localhost:3000/api/health | grep ok
                interval: 30
                retries: 3
                start_period: 60
                timeout: 15
        links:
            app-database:
                env_key: APP_DATABASE_URL
            metabase-database:
                env_key: METABASE_DATABASE_URL
        network:
            health_check:
                path: /api/health
                status: 200-499
            ports:
                - 3000
            protocol: http
            public: true
        resources:
            cpu: 128
            memory: 2048
            scale: 1
services:
    app-database:
        plan: shared
        type: postgresql
    metabase-database:
        plan: shared
        type: postgresql
...
```

## Deployment

You can just apply the configuration above to your SetOps Stage and afterwards build & push the image in this directory as you are used to.

# GitHub Environment Setup — yassen_hamdy

## Create Environment

1. Go to your GitHub repository → **Settings** → **Environments**
2. Click **New environment**
3. Name: `yassen_hamdy`
4. Click **Configure environment**

## Add Secrets

Add the following secrets to the `yassen_hamdy` environment:

| Secret Name        | Description                              | Example                |
|--------------------|------------------------------------------|------------------------|
| `DOCKER_USERNAME`  | Your Docker Hub username                 | `yassenhamdy`          |
| `DOCKER_PASSWORD`  | Docker Hub access token or password      | `dckr_pat_xxxxx`       |
| `CD_REPO_TOKEN`    | GitHub PAT with write access to CD repo  | `ghp_xxxxx`            |

## Run the Pipeline

1. Go to **Actions** tab
2. Select **Production CI/CD - yassen_hamdy**
3. Click **Run workflow**
4. Optionally set a custom `image_tag`
5. Click **Run workflow**

## Pipeline Steps

The workflow performs:
1. Checkout repository
2. Setup Java 11 (Temurin)
3. Build JAR with Maven (`mvn clean package`)
4. Upload JAR as GitHub artifact
5. Build Docker image
6. Push to Docker Hub (`DOCKER_USERNAME/demo1:TAG`)
7. Update CD repository with new image tag
8. Concurrency group prevents parallel runs

## CD Repository Structure

The CD repo (`Hassan-Eid-Hassan/java-cd`) should contain:

```
java-cd/
└── yassen_hamdy/
    ├── deployment.yaml   # image tag updated by CI
    └── service.yaml
```

The CI pipeline updates the `image:` field in `yassen_hamdy/deployment.yaml`.

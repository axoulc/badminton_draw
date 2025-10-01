# Badminton Tournament Manager - Docker

## Build and Run with Docker

### Prerequisites
- Docker installed on your system

### Build the Docker image

```bash
docker build -t badminton-tournament-manager .
```

### Run the container

```bash
docker run -d -p 8080:80 --name badminton-app badminton-tournament-manager
```

The app will be available at: http://localhost:8080

### Docker Compose (Optional)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  badminton-app:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped
```

Then run:

```bash
docker-compose up -d
```

### Stop the container

```bash
docker stop badminton-app
docker rm badminton-app
```

### View logs

```bash
docker logs badminton-app
```

### Environment Configuration

The Docker image includes:
- Flutter web app (production build)
- Nginx web server (Alpine Linux)
- Gzip compression enabled
- Security headers configured
- Static asset caching
- SPA routing support

### Deploy to Production

#### Deploy to any cloud platform:

**AWS (EC2, ECS, App Runner)**
```bash
# Tag and push to ECR
docker tag badminton-tournament-manager:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/badminton:latest
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/badminton:latest
```

**Google Cloud Run**
```bash
gcloud builds submit --tag gcr.io/<project-id>/badminton
gcloud run deploy --image gcr.io/<project-id>/badminton --platform managed
```

**Azure Container Instances**
```bash
az acr build --registry <registry-name> --image badminton:latest .
az container create --resource-group <rg-name> --name badminton-app \
  --image <registry-name>.azurecr.io/badminton:latest --dns-name-label badminton
```

**Heroku**
```bash
heroku container:push web -a <app-name>
heroku container:release web -a <app-name>
```

**DigitalOcean App Platform**
- Connect repository
- Select Dockerfile deployment
- Deploy automatically

### Build Optimization

The Docker image uses multi-stage builds:
1. **Build stage**: Compiles Flutter web app
2. **Runtime stage**: Serves with lightweight nginx (Alpine)

Final image size: ~50MB (without Flutter SDK)

### Troubleshooting

**Build fails:**
- Ensure you have sufficient disk space (>5GB)
- Check Docker daemon is running
- Try: `docker system prune` to free up space

**App not accessible:**
- Check port mapping: `docker ps`
- Verify firewall rules
- Check logs: `docker logs badminton-app`

**Performance issues:**
- Increase nginx worker processes in nginx.conf
- Enable HTTP/2 if using HTTPS
- Use CDN for static assets

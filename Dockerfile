# ---------------------------------------
# 🧱 BoDiGi™ - Cloud Run Dockerfile
# Production build for Vite + React
# ---------------------------------------

# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files and build
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built files to Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy your optimized nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose Cloud Run’s required port
EXPOSE 8080

# Health check for Cloud Run
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

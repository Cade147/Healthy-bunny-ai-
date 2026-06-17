# Multi-stage build for Health Bunny

# Stage 1: Build backend
FROM node:18-alpine AS api-builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy workspace files
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./

# Copy all packages
COPY . .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build backend
RUN pnpm -F api-server build

# Stage 2: Build frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /app

RUN npm install -g pnpm

COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY . .

RUN pnpm install --frozen-lockfile

# Build frontend
RUN pnpm -F health-bunny build

# Stage 3: API Runtime
FROM node:18-alpine AS api

WORKDIR /app

RUN npm install -g pnpm

# Copy only necessary files
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY artifacts/api-server/ ./artifacts/api-server/
COPY lib/ ./lib/

# Install production dependencies
RUN pnpm install --prod --frozen-lockfile

# Expose API port
EXPOSE 3001

ENV NODE_ENV=production
ENV PORT=3001

CMD ["pnpm", "-F", "api-server", "start"]

# Stage 4: Frontend Runtime (Nginx)
FROM nginx:alpine AS frontend

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built frontend
COPY --from=frontend-builder /app/artifacts/health-bunny/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Stage 5: Combined Runtime
FROM node:18-alpine AS production

WORKDIR /app

RUN npm install -g pnpm pm2

COPY pnpm-workspace.yaml package.json pnpm-lock.yaml ./
COPY . .

RUN pnpm install --frozen-lockfile && \
    pnpm build

EXPOSE 3001

ENV NODE_ENV=production

CMD ["pm2-runtime", "start", "ecosystem.config.js"]

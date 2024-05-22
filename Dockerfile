#---------------------------------------
# Base
#---------------------------------------

FROM oven/bun:1.1.9-alpine AS base
USER bun
WORKDIR /workspace
ENTRYPOINT []
CMD []

#---------------------------------------
# Dependencies
#---------------------------------------

FROM base AS dependencies
COPY --chown=bun:bun package.json .
COPY --chown=bun:bun packages/frontend/package.json packages/frontend/
COPY --chown=bun:bun packages/backend/package.json packages/backend/
COPY --chown=bun:bun packages/cli/package.json packages/cli/
COPY --chown=bun:bun bun.lockb .

FROM dependencies AS dependencies_dev
RUN bun install --frozen-lockfile

FROM dependencies AS dependencies_prod
RUN bun install --frozen-lockfile --production

#---------------------------------------
# Frontend
#---------------------------------------

FROM base AS frontend
COPY --chown=bun:bun packages/frontend packages/frontend

FROM frontend AS frontend_dev
COPY --from=dependencies_dev /workspace/node_modules /workspace/node_modules
CMD ["bun", "run", "--filter", "frontend", "dev"]

FROM frontend AS frontend_prod_build
COPY --from=dependencies_prod /workspace/node_modules /workspace/node_modules
RUN bun run --filter frontend build

FROM nginxinc/nginx-unprivileged:1.26-alpine AS frontend_prod
COPY --from=frontend_prod_build /workspace/packages/frontend/dist /usr/share/nginx/html

#---------------------------------------
# Backend
#---------------------------------------

FROM base AS backend
COPY --chown=bun:bun packages/backend packages/backend
EXPOSE 3000

FROM backend AS backend_dev
COPY --from=dependencies_dev /workspace/node_modules /workspace/node_modules
CMD ["bun", "run", "--filter", "backend", "dev"]

FROM backend AS backend_prod
COPY --from=dependencies_prod /workspace/node_modules /workspace/node_modules
CMD ["bun", "run", "--filter", "backend", "start"]

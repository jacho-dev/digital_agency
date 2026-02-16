# --------- deps ---------
FROM node:20-alpine AS deps
WORKDIR /app
RUN apk add --no-cache libc6-compat

COPY package*.json ./
RUN npm ci

# --------- builder ---------
FROM node:20-alpine AS builder
WORKDIR /app
ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# --------- runner ---------
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

# Copia lo necesario para correr
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Copia public SOLO si existe en tu repo (si no existe, NO lo copies)
# Si luego creas public/, descomenta la línea:
# COPY --from=builder /app/public ./public

USER nextjs
CMD ["npm", "run", "start"]

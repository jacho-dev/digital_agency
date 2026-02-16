# --------- runner ---------
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

# Copia package y build output
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Copia public SOLO si existe (hacemos un truco: copiamos todo el directorio y ya)
# En vez de copiar /public directo, copiamos el proyecto completo "filtrado" no conviene.
# Mejor: crea public vacío o elimina este COPY.
USER nextjs
CMD ["npm", "run", "start"]

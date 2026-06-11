# ---------- Build ----------
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
# Placeholder apenas para o prisma.config.ts carregar; o generate não conecta ao banco
ENV DATABASE_URL="postgresql://build:build@localhost:5432/build"
RUN npx prisma generate && npm run build

# ---------- Runtime ----------
FROM node:22-alpine AS production

WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY prisma ./prisma
COPY prisma.config.ts ./
COPY --from=build /app/dist ./dist

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/seed.js && node dist/main.js"]

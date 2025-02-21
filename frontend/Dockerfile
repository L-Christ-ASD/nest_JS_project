# Étape 1 : Build du projet Vite
FROM node:18 AS builder
WORKDIR /app

# Copier les fichiers nécessaires
COPY package.json package-lock.json ./
RUN npm install

# Copier tout le code et builder
COPY . .
RUN npm run build

# Étape 2 : Serveur Nginx pour le frontend
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# Exposer le port 80
# EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

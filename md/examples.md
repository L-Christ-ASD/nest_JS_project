# Exemples de multi-staging Docker

## Example avec une application Nest.js

### Création d'une application Nest.js

On va créer une application Nest.js pour la démonstration.

```bash
npm install --global @nestjs/cli
nest new nest-app
```

Après avoir sélectionné les différentes options, on peut se rendre dans le dossier de l'application, installer les dépendances et démarrer l'application.

```bash
cd nest-app
npm run start
```

### Création d'une image Docker pour l'application

#### Création d'une image dédiée au développement

On va créer une image Docker pour l'application Nest.js en mode développement. Pour cela, on crée un fichier `Dockerfile.development` à la racine du projet.

```Dockerfile
FROM node:latest

WORKDIR /app

COPY ./package.json ./

RUN npm install

COPY ./ ./

CMD ["npm", "run", "start:dev", "--", "--host", "0.0.0.0"]
```

On peut maintenant construire l'image Docker.

```bash
docker build --tag nest-app:development --file ./nest-app/Dockerfile.development ./nest-app
```

On peut maintenant démarrer un conteneur Docker avec l'image créée.

```bash
docker run --publish 3000:3000 nest-app:development
```

#### Docker Compose Watch

On va utiliser Docker Compose Watch pour synchroniser les modifications du code source avec le conteneur Docker. Pour cela, on va ajouter un service `nest-app` au fichier `compose.development.yml` à la racine du projet.

```yaml
services:
  react-app:
    image: react-app:development
    build:
      context: ./react-app
      dockerfile: Dockerfile.development
    ports:
      - "5173:5173"
    develop:
      watch:
        - action: sync
          path: react-app/src
          target: /app/src
        - action: sync+restart
          path: react-app
          target: /app
        - action: rebuild
          path: react-app/package.json
  nest-app:
    image: nest-app:development
    build:
      context: ./nest-app
      dockerfile: Dockerfile.development
    ports:
      - "3000:3000"
    develop:
      watch:
        - action: sync
          path: nest-app/src
          target: /app/src
        - action: sync+restart
          path: nest-app
          target: /app
        - action: rebuild
          path: nest-app/package.json
```

On peut maintenant démarrer le conteneur Docker avec Docker Compose Watch.

```bash
docker-compose --file compose.development.yml up --build --watch
```

### Création d'une image Docker pour la production

On va créer une image Docker pour l'application Nest.js en mode production. Pour cela, on crée un fichier `Dockerfile` à la racine du projet.

```Dockerfile
FROM node:latest AS builder

WORKDIR /app

COPY ./package.json ./

RUN npm install

COPY ./ ./

RUN npm run build


FROM oven/bun:alpine AS server

WORKDIR /app

COPY --from=builder /app/dist ./dist

COPY ./package.json ./

RUN bun install --production

CMD ["bun", "dist/main"]
```

On utilise Bun pour démarrer l'application en mode production, mais on pourrait très bien continuer à utiliser Node.js (ou utiliser Deno.js par exemple).

On peut maintenant construire l'image Docker.

```bash
docker build --tag nest-app:production ./nest-app
```

On peut maintenant démarrer un conteneur Docker avec l'image créée.

```bash
docker run --publish 3000:3000 nest-app:production
```

## Exemple avec une application Python

### Création d'un Dockerfile multi-staging

Créez un premier stage pour installer les dépendances et préparer l'environnement de développement :

```Dockerfile
FROM python:3.10 AS builder

# Installer les dépendances système nécessaires :
RUN apt-get update && apt-get install -y build-essential

WORKDIR /app

COPY requirements.txt ./

# Installer les dépendances :
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste des fichiers :
COPY ./ ./

# Construire l'application (si nécessaire, par ex. compilation Cython) :
RUN python setup.py build
```

Créez un second stage minimaliste pour exécuter l'application :

```Dockerfile
FROM python:3.10-slim AS server

WORKDIR /app

# Copier uniquement les fichiers nécessaires depuis le stage précédent :
COPY --from=builder /app /app

# Installer uniquement les dépendances nécessaires à la production :
RUN pip install --no-cache-dir -r requirements.txt --only-binary=:all:

# Commande par défaut pour démarrer l'application :
CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:8000", "app:app"]
```

Le premier stage utilise une image complète avec tous les outils nécessaires à la construction.
Le second stage utilise une image légère (slim) et ne conserve que ce qui est indispensable à l'exécution.
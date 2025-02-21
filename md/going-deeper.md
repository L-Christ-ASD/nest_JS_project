# Analyse approfondie

## Utilisation d'un unique Dockerfile

On peut utiliser un unique Dockerfile pour les environnements de développement et de production. On va simplement séparer les étapes de construction et d'exécution de manière distincte pour le développement et la production.

Dans un Dockerfile multi-étapes, le paramètre `target` dans Docker Compose ou le *flag* `--target` dans `docker build` permet de spécifier à quelle étape du processus de construction s'arrêter. 

```Dockerfile
FROM node:latest AS base

WORKDIR /app

COPY ./package.json ./

RUN npm install

COPY ./ ./


FROM base AS development

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]


FROM base AS build

RUN npm run build


FROM nginx:alpine AS production

COPY --from=build /app/dist /usr/share/nginx/html
```

On a ici 4 étapes :
- `base` : étape de base pour installer les dépendances et copier le code source
- `development` : étape pour démarrer l'application en mode développement
- `build` : étape pour construire l'application
- `production` : étape pour démarrer l'application en mode production

On peut maintenant construire l'image Docker pour l'environnement de développement avec le *flag* `--target`.

```bash
docker build --tag react-app:development --target development ./react-app
```

On peut maintenant construire l'image Docker pour l'environnement de production avec le *flag* `--target`.

```bash
docker build --tag react-app:production --target production ./react-app
```

Concrètement, la construction de l'image Docker pour l'environnement de développement va s'arrêter à l'étape `development` et celle pour l'environnement de production à l'étape `production`. L'étape de production ne va même pas lancer les commandes de l'étape de développement, car elles ne sont pas nécessaires, et il n'existe aucune dépendance entre les étapes.

## Mise à jour du Docker Compose

### Utilisation de `target`

Le Docker Compose est principalement dédié à l'environnement de développement. On va donc mettre à jour le fichier `compose.development.yml` pour utiliser l'image Docker pour l'environnement de développement ou la construire si elle n'existe pas en utilisant l'attribut `target`.

```yaml
services:
  react-app:
    image: react-app:development
    build:
      context: ./react-app
      dockerfile: Dockerfile
      target: development
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
  # ...
```

### Utilisation d'une variable d'environnement

Pour l'environnement de production, on va utiliser une variable d'environnement pour spécifier l'image Docker à utiliser. On va mettre à jour le fichier `compose.production.yml` (en `compose.yml`) pour utiliser l'image Docker pour l'environnement de production.

On commence par définir la variable d'environnement dans le fichier `.env`.

```
ENVIRONMENT=production
```

On peut maintenant mettre à jour le fichier `compose.yml` pour utiliser la variable d'environnement.

```yaml
services:
  react-app:
    build:
      context: ./react-app
      dockerfile: Dockerfile
      target: ${ENVIRONMENT}
    ports:
      - "5173:5173"
      - "80:80"
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
  # ...
```

Ainsi, on peut démarrer facilement l'application en mode développement ou production en utilisant la variable d'environnement `ENVIRONMENT`.

```bash
docker-compose up --build
```

#### Utilisation d'un `Makefile`

Un `Makefile` a été ajouté pour simplifier les commandes.

```Makefile
ENV_FILE=.env

.PHONY: dev prod

watch:
	@echo "ENVIRONMENT=development" > $(ENV_FILE)
	@docker-compose up --build --watch

run:
	@echo "ENVIRONMENT=production" > $(ENV_FILE)
	@docker-compose up --build
```

On peut maintenant démarrer l'application en mode développement ou production en utilisant les commandes suivantes.

```bash
make watch
```

```bash
make run
```

## Conclusion

Le multi-staging est particulièrement efficace pour réduire la taille des images, car seule la partie nécessaire pour exécuter l’application est incluse dans l’image finale. Cela améliore également le temps de build et de déploiement, en réduisant la quantité de données à traiter. 

On peut avoir un contrôle sur cela, au sein d'un fichier unique, en ciblant précisément les étapes de construction et d'exécution pour chaque environnement.
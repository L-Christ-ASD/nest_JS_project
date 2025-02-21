# Utilisation de Traefik comme reverse proxy avec Docker Compose

## Objectifs pédagogiques

- Comprendre les concepts de base de Traefik (Entrypoints, Routers, Services, Middlewares, Providers).
- Installer et configurer Traefik comme reverse proxy.
- Mettre en place un projet démontrant l'auto-découverte des services avec Docker Compose.
- Visualiser le routage via le tableau de bord Traefik.

## Étape 1 : Concepts clés de Traefik

Avant de commencer, voici les concepts essentiels :

1. **Entrypoints** : Les ports sur lesquels Traefik écoute les requêtes entrantes (e.g., HTTP sur le port 80).
2. **Routers** : Définissent les règles de routage pour diriger les requêtes vers les services backend.
3. **Services** : Les applications ou microservices vers lesquels le trafic est acheminé.
4. **Middlewares** : Modifient les requêtes avant qu'elles n'atteignent les services (e.g., authentification, réécriture d'URL).
5. **Providers** : Sources dynamiques de configuration (e.g., Docker, Kubernetes).

## Étape 2 : Préparation du projet

### Créez une structure de fichiers :

```bash
mkdir traefik-demonstration && cd traefik-demonstration
touch compose.yml
```

### Contenu du fichier `docker-compose.yml` :

Voici une configuration de base pour utiliser Traefik avec Docker Compose :

```yaml
services:
   reverse-proxy:
      image: traefik:latest
      container_name: traefik
      command:
         - --api.insecure=true # Active l'interface du tableau de bord sans authentification
         - --providers.docker=true # Active Docker comme provider dynamique
         - --entrypoints.web.address=:80 # Définit un entrypoint HTTP sur le port 80
      ports:
         - "80:80" # Port HTTP
         - "8080:8080" # Tableau de bord Traefik
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock # Permet à Traefik d'accéder aux informations des conteneurs Docker

   whoami:
      image: traefik/whoami # Service simple qui retourne des informations sur la requête HTTP
      container_name: whoami
      labels:
         - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)" # Règle de routage basée sur le host

networks:
   default:
      name: traefik-net
```

## Étape 3 : Lancer et tester la configuration

### 1. Démarrez les services :

Exécutez la commande suivante pour démarrer les conteneurs :

```bash
docker-compose up --detach
```

### 2. Accédez au tableau de bord Traefik :

Ouvrez votre navigateur et allez à [http://localhost:8080](http://localhost:8080). Vous verrez le tableau de bord Traefik avec les routes configurées.

### 3. Testez le service `whoami` :

Dans votre navigateur, accédez à [http://whoami.docker.localhost](http://whoami.docker.localhost). Vous devriez voir une réponse contenant des informations sur la requête HTTP.

## Étape 4 : Ajouter un deuxième service

Ajoutez un deuxième service au fichier `docker-compose.yml` pour démontrer l'auto-découverte :

```yaml
  whoami-again:
     image: traefik/whoami
     container_name: whoami-again
     labels:
        - "traefik.http.routers.whoami-again.rule=Host(`whoami-again.docker.localhost`)"
```

### Relancez Docker Compose :

Ajoutez le nouveau service sans arrêter les conteneurs existants :

```bash
docker-compose up --detach whoami-again
```

### Testez le nouveau service :

Accédez à [http://whoami-again.docker.localhost](http://whoami-again.docker.localhost) pour vérifier que le second service est accessible.

## Étape 5 : Analyse des routes sur le tableau de bord

1. Retournez au tableau de bord Traefik ([http://localhost:8080](http://localhost:8080)).
2. Vérifiez que deux routes sont configurées :
   - Une route pour `whoami.docker.localhost`.
   - Une route pour `whoami-again.docker.localhost`.

## Étape 6 : Explication des labels et auto-découverte

### Labels dans Docker Compose :
Les labels définissent dynamiquement les règles utilisées par Traefik pour router les requêtes vers vos services.

Exemple :

```yaml
labels:
   - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)"
```

- **`traefik.http.routers.whoami.rule`** : Définit une règle basée sur l'hôte HTTP.
- **`Host(`whoami.docker.localhost`)`** : Route uniquement les requêtes avec cet hôte vers ce service.

### Auto-découverte :

Grâce à l'option `--providers.docker=true`, Traefik détecte automatiquement tous les conteneurs Docker ayant des labels définis et configure leurs routes dynamiques.

## Étape 7 : Ajout d'un middleware (optionnel)

Ajoutez un middleware pour rediriger automatiquement toutes les requêtes HTTP vers HTTPS.

1. Modifiez le fichier `docker-compose.yml` pour inclure un middleware :

```yaml
services:
   reverse-proxy:
      image: traefik:latest
      container_name: traefik
      command:
         - --api.insecure=true
         - --providers.docker=true
         - --entrypoints.web.address=:80
         - --entrypoints.websecure.address=:443 # Entrypoint HTTPS activé
      ports:
         - "80:80"
         - "443:443"
         - "8080:8080"
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock

   whoami:
      image: traefik/whoami
      container_name: whoami
      labels:
         - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)"
         - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https" # Middleware redirection HTTPS
         - "traefik.http.routers.whoami.middlewares=redirect-to-https" # Attache le middleware au router

networks:
   default:
      name: traefik-net
```

2. Relancez Docker Compose :

```bash
docker-compose up -d
```

3. Testez la redirection HTTPS en accédant à [http://whoami.docker.localhost](http://whoami.docker.localhost). Vous serez automatiquement redirigé vers HTTPS.



# Exemple de commande pour lancer un Proxy pour Docker Socket

```bash
docker run -d \
    --name dockerproxy \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e CONTAINERS=1 \
    -e IMAGES=0 \
    -e NETWORKS=0 \
    -p 2375:2375 \
    tecnativa/docker-socket-proxy
```
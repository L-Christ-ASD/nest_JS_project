# Utiliser Traefik pour le Load Balancing

Traefik peut faire du load balancing, et il offre plusieurs options pour gérer efficacement la répartition de charge entre différents services. Voici un aperçu des mécanismes de load balancing proposés par Traefik ainsi que des exemples concrets pour les implémenter.

## Options de Load Balancing proposées par Traefik

### 1. Round Robin

- **Description** : Répartit les requêtes de manière équitable entre les instances disponibles, en suivant un ordre circulaire.
- **Cas d'utilisation** : Idéal pour des services ayant des capacités similaires.

### 2. Weighted Round Robin

- **Description** : Une version pondérée du Round Robin où chaque service peut se voir attribuer un poids. Les services avec un poids plus élevé recevront une proportion plus importante des requêtes.
- **Cas d'utilisation** : Utile si certaines instances ont plus de ressources ou doivent traiter plus de trafic.

### 3. Traffic Mirroring

- **Description** : Copie le trafic d'un service principal vers un ou plusieurs services secondaires à des fins de test ou d'analyse.
- **Cas d'utilisation** : Tester une nouvelle version d'un service sans interrompre le trafic en production.

### 4. Failover (Tolérance aux pannes)

- **Description** : Si une instance est indisponible, Traefik redirige automatiquement le trafic vers une autre instance disponible.
- **Cas d'utilisation** : Assurer la haute disponibilité des services.

### 5. Load Balancing pour TCP et UDP

- Traefik prend également en charge le load balancing pour les protocoles TCP et UDP, en plus du HTTP/HTTPS.


## Exemple Pratique : Implémentation avec Docker Compose

Voici un exemple simple pour configurer Traefik avec du load balancing entre deux instances d'un service `whoami`.

### Fichier `docker-compose.yml`

```yaml
services:
  traefik:
    image: traefik:latest
    container_name: traefik
    command:
      - --api.insecure=true
      - --providers.docker=true
      - --entrypoints.web.address=:80
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  whoami:
    image: traefik/whoami
    container_name: whoami
    labels:
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"

  whoami-again:
    image: traefik/whoami
    container_name: whoami-again
    labels:
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"
```

### Explications :
1. Traefik comme reverse proxy :
    - Le service `traefik` est configuré pour écouter sur le port `80` et détecter dynamiquement les services grâce au provider Docker (`--providers.docker=true`).

2. Deux instances du service `whoami` :
    - Les services `whoami` et `whoami-again` sont exposés à travers le même routeur (`traefik.http.routers.whoami.rule=Host('whoami.localhost')`).
    - Traefik applique automatiquement le mécanisme de load balancing (par défaut, Round Robin) entre ces deux instances.

3. Tableau de bord Traefik :
    - Accessible via [http://localhost:8080](http://localhost:8080), il permet de visualiser les routes et les services configurés.

---

### Test du Load Balancing :

1. Lancez les conteneurs :

   ```bash
   docker-compose up --detach
   ```

2. Accédez à [http://whoami.localhost](http://whoami.localhost) dans votre navigateur ou utilisez `curl` :

   ```bash
   curl http://whoami.localhost
   ```

3. Observez que la réponse alterne entre les deux instances (`whoami` et `whoami-again`) grâce au mécanisme Round Robin.

> 🛠️ Si cela ne fonctionne pas avec Google Chrome (problème probablement lié au cache DNS ou aux connexions HTTP/2), essayez avec un autre navigateur.

## Exemple supplémentaire : Weighted Round Robin

Pour utiliser un load balancing pondéré, ajoutez des poids aux services via le label `traefik.http.services.<service_name>.loadbalancer.server.weight`.

## Modification du fichier `docker-compose.yml`

```yaml
  whoami:
     image: traefik/whoami
     container_name: whoami
     labels:
        - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
        - "traefik.http.services.whoami.loadbalancer.server.port=80"
        - "traefik.http.services.whoami.loadbalancer.server.weight=3" # Poids élevé

  whoami-again:
     image: traefik/whoami
     container_name: whoami-again
     labels:
        - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
        - "traefik.http.services.whoami.loadbalancer.server.port=80"
        - "traefik.http.services.whoami.loadbalancer.server.weight=1" # Poids faible
```

### Résultat :

Dans ce cas, `whoami` recevra environ trois fois plus de requêtes que `whoami-again`, grâce au mécanisme Weighted Round Robin.

## Autres méthodes avancées

### 1. Traffic Mirroring (Miroir de trafic)

Permet de copier une partie ou la totalité du trafic vers un autre service pour effectuer des tests en conditions réelles sans impacter la production.

Exemple :

```yaml
labels:
  - "traefik.http.middlewares.test-mirror.mirror.service=staging-service"
```

### 2. Failover (Tolérance aux pannes)

Traefik redirige automatiquement le trafic vers une autre instance si l'une des instances devient indisponible (grâce aux vérifications de santé intégrées).
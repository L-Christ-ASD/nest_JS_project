# Transformer un projet NestJS en multi-staging

Orchestration d'un environnement de développement incluant une application NestJS, un frontend, une base de données PostgreSQL, un reverse proxy Traefik et des outils de monitoring comme PgAdmin et SonarQube.

## Points positifs :  

✔ Utilisation de Traefik comme reverse proxy pour router les requêtes aux bons services.  
✔ Utilisation de depends_on avec condition: service_healthy pour s'assurer que les bases de données sont bien lancées avant d'autres services.  
✔ Définition de healthcheck pour PostgreSQL, ce qui est une bonne pratique pour éviter les erreurs de connexion.  
✔ Stockage des données avec volumes, garantissant la persistance des bases de données et des configurations.  
✔ Séparation des réseaux (nest_network, sonar_network) pour une meilleure isolation des services.

**Lancer les services:**  

Ouvrir le projet et acceder au container -> "**Reopen and build in container**"  

```bash
    docker compose up -d
```
ou alors:

```bash
    make project
```



## Accès aux services :  

Frontend → http://localhost:8085  
Backend NestJS → http://localhost:3000  
SonarQube → http://localhost:9000  
Traefik Dashboard → http://localhost:8080


**NB**:  
Traefik répond bien sur http://localhost:8080 ! 🎉

Cependant, il te redirige vers http://localhost:8080/dashboard/, donc essaie directement cette URL dans ton navigateur :

👉 http://localhost:8080/dashboard/

**Si tu n'arrives toujours pas** à voir http://localhost:8080/dashboard/ dans Firefox, voici quelques solutions :

✅ 1. Forcer un rafraîchissement complet
Essaye Ctrl + Shift + R (Windows/Linux) ou Cmd + Shift + R (Mac) pour vider le cache.

✅ 2. Tester en navigation privée
Ouvre une fenêtre privée (Ctrl + Shift + P ou Cmd + Shift + P) et teste http://localhost:8080/dashboard/.

✅ 3. Tester avec un autre navigateur
Si Firefox bloque l’accès, essaye avec Chrome ou Edge.

✅ 4. Vérifier le proxy ou le pare-feu
Si tu utilises un proxy ou un VPN, désactive-le temporairement pour tester.

✅ 5. Regarder la console du navigateur
Ouvre les outils de développement (F12 ou Ctrl + Shift + I), va dans l'onglet Console, et regarde s’il y a des erreurs.

✅ Le dashboard est accessible via curl



## Suggestions et améliorations :

✅ Sécuriser l'interface Web de Traefik
Actuellement, l'interface web de Traefik est exposée sur http://localhost:8080 avec --api.insecure=true.

### ➡ Solution:  
Désactiver cette option en production ou restreindre l'accès via un middleware.

```yaml
  traefik-proxy:
    command:
      - "--api.dashboard=true"
      - "--api.insecure=false"  # Désactiver en prod
      - "--api"
```
Ou alors, protéger avec un middleware basique d'authentification:

```yaml

      - "traefik.http.middlewares.admin-auth.basicauth.users=user:$$apr1$$YzF...$$XU..."  # Générer un mot de passe avec `htpasswd`

```
✅ **Améliorer la configuration de pgsql**  

✔ Il est préférable d'exposer PostgreSQL uniquement aux conteneurs (éviter d'exposer 5432 à l'extérieur).  
✔ Ajouter un volume explicite pour le stockage des logs si nécessaire.

✅ **Ajouter une gestion des logs pour SonarQube**  
Actuellement, SonarQube stocke ses logs dans /opt/sonarqube/logs, mais il peut être utile d'ajouter un driver de log pour Docker afin d'éviter une consommation excessive d'espace disque :

```yaml

    logging:
      driver: "json-file"
      options:
        max-size: "50m"
        max-file: "3"
```

## Résumé des améliorations proposées :  

✔ Sécuriser Traefik (--api.insecure=false et auth basique)  
✔ Ne pas exposer PostgreSQL en dehors du réseau Docker  
✔ Utiliser .env pour les mots de passe et les configurations sensibles  
✔ Limiter la taille des logs SonarQube avec logging  
✔ Ajouter un host Traefik pour le frontend.
✔ Utiliser le multi-staging pour tout les services afin de reduire la taille des image en prod.
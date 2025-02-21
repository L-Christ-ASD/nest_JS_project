# Introduction à Caddy avec Docker

## Objectifs pédagogiques
- Comprendre les caractéristiques principales de Caddy
- Maîtriser l'installation et la configuration de base de Caddy avec Docker
- Analyser le fonctionnement de l'auto-discovery avec Caddy

## Qu'est-ce que Caddy ?
Caddy est un serveur web moderne open-source qui se distingue par :
- Sa simplicité de configuration
- La gestion automatique de HTTPS
- Son extensibilité
- Une alternative moderne à Nginx et Apache

## Installation avec Docker

### Configuration de base
```bash
docker run --detach --publish 80:80 --publish 443:443 caddy
```

### Configuration avec Caddyfile
Le Caddyfile est le fichier de configuration principal de Caddy. Exemple simple :
```caddyfile
example.com {
    respond "Hello, Caddy!"
}
```

## Auto-discovery avec Caddy

### Utilisation de caddy-docker-proxy
- Basé sur le projet [`lucaslorentz/caddy-docker-proxy`](https://github.com/lucaslorentz/caddy-docker-proxy)
- Permet la détection automatique des services Docker
- Configuration via labels Docker

### Exercice pratique
1. Cloner le repository d'exemple : https://github.com/kevinganthy/poc-caddy-auto-reverse-proxy
2. Examiner la structure et les fichiers de configuration
3. Suivre les instructions du README pour la mise en place

## Avantages de Caddy
- Configuration simplifiée
- Gestion automatique des certificats SSL/TLS
- Auto-discovery des services Docker
- Idéal pour les environnements de développement et de production

## Conclusion
Caddy représente une alternative moderne aux serveurs web traditionnels, offrant une configuration simplifiée et une gestion automatisée des certificats HTTPS, particulièrement adaptée aux environnements Docker.
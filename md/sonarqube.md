# Analyse et correction d’un Dockerfile avec SonarQube

Voici un exemple de *Dockerfile* contenant des erreurs liées aux vulnérabilités mentionnées (informations d'identification codées en dur, permissions trop permissives, absence de vérification des certificats, et utilisation de protocoles SSL/TLS faibles). 

Ce fichier sera corrigé en suivant les bonnes pratiques de sécurité Docker, et analysé avec SonarQube pour identifier et résoudre les problèmes de sécurité.

```Dockerfile
# Utilisation d'une image de base sans version spécifique:
FROM ubuntu:latest

# Ajout d'informations d'identification codées en dur:
ENV DB_USER=admin
ENV DB_PASSWORD=secret123

# Installation des dépendances:
RUN apt-get update
RUN apt-get install -y curl wget openssl

# Téléchargement d'un fichier sans vérifier le certificat SSL:
RUN curl -o /app/config.json http://example.com/config.json

# Permissions trop permissives sur les fichiers de l'application:
COPY app /app
RUN chmod -R 777 /app

# Utilisation d'un protocole SSL obsolète pour une connexion sécurisée:
RUN openssl s_client -connect example.com:443 -tls1

# Exposition du port HTTP:
EXPOSE 80

# Commande pour démarrer l'application:
CMD ["python3", "/app/main.py"]
```

## Analyse avec SonarQube

- Lancement SonarQube en local avec Docker :

```bash
docker run --publish 9000:9000 sonarqube:latest
```

- Configuration d'un projet dans SonarQube à [http://localhost:9000](http://localhost:9000).
- Analyse du *Dockerfile* avec SonarScanner :

Le `Makefile` a été mis à jour pour utiliser SonarScanner et lancer l'analyse du projet Docker, en utilisant les variables d'environnement définies dans le fichier `./sonarqube/.env` :

```Makefile
ENV_FILE=.env

.PHONY: dev prod

include ./sonarqube/.env

watch:
	@echo "ENVIRONMENT=development" > $(ENV_FILE)
	@docker-compose up --build --watch

run:
	@echo "ENVIRONMENT=production" > $(ENV_FILE)
	@docker-compose up --build

sonar-scan:
	docker run \
		--rm \
		--network="host" \
		-e SONAR_HOST_URL="http://localhost:9000" \
		-e SONAR_TOKEN="$(SONAR_TOKEN)" \
		-v "./sonarqube:/usr/src" \
		sonarsource/sonar-scanner-cli \
		-Dsonar.projectKey=$(PROJECT_KEY)
```

Pour l'analyse des erreurs, on utilisera la documentation (et elle ne sera pas détaillée ici).

## Correction des erreurs

Après l'analyse avec SonarQube, on peut identifier les erreurs et les corriger dans le *Dockerfile*.

Voici le *Dockerfile* corrigé en suivant les bonnes pratiques de sécurité Docker :

```Dockerfile
# Utilisation d'une image de base avec une version spécifique:
FROM ubuntu:20.04

# Create non-root user and install dependencies:
RUN useradd -m appuser \
    && apt-get update && apt-get install -y --no-install-recommends \
        curl \
        openssl \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Application setup:
WORKDIR /app

ADD https://example.com/config.json /app/config.json

RUN chmod -R 755 /app \
    && chown -R appuser:appuser /app \
    && openssl s_client -connect example.com:443 -tls1_2

EXPOSE 80

USER appuser

CMD ["python3", "/app/main.py"]
```

Pour utiliser les variables d'environnement, celles-ci peuvent être définies à part en tant que secrets (dans le Docker Compose par exemple), et injectées dans le *Dockerfile* lors de la construction de l'image Docker.

## SonarQube Cloud

En plus de l'analyse locale (ou depuis un serveur dédié), on peut également utiliser SonarQube Cloud pour analyser le code source et les *Dockerfiles* en continu, en intégrant les outils de sécurité directement dans le pipeline CI/CD.

Pour cela, on peut configurer un projet sur SonarQube Cloud, et utiliser les outils fournis pour analyser le code source et les *Dockerfiles* à chaque commit ou à chaque *pull request*.

## Conclusion

L'analyse et la correction des *Dockerfiles* avec SonarQube permettent d'identifier et de résoudre les problèmes de sécurité liés à la configuration des conteneurs Docker, en suivant les bonnes pratiques de sécurité Docker et en utilisant des outils d'analyse statique pour détecter les vulnérabilités et les erreurs de configuration.
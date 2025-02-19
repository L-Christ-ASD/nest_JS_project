ENV-FILE=.env

include ./sonarqube/.env


watch:
	@echo "ENVIRONMENT=developpement" > ${ENV-FILE}
	@docker compose up --watch

run:
	@echo "ENVIRONMENT=production" > ${ENV-FILE}
	@docker compose up -d

sonarqube:
	@ docker compose up sonarqube sonar_db

sonar-scan:
	docker run \
    --rm \
    --network=s13-challenge_sonar_network \
    -e SONAR_HOST_URL="http://sonarqube:9000"  \
    -e SONAR_TOKEN="${SONAR_TOKEN}" \
    -v "${pwd}:/usr/src" \
    sonarsource/sonar-scanner-cli \
	-Dsonar.projectKey=${PROJECT_KEY}

project:
	@docker compose up


	

-- Crée la base de données "sonar" s'il n'existe pas
CREATE DATABASE sonar OWNER sonar;

-- Crée l'utilisateur "sonar" s'il n'existe pas
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'sonar') THEN
      CREATE ROLE sonar WITH LOGIN PASSWORD 'sonar';
      ALTER ROLE sonar CREATEDB;
   END IF;
END
$$;


-- Crée la base de données "user" s'il n'existe pas
CREATE DATABASE user OWNER user;

-- Crée l'utilisateur "user" s'il n'existe pas
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'user') THEN
      CREATE ROLE user WITH LOGIN PASSWORD 'user';
      ALTER ROLE user CREATEDB;
   END IF;
END
$$;
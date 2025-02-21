import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Permet l'accès depuis le conteneur Docker
    port: 5173, // Même port que dans docker-compose
  },
})

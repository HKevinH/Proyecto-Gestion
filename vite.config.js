import { defineConfig } from 'vite'
import laravel from 'laravel-vite-plugin'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    laravel({
      // incluye el entry principal usado por Blade
      input: ['resources/js/main.jsx'],
      refresh: true,
    }),
    react(),
  ],
})

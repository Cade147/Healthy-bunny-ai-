module.exports = {
  apps: [
    {
      name: 'health-bunny-api',
      script: 'pnpm',
      args: '-F api-server start',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      max_memory_restart: '500M',
      watch: false,
      ignore_watch: ['node_modules', 'logs', 'dist'],
    },
    {
      name: 'health-bunny-frontend',
      script: 'pnpm',
      args: '-F health-bunny preview',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
      },
      error_file: './logs/frontend-err.log',
      out_file: './logs/frontend-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      autorestart: true,
      max_memory_restart: '300M',
      watch: false,
    },
  ],
  deploy: {
    production: {
      user: 'node',
      host: 'your-server.com',
      ref: 'origin/main',
      repo: 'https://github.com/Cade147/Healthy-bunny-ai-.git',
      path: '/var/www/health-bunny',
      'post-deploy':
        'pnpm install && pnpm build && pm2 reload ecosystem.config.js --env production',
    },
  },
};

module.exports = {
  apps: [{
    name: 'getyoursite',
    script: 'yarn',
    args: 'start',
    cwd: '/app',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      HOSTNAME: '0.0.0.0'
    },
    error_file: '/var/log/pm2/getyoursite-error.log',
    out_file: '/var/log/pm2/getyoursite-out.log',
    log_file: '/var/log/pm2/getyoursite.log',
    time: true,
    kill_timeout: 5000,
    wait_ready: true,
    listen_timeout: 10000
  }]
}
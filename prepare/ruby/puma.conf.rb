# See: https://github.com/puma/puma/blob/master/docs/deployment.md#mri
workers 3 # CPU nums * 1.5
threads 5,16 # Defaults 5

bind 'tcp://0.0.0.0:5000'
bind 'unix:///tmp/puma.sock'
#bind 'unix:///tmp/puma.sock?backlog=2048'

preload_app!

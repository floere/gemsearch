listen            '0.0.0.0:8080'
pid               'tmp/pids/unicorn.pid'
preload_app       true
stderr_path       'log/unicorn.stderr.log'
stdout_path       'log/unicorn.stdout.log'
timeout           10
worker_processes  3

# After forking, the GC is disabled, because we
# kill off the workers after x requests and fork
# new ones – so the GC doesn't run.
#
# Don't disable the GC on Heroku!
#
# after_fork do |_, _|
#   GC.disable
# end
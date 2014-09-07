
@path = "/home/ec2-user/satokenta/twiume/"

worker_processes 1
working_directory @path
timeout 300
listen '/tmp/satokenta.sock'
pid "#{@path}tmp/pids/unicorn.pid"

stderr_path "#{@path}log/unicorn.stderr.log"
stdout_path "#{@path}log/unicorn.stdout.log"
preload_app true

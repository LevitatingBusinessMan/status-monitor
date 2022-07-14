require 'toml'
require 'sinatra'

$servers = TOML.load_file 'config.toml'

PORT = ENV['PORT'] || 2952

SLEEP = 1
PING_TIMEOUT = 1

set :port, PORT

threads = []
$servers.each do |server|
	threads << Thread.new do
		name = server[0]
		details = server[1]
		loop do

			`ping #{details['ip']} -c1 -W#{PING_TIMEOUT}`
			details['status'] = $?.success?
			sleep SLEEP
		end
	end
end

get '/' do
	slim :index
end

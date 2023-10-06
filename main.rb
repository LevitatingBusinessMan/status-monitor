require 'toml'
require 'sinatra'

$servers = TOML.load_file "#{__dir__}/config.toml"

PORT = ENV['PORT'] || 2952

SLEEP = 2
PING_TIMEOUT = 1

set :port, PORT

for server in $servers
	#Reshape up ports
	server[1]['ports'] = []
	for attr in server[1].keys
		if attr.start_with? 'port-'
			server[1]['ports'] << {'name'=> attr[5..], 'port' => server[1][attr], 'status' => nil}
			server[1].delete attr
		end
	end
end

threads = []
$servers.each do |server|
	threads << Thread.new do
		name = server[0]
		details = server[1]

		loop do
			`ping #{details['ip']} -c1 -W#{PING_TIMEOUT}`
			details['status'] = $?.success?

			for port in details['ports']
				`nc -z #{details['ip']} #{port['port']}`
				port['status'] = $?.success?
			end if $?.success?

			sleep SLEEP
		end
	end
end

def render_status status
	return '<td>?<\td>' if status.nil?
	"<td class=\"#{status ? 'green' : 'red'}\">#{status}</td>"
end

get '/' do
	slim :index
end

#get '/button/:server/:button'

#end

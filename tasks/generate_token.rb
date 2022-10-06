#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'net/http'
require 'puppet'
require 'uri'

def get_token(username, password)
  @uri = URI.parse('http://localhost:2754/auth')
  http = Net::HTTP.new(@uri.host, @uri.port)
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  req = Net::HTTP::Post.new(@uri.path.to_str)
  req.add_field('Content-Type', 'application/json')
  req.content_type = 'application/json'
  req.body = user_creds(username, password)
  http.request(req)
end

def user_creds(username, password)
  user = {
    'username' => username,
    'password' => password
  }
  user.to_json
end

params = JSON.parse($stdin.read)
username = params['username']
password = params['password']

begin
  result = get_token(username, password)
  puts result.body.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
# frozen_string_literal: true

require 'puppet'
require 'puppet/util'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'

# rubocop:disable Style/ClassAndModuleCamelCase
# golang_reports.rb
module Puppet::Util::Golang_Reports
  def settings
    return @settings if @settings

    @settings_file = Puppet[:confdir] + '/golang_reports_api/golang_reports.yaml'

    @settings = YAML.load_file(@settings_file)
  end

  def send_report(body)
    reports_url = settings['reports_url'] || raise(Puppet::Error, 'Must provide reports_url parameter to golang_reports class.')
    @uri = URI.parse("#{reports_url}:2754/reports/add")
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(@uri.path.to_str)
    req.add_field('Content-Type', 'application/json')
    req.content_type = 'application/json'
    req.body = body.to_json
    res = http.request(req)
    return nil unless res.body != "null\n"

    Puppet.err "could not send report to golang_reports API: #{res.body.chomp}."
  end
end

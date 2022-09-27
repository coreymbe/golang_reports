# frozen_string_literal: true

# Located in /etc/puppetlabs/puppet/modules/golang_reports/lib/puppet/reports/golang_reports.rb

require File.dirname(__FILE__) + '/../util/golang_reports.rb'

Puppet::Reports.register_report(:golang_reports) do
  desc 'Process reports via the golang_reports API.'

  include Puppet::Util::Golang_Reports
  def process
    p_report = {
      'certname' => host,
      'environment' => environment,
      'status' => status,
      'time' => time,
      'transaction_uuid' => transaction_uuid
    }
    Puppet.info 'sending report to golang_reports API.'
    send_report(p_report)
  end
end

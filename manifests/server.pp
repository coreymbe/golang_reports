# @summary Class to configure the Golang Reports API
#
# This class manages the golang-reports service.
#
# The optional parameters should be utilized when Puppet
# is not managing the PostgreSQL server.
#
# @example
#   include golang_reports::server
# @param [String] db_name
#   Default: $golang_reports::database::db_name
#   The name of the PG database.   
# @param [String] db_user
#   Default: $golang_reports::database::pg_user
#   The name of the PG user.
# @param [String] db_pass
#   Default: $golang_reports::database::pg_password
#   The PG User password.
#
class golang_reports::server (
  String $db_name = $golang_reports::database::db_name,
  String $db_user = $golang_reports::database::pg_user,
  String $db_pass = $golang_reports::database::pg_password,
) {
  file { "${settings::confdir}/golang_reports_api":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }
  file { "${settings::confdir}/golang_reports_api/golang-reports-api":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    source  => ['puppet:///modules/golang_reports/golang-reports-api'],
    before  => File['/etc/systemd/system/golang-reports.service'],
    require => File["${settings::confdir}/golang_reports_api"],
  }

  file { '/etc/systemd/system/golang-reports.service':
    ensure => file,
    source => ['puppet:///modules/golang_reports/golang-reports.service'],
  }
  file { '/etc/systemd/system/golang-reports.service.d':
    ensure  => directory,
    require => File['/etc/systemd/system/golang-reports.service'],
  }
  file { '/etc/systemd/system/golang-reports.service.d/env.conf':
    ensure  => file,
    content => epp('golang_reports/golang_reports-env.conf.epp'),
    require => File['/etc/systemd/system/golang-reports.service.d'],
    notify  => Service['golang-reports'],
  }

  service { 'golang-reports':
    ensure => running,
    enable => true,
  }
}

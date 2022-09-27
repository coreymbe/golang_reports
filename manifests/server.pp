# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include golang_reports::server
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

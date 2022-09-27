# @summary Class to configure custom report processor
#
# This class enables the custom golang_reports report processor. 
#
# @example
#   include golang_reports
# @param [String] reports_url
#   The url of the server running the Reports API is running on.
# @param [Boolean] enabled
#   Default: false
#   Set this parameter to true to enable the report processor.
#
class golang_reports (
  String $reports_url,
  Boolean $enabled = false,
) {
  if $enabled {
    Resource[pe_ini_subsetting] { 'enable golang_reports':
      ensure               => present,
      path                 => '/etc/puppetlabs/puppet/puppet.conf',
      section              => 'master',
      setting              => 'reports',
      subsetting           => 'golang_reports',
      subsetting_separator => ',',
      notify               => Service['pe-puppetserver'],
    }

    file { "${settings::confdir}/golang_reports_api":
      ensure => directory,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
    }

    file { "${settings::confdir}/golang_reports_api/golang_reports.yaml":
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0640',
      content => epp('golang_reports/golang_reports.yaml.epp'),
      require => File["${settings::confdir}/golang_reports_api"],
      notify  => Service['pe-puppetserver'],
    }
  }
}

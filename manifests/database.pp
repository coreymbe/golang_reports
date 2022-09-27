# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include golang_reports::database
class golang_reports::database (
  String $pg_user,
  String $pg_password,
  String $db_name,
) {
  class { 'postgresql::server':
    postgres_password => $pg_password,
  }
  postgresql::server::db { $db_name:
    user     => $pg_user,
    password => postgresql::postgresql_password($pg_user, $pg_password),
  }

  postgresql::server::pg_hba_rule { 'allow application network to access puppet database':
    description => 'Open up PostgreSQL for access for puppet user',
    type        => 'host',
    database    => $db_name,
    user        => $pg_user,
    address     => '0.0.0.0/0',
    auth_method => 'md5',
  }
}

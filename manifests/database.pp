# @summary Class to manage DB connection for Golang Reports API
#
# This class installs PostgreSQL and creates a DB user and database.
#
# @example
#   include golang_reports::database
# @param [String] pg_user
#   Database user to create with required permissions.
# @param [String] pg_password
#   Sets password for the postgres and $pg_user.
# @param [String] db_name
#   Name for newly created database.
#
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

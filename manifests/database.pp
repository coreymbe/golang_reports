# @summary Class to manage DB connection for Golang Reports API
#
# This class installs PostgreSQL and creates a DB user and database.
#
# @example
#   include golang_reports::database
# @param [String] pe_console
#   FQDN of PE Console for access to the DB.
# @param [String] pg_user
#   Database user to create with required permissions.
# @param [Sensitive[String]] pg_password
#   Sets password for the pg_user.
# @param [String] db_name
#   Name for newly created database.
#
class golang_reports::database (
  String $pe_console,
  String $pg_user,
  Sensitive[String] $pg_password,
  String $db_name,
) {
  class { 'postgresql::server':
  }
  postgresql::server::db { $db_name:
    user     => $pg_user,
    password => postgresql::postgresql_password($pg_user, $pg_password),
  }

  postgresql::server::pg_hba_rule { 'allow application network to access puppet database':
    description => 'Open up PostgreSQL from PE Console',
    type        => 'host',
    database    => $db_name,
    user        => $pg_user,
    address     => $pe_console,
    auth_method => 'md5',
  }
}

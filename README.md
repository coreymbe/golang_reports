# golang_reports

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
  * [Database](#database)
  * [API Server](#server)
  * [Generate JSON Web Token](#generate-jwt)
  * [Report Processor](#report-processor)
3. [Usage](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module contains an example custom Puppet processor (`golang_reports`) to send a small amount of Puppet report data to an [example API](https://github.com/coreymbe/golang-reports-api) written in Golang.

After completing the setup steps you should have an agent node running the custom Golang Reports API backed with PostgreSQL for the Primary and Compilers to ship reports to.

## Setup

### Database

Apply the database class to an agent node.

##### `golang_reports::database`
###### Parameters:
  * `$pe_console` - FQDN of the PE Console.
  * `$pg_user` - Name for new postgresql user.
  * `$pg_password` - Password for new `$pg_user`.
  * `$db_name` - Name for new database to store reports.

**Example**:

```
node 'golang-reports-api.example.com' {
  class { 'golang_reports::database':
    pg_password => Sensitive('5up3r5eCvr3p455w0rD'),
    pg_user => 'puppet',
    db_name => 'puppet',
    pe_console => 'puppet-server.example.com',
  }
}
```

Once the class has been applied you will need to run the following task from the PE Console against the agent node with the `golang_reports::database` class:

**Note**: There are three (**3**) different SQL statements to run. You can run them as 3 seperate tasks, or as a single task with a single SQL statement.

**Task**: `postgresql::sql`

  * **Parameters**:
    * **database** = (The database name used for `golang_reports::database::db_name`)
    * **host** = `127.0.0.1`
    * **password** = (The password used for `golang_reports::database::pg_password`)
    * **sql** = (See the three (**3**) statements below)
    * **user** = (The username used for `golang_reports::database::pg_user`)

```
CREATE TABLE reports ( ID SERIAL PRIMARY KEY, certname varchar(80) NOT NULL, environment varchar(40), status varchar(10) NOT NULL, time varchar(30), transaction_uuid character varying(50) NOT NULL );
```

```
CREATE TABLE users ( username varchar(20) NOT NULL, password varchar(20) NOT NULL );
```

```
INSERT INTO users (username, password) VALUES ('admin', 'ch@ngem3');
```

**Note**: The last statement contains the username and password for the API user that you will be generating a token for.

### API Server

Apply the server class to agent node running the database.

##### `golang_reports::server`
###### Parameters:
  * `$jwt_secret` - A random secure character string to use as the private key.

**Example**:

```
  class { 'golang_reports::server':
    jwt_secret => Sensitive('5up3r5eCvr3p455w0rD'),
  }
```

### Generate JWT

With the Reports API up and running, you will need to generate a JSON Web Token for authentication. This can be accomplished by running the following task from the PE Console against the agent node with the `golang_reports::server` class:


**Task**: `golang_reports::generate_token`

  * **Parameters**:
    * **username** = (The API user)
    * **password** = (The API users password)

Make note of the `access_token` value returned:

```
{"token_type":"Bearer","access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c","expires_at":"2022-10-31T23:59:59-07:00"}
```

### Report Processor

Apply the following class to your PE Primary Server & Compilers.

##### `golang_reports`
###### Parameters:
  * `$enabled` - Set to **true** to enable the report processor.
  * `$reports_url` - The hostname of Report Server (ex. `http://golang-reports-api.example.com`).
  * `$jwt` - The JSON Web Token (Created by running the `golang_reports::generate_token` task).

**Example**:

```
node 'puppet-server.example.com' {
  class { 'golang_reports':
    enabled => true,
    reports_url => 'http://golang-reports-api.example.com',
    jwt => Sensitive('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'),
  }
}
```

## Usage

You can confirm that the Reports API is functioning properly by checking the logs on the agent node with the following:

  * `journalctl -u golang-reports`

Additionally, you can review report data by running the following curl command:

  * `curl http://localhost:2754/reports`
  
## Limitations

  * Current testing of this modules usage is limited to PE 2019.8.12 on CentOS 7.

  * While this module attempts to secure password and token data with the `Sensitive` data type; ideally one would use something like [`hiera-eyaml`](https://github.com/voxpupuli/hiera-eyaml) to encrypt the values.

  * The custom report processor and API currently only support the following report data from Puppet:
    * `certname`
    * `environment`
    * `status`
    * `time`
    * `transaction_uuid`
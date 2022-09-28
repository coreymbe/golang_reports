# golang_reports

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module contains an example custom Puppet processor (`golang_reports`) to send a small amount of Puppet report data to an [example API](https://github.com/coreymbe/golang-reports-api) written in Golang.

After completing the setup steps you should have an agent node running the custom Golang Reports API backed with PostgreSQL for the Primary and Compilers to ship reports to.

## Setup

Apply the database class to an agent node.

#### `golang_reports::database`
##### Parameters:
  * `$pe_console` - FQDN of the PE Console.
  * `$pg_user` - Name for new postgresql user.
  * `$pg_password` - Password for new `$pg_user`.
  * `$db_name` - Name for new database to store reports.

Once the class has been applied you will need to run the following task from the PE Console against the agent node with the 	`golang_reports::database` class:

**Task**: `postgresql::sql`

  * **Parameters**:
    * **database** = (The database name used for `golang_reports::database::db_name`)
    * **host** = `127.0.0.1`
    * **password** = (The password used for `golang_reports::database::pg_password`)
    * **sql** = `CREATE TABLE reports ( ID SERIAL PRIMARY KEY, certname varchar(40) NOT NULL, environment varchar(40), status varchar(40) NOT NULL, time varchar(40), transaction_uuid character varying(50) NOT NULL );`
    * **user** = (The username used for `golang_reports::database::pg_user`)

Then apply the server class to agent node running the database.

#### `golang_reports::server`

---

Apply this class to your PE Primary Server & Compilers.

#### `golang_reports`
##### Parameters:
  * `$enabled` - Set to **true** to enable the report processor.
  * `$reports_url` - The hostname of Report Server (ex. `http://example.agent-node.puppet.com`).

## Usage

You can confirm that the Reports API is functioning properly by checking the logs on the agent node with the following:

  * `journalctl -u golang-reports`

Additionally, you can review report data by running the following curl command:

  * `curl http://localhost:2754/reports`
  
## Limitations

  * Current testing of this modules usage is limited to PE 2019.8.12 on CentOS 7.

  * The custom report processor and API currently only support the following report data from Puppet:
    * `certname`
    * `environment`
    * `status`
    * `time`
    * `transaction_uuid`
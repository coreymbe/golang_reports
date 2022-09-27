# golang_reports

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module contains an example custom Puppet processor (`golang_reports`) to send a small amount of Puppet report data to an [example API](https://github.com/coreymbe/golang-reports-api) written in Golang.

## Setup

Apply this class to your PE Primary Server & Compilers.

#### `golang_reports`
##### Parameters:
  * `$reports_url` - The hostname of Report Server.

---

Apply the database class to an agent node.

#### `golang_reports::database`
##### Parameters:
  * `$pg_user` - Name for new postgresql user.
  * `$pg_password` - Password for both the new user and the `postgres` user.
  * `$db_name` - Name for new database to store reports.

Once the class has been applied you will need to run the following task from the PE Console against the agent node with the 	`golang_reports::database` class:

**Task**: `postgresql::sql`

  * **Parameters**:
    * **database** = (The database name used for `golang_reports::database::db_name`)
    * **host** = `127.0.0.1`
    * **password** = (The password used for `golang_reports::database::pg_password`)
    * **sql** = `CREATE TABLE reports ( ID SERIAL PRIMARY KEY, certname varchar(40) NOT NULL, environment varchar(40), status varchar(40) NOT NULL, time varchar(40), transaction_uuid character varying(50) NOT NULL );`
    * **user** = (The username used for `golang_reports::database::pg_user`)

---

Apply the server class to agent node running the database.

#### `golang_reports::server`


## Usage

You can confirm that the Reports API is functioning properly by checking the logs on the agent node with the following:

  * `journalctl -u golang-reports`

Additionally, you can review report data by running the following curl command:

  * `curl http://localhost:2754/reports`
  
## Limitations

Currently testing of this modules usage is limited to CentOS 7.

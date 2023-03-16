# Week 4 — Postgres and RDS

## 1. Provision an RDS instance on AWS
This can be done either via the AWS website and click through the options. This is a good option if you want to learn/read more about the option you are selecting. We will provision the RDS instance using AWS cli using the code below. More about using the cli check out the documentation [AWS Create db instance](https://docs.aws.amazon.com/cli/latest/reference/rds/create-db-instance.html)

```
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username root \
  --master-user-password huEE33z2Qvl383 \
  --allocated-storage 20 \
  --availability-zone ca-central-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```



## 2. Temporarily stop an RDS instance
We temporary stop the instance as we setup the app. Using the AWS website search for RDS. On the  right hand side select the databases and choose the action to temporarily stop it. Accept the term that it will restart automatically in 7 days.


## 3. Remotely connect to RDS instance
We will connect to the RDS instance using the connection url from our AWS RDS page. This can be found on the database page under connectivity & security

```
psql psql postgresql://root:Password@cruddur-db-instance.coagm6bgrldw.us-east-1.rds.amazonaws.com:5432/cruddur
```

After a successful test we can add this to gitpod

```
export PROD_CONNECTION_URL="postgresql://root:Password@cruddur-db-instance.coagm6bgrldw.us-east-1.rds.amazonaws.com:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://root:Password@cruddur-db-instance.coagm6bgrldw.us-east-1.rds.amazonaws.com:5432/cruddur"
```

## 4. Programmatically update a security group rule
To connect our Gitpod CDE to the RDS instance we need to whitelist our IP address. This is done by adding our IP address and port 5432 on the inbound rule allowed list. 
We first need to get our Gitpod IP address. This is achieved by using the code

```
GITPOD_IP=$(curl ifconfig.me)
```
This will give us the current IP address which we can then add to our RDS instance. The issue we run to is that we get a new Gitpod address each time we launch it. To automate this process we will have to create a script to do this for us.

We first export the security group ID and security rule ID on gitpod.
```
export DB_SG_ID="sg-ID"
gp env DB_SG_ID="sg-ID"
export DB_SG_RULE_ID="sgr-ID"
gp env DB_SG_RULE_ID="sgr-ID"
```

Then we create a bash script on out bin folder that we can run to automate this 

```
aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32,Description=$GITPOD}"
```

[Modify Security Groups cli](https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-security-group-rules.html#examples)

We also add this to our gitpod.yml file to have it run everytime we launch the instance

```
    command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source "$THEIA_WORKSPACE_ROOT/backend-flask/db-update-sg-rule"

```


## 5. Operate common SQL commands
We connect to psql via the psql client cli on localhost using the command below

```
psql -Upostgres --host localhost

```

After we connect we can try out a few command

```
\x on -- expanded display when looking at data
\q -- Quit PSQL
\l -- List all databases
\c database_name -- Connect to a specific database
\dt -- List all tables in the current database
\d table_name -- Describe a specific table
\du -- List all users and their roles
\dn -- List all schemas in the current database
CREATE DATABASE database_name; -- Create a new database
DROP DATABASE database_name; -- Delete a database
CREATE TABLE table_name (column1 datatype1, column2 datatype2, ...); -- Create a new table
DROP TABLE table_name; -- Delete a table
SELECT column1, column2, ... FROM table_name WHERE condition; -- Select data from a table
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...); -- Insert data into a table
UPDATE table_name SET column1 = value1, column2 = value2, ... WHERE condition; -- Update data in a table
DELETE FROM table_name WHERE condition; -- Delete data from a table

```

To create a database we use the command below

```

createdb cruddur -h localhost -U postgres

```

Reference
[SQL COMMANDS](https://www.postgresql.org/docs/13/sql-commands.html)

## 6. Create a schema SQL file by hand
Schema is a collection of database objects associated with a database
To create one we first create a folder ```backend-flask/db``` and add ```schema.sql```

We then run the 

We can import the schema to our database by running:

```
psql cruddur < db/schema.sql -h localhost -U postgres

```


## 7. Work with UUIDs and PSQL extensions
We will use postgres to generate UUIDs. We use an extension called UUID-ossp

We add the code below to our ```schema.sql```

```
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

```

We create our table 

```
CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text,
  handle text
  cognito_user_id text,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

```

```
CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

```

We add the code below to avoid any errors

```
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

```


## 8. Write several bash scripts for database operations

We will use bash script to run task we commonly need to do. We add the script on the bin folder. We add some colour to our scripts to make it readable. We give the scripts run and execute permission by 

```chmod u+x /bin/db-file```

### db-connect
This will be used to connect to either our production database or local

```
#! /usr/bin/bash

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL

```

### db-create
To create a database we use this script
```
#! /usr/bin/bash

#echo "== db-create"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "CREATE database cruddur;"

```

### db-drop
To drop the database

```
#! /usr/bin/bash

#echo "== db-drop"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-drop"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "DROP DATABASE IF EXISTS cruddur;"

```

### db-schema-load
To load the schema

```
#! /usr/bin/bash

#echo "== db-schema-load"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"

echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path

```


### db-seed
To load seed data

```
#! /usr/bin/bash

#echo "== db-seed"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"

echo $seed_path

psql $CONNECTION_URL cruddur < $seed_path

```

### db-sessions
To check what connection we are using

```
#! /usr/bin/bash

#echo "== db-sessions"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_DB_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_DB_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"

```
### db-setup
To easily setup or reset everything in our database

```
#! /usr/bin/bash
-e # stop if it fails at any point

#echo "==== db-setup"
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}==== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"

```



## 9. Implement a postgres client for python using a connection pool
We will use the Psycopg (v3) to enable us use a pythone script to run SQL commands for our database. We install it using pip and adding it to the ```requirements.txt```

```
psycopg[binary]
psycopg[pool]

```

Then we add the code below to ``` db.py ``` on a new folder ``` backend-flask\lib\ ```

```
from psycopg_pool import ConnectionPool
import os

def query_wrap_object(template):
  sql = f"""
  (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
  {template}
  ) object_row);
  """
  return sql

def query_wrap_array(template):
  sql = f"""
  (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
  {template}
  ) array_row);
  """
  return sql

connection_url = os.getenv("CONNECTION_URL")
pool = ConnectionPool(connection_url)


```

## 10. Troubleshoot common SQL errors


## 11. Implement a Lambda that runs in a VPC and commits code to RDS


## 12. Work with PSQL json functions to directly return json from the database


## 13. Correctly sanitize parameters passed to SQL to execute
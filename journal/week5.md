# Week 5 — DynamoDB and Serverless Caching

## Data Modelling a Direct Messaging System using Single Table Design
Single Table Design is a data modelling technique in which all related data is stored in a single database table. We use it in our app to handle the messaging system. To implement a single table design in DynamoDB, each item in the table is given a partition key and a sort key .The partition key is used to distribute the data across multiple physical partitions, while the sort key is used to organize the data within each partition. 

## Implementing DynamoDB query using Single Table Design

## Provisioning DynamoDB tables with Provisioned Capacity

## Utilizing a Global Secondary Index (GSI) with DynamoDB
## Rapid data modelling and implementation of DynamoDB with DynamoDB Local



## Writing utility scripts to easily setup and teardown and debug DynamoDB data
We create utility scripts to drop tables, list-tables, scan, seed, schema-load, some conversation patterns and debug the DynamoDB data

* [Scan](/bin/ddb/scan): Used to scan items saved in the table
* [Drop](/bin/ddb/drop): It will drop the table
* [List-table](/bin/ddb/list-tables): This will list the tables names created
* [Seed](/bin/ddb/seed): Used to load see data into the table
* [Schema-load](/bin/ddb/schema-load): Create a table named ```cruddur-messages ``` 

Show Contents of a conversation and List All Conversations
* [Get-conversation](/bin/ddb/patterns/get-conversation): Show the messages od a specific conversation of a user ordered in descending order. The limit sent is 20 messages. 
* [List-conversation](/bin/ddb/patterns/list-conversations): List message groups



## Restructure the Bin Directory
We restucture our folders by moving the bin directory to the top levele and rearranging some of the folders
```
bin
  |
  |--db
  |
  |--ddb
  |
  |--rds
```
Then update the scripts on the ```Schema-load```, ```seed```, ```sessions```, ```setup``` to update the new path
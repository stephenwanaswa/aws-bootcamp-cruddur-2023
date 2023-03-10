# Week 3 — Decentralized Authentication

## Homework Tasks
1. Provision via ClickOps(Using AWS UI) a Amazon Cognito User Pool
2. Install and configure Amplify client-side library for Amazon Congito
3. Implement API calls to Amazon Coginto for custom login, signup, recovery and forgot password page
4. Show conditional elements and data based on logged in or logged out
5. Verify JWT Token server side to serve authenticated API endpoints in Flask Application


## Homework Challenge
1. Decouple the JWT verify from the application code by writing a  Flask Middleware
2. Decouple the JWT verify by implementing a Container Sidecar pattern using AWS’s official Aws-jwt-verify.js library
3. Decouple the JWT verify process by using Envoy as a sidecar https://www.envoyproxy.io/
4. Implement a IdP login eg. Login with Amazon or Facebook or Apple.
5. Implement MFA that send an SMS (text message), warning this has spend, investigate spend before considering, text messages are not eligible for AWS Credits

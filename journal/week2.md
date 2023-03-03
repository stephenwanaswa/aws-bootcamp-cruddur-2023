# Week 2 — Distributed Tracing

## Homework
1. Instrument our backend flask application to use Open Telemetry (OTEL) with
2. Honeycomb.io as the provider
3. Run queries to explore traces within Honeycomb.io
4. Instrument AWS X-Ray into backend flask application
5. Configure and provision X-Ray daemon within docker-compose and send data back to X-Ray API
6. Observe X-Ray traces within the AWS Console
7. Integrate Rollbar for Error Logging
8. Trigger an error an observe an error with Rollbar
9. Install WatchTower and write a custom logger to send application log data to - CloudWatch Log group


### HoneyComb
Rewatched the Week 1 Livestream Videos. 
I started by setting up Open telemetry. I addedd the requirement on the requirements txt on the backend using the code below
``` 
opentelemetry-api 
opentelemetry-sdk 
opentelemetry-exporter-otlp-proto-http 
opentelemetry-instrumentation-flask 
opentelemetry-instrumentation-requests
```

Next I imported the libraries in ``` ap.py``` on the backend
``` 
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
```
This was then followed by
-Initializing the tracing and exporting the data to Honeycomb
-Initializing automatic instrumentation with Flask
-Adding the environmental variable for open telemetry

I then include the honeycomb service name and api key.Also added them to gitpod
``` 
export HONEYCOMB_API_KEY=""
export HONEYCOMB_SERVICE_NAME="Cruddur"
gp env HONEYCOMB_API_KEY=""
gp env HONEYCOMB_SERVICE_NAME="Cruddur"
```
I run docker compose to start the containers. 

Honeycomb was able to receive the data

![Honecomb logs](/journal/assets/week2/Honeycomb.jpg)

Honeycomb Query

![honeyquery](/journal/assets/week2/honeycomb%20query.jpg)

### AWS X-Ray

![xray](/journal/assets/week2/xray%202.jpg)
![xraysegment](/journal/assets/week2/xray%20segments.jpg)

### Rollbar

![rollbar](/journal/assets/week2/Rollbar%20Error.jpg)

### Cloud watch

![cloudwatch](/journal/assets/week2/cloudwatch.jpg)

## Homework Challenges Work in Progress
1. Instrument Honeycomb for the frontend-application to observe network latency between frontend and backend[HARD]
2. Add custom instrumentation to Honeycomb to add more attributes eg. UserId, Add a custom span
3. Run custom queries in Honeycomb and save them later eg. Latency by UserID, Recent Traces

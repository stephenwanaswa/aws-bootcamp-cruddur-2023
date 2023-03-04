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

I started by setting up Open telemetry.OpenTelemetry is a collection of vendor-neutral tools, APIs, and SDKs that are Used to instrument, generate, collect, and export telemetry data to help you analyze your software’s performance and behavior.Read more from their [Documentations](https://opentelemetry.io/docs/)

Started by Installing the required packages.

I added the required packages on the requirements txt on the backend using the code below on the [app.py](/backend-flask/app.py)
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
This was then followed by Initializing the tracing
Created a new tracer provider and register instrumentation libraries
  
  ``` 
 provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
```
  
Initializing automatic instrumentation with Flask
``` 
app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
```

I also had to create a custom span on the home activities

On the honeycomb dashboard I created an environment for Cruddur and got the api key

I then include the honeycomb service name and api key.Also added them to gitpod
``` 
export HONEYCOMB_API_KEY=""
export HONEYCOMB_SERVICE_NAME="Cruddur"
gp env HONEYCOMB_API_KEY=""
gp env HONEYCOMB_SERVICE_NAME="Cruddur"
```
On the docker compose I added the environmental variables for open telemetry

``` 
OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
OTEL_SERVICE_NAME: "${HONEYCOMB_SERVICE_NAME}"
```
I run docker compose to start the containers. Then accessed the homepage a couple of time to send some data.

Honeycomb was able to receive the data

![Honecomb logs](/journal/assets/week2/Honeycomb.jpg)

Honeycomb Query page

![honeyquery](/journal/assets/week2/honeycomb%20query.jpg)

### AWS X-Ray

![xray](/journal/assets/week2/xray%202.jpg)
![xraysegment](/journal/assets/week2/xray%20segments.jpg)

### Rollbar
Started by adding the required dependancies on the requirements.txt and installed them on the backend

```
blinker
rollbar
```

On rollbar I created a new project and got the access token.I set this in the dev environment and added them to gitpod.
```
export ROLLBAR_ACCESS_TOKEN=""
gp env ROLLBAR_ACCESS_TOKEN=""
```

This is also added to the Docker compose yaml

```
ROLLBAR_ACCESS_TOKEN: "${ROLLBAR_ACCESS_TOKEN}"
```

Next I imported the libraries on app.py

``` 
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception
```

In the flask application I add the code below to initialize rollbar to capture and report exception to rollbar
``` 
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
@app.before_first_request
def init_rollbar():
    """init rollbar module"""
    rollbar.init(
        # access token
        rollbar_access_token,
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app)
```

I added a custom instrumentation to capture additional data on rollbar
 ```
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
```   
I ran docker compose to start up the app and accessed the backend and the rollbar endpoint to generate some activity.
I was able to get the data on rollbar

![rollbar](/journal/assets/week2/Rollbar%20Error.jpg)

### Cloud watch

![cloudwatch](/journal/assets/week2/cloudwatch.jpg)

## Homework Challenges Work in Progress
1. Instrument Honeycomb for the frontend-application to observe network latency between frontend and backend[HARD]
2. Add custom instrumentation to Honeycomb to add more attributes eg. UserId, Add a custom span
3. Run custom queries in Honeycomb and save them later eg. Latency by UserID, Recent Traces

require 'aws-sdk-s3'
require 'json'
require 'jwt'

def handler(event:, context:)
  puts event
  # return cors headers for preflight check
  if event['routeKey'] == "OPTIONS /{proxy+}"
    puts({step: 'preflight', message: 'preflight CORS check'}.to_json)
    { 
      headers: {
        "Access-Control-Allow-Headers": "*, Authorization",
        "Access-Control-Allow-Origin": "https://3000-stephenwana-awsbootcamp-0wppcs5dp0n.ws-eu96b.gitpod.io",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
      },
      statusCode: 200,
    }
  else
    # Check if the event object contains the required keys
    if event['headers'] && event['headers']['authorization']
      token = event['headers']['authorization'].split(' ')[1]
      puts({step: 'presignedurl', access_token: token}.to_json)

      body_hash = JSON.parse(event["body"])
      extension = body_hash["extension"]

      decoded_token = JWT.decode token, nil, false
      cognito_user_uuid = decoded_token[0]['sub']

      s3 = Aws::S3::Resource.new
      bucket_name = ENV["UPLOADS_BUCKET_NAME"]
      object_key = "#{cognito_user_uuid}.#{extension}"

      puts({object_key: object_key}.to_json)

      obj = s3.bucket(bucket_name).object(object_key)
      url = obj.presigned_url(:put, expires_in: 60 * 5)
      url # this is the data that will be returned
      body = {url: url}.to_json
      { 
        headers: {
          "Access-Control-Allow-Headers": "*, Authorization",
          "Access-Control-Allow-Origin": "https://3000-stephenwana-awsbootcamp-0wppcs5dp0n.ws-eu96b.gitpod.io",
          "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
        },
        statusCode: 200, 
        body: body 
      }
    else
      # Return an error response if the required keys are not present in the event object
      {
        statusCode: 400,
        body: "Missing required headers"
      }
    end
  end # if 
end # def handler


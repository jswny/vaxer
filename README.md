# Vaxer

A vaccine finder which can alert you using SMS when vaccines are available

## Supported Sources

- CVS

## Environment Variables

**Note**: all phone numbers should be in the form `+1XXXXXXXXXX` for US numbers.

- `DELAY`: delay in MS in between checks, defaults to 10 minutes. The first check is done 1 minute after startup, then the delay is used.
- `TWILIO_ACCOUNT_SID`: for your Twilio account
- `TWILIO_AUTH_TOKEN`: for your Twilio account
- `TWILIO_PHONE_NUMBER`: the Twilio phone number to send SMS from using your account
- `NOTIFICATION_PHONE_NUMBERS`: a comma-separated list of phone numbers to message when a vaccine is available
- `STATE_ABBREVIATION`: the two-letter abbreviation of the state to check, such as `MA`
- `ZIP_CODE`: the zip code to check for vaccination locations near. If this is set, locations will be searched within 50 miles. Otherwise, any location in the state will be returned if vaccines are available.

## Running

1. Create a `.env` file with the following environment variables:

```shell
TWILIO_ACCOUNT_SID=<fill>
TWILIO_AUTH_TOKEN=<fill>
TWILIO_PHONE_NUMBER=<fill>
NOTIFICATION_PHONE_NUMBERS=<fill>
STATE_ABBREVIATION=<fill>
ZIP_CODE=<fill>
```

2. Run the app with `docker-compose up` or `docker-compose up -d` for detatched mode

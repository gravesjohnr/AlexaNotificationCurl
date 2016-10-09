# AlexaNotificationCurl
Some curl scripts to allow interfacing with Alexa using text as input.

<h2>Demo</h2>
<a href="https://youtu.be/WLPApYslQVM">https://youtu.be/WLPApYslQVM</a>

I'm using this along with OpenCV to do face recognition and then let me know who is at the front door:
"Simon says, Joe is at the front door."

Initially, I just used my Alexa bluetooth and espeak (very bad sound), but I wanted it to sound like Alexa.  So, I wrote this...

<h2>Credits</h2>
Motivated by Miguel Mota
<a href="https://miguelmota.com/blog/alexa-voice-service-with-curl">https://miguelmota.com/blog/alexa-voice-service-with-curl</a>

<h2>The way this works:</h2>
- The text given to alexa.sh is converted into an wav file and sent to the alexa voice service.
- The response is then piped to a 'play' command (espeak) to give the response.

<h2>Requirements:</h2>
You will need
- curl
- sox (Ubuntu packages: sox libsox-fmt-mp3)
- pico2wav (Ubuntu package: libttspico-utils)
- espeak (Not used in current version)
NOTE: You could change the alexa.sh to use a different speech module, but I've found pico2wav to be pretty good.

<h2>How to use:</h2>

1. Follow the instructions from Miguel here:
<a href="https://miguelmota.com/blog/alexa-voice-service-authentication">https://miguelmota.com/blog/alexa-voice-service-authentication/</a>
This sets up the service authentication.
2. Replace the CLIENT_ID in the auth_code.sh file
3. Run auth_code.sh (./auth_code.sh)
4. Copy/paste the given URL into a browser and login to your amazon account
5. Look for the code= in the authresponse in the url of the 'failed' webpage
6. Replace CLIENT_ID, CLIENT_SECRET, and CODE in the auth_token.sh file
7. Run the auth_token.sh (./auth_token.sh)

If all goes well, you will then have two files: token.dat and refresh.dat

For the next hour, you will be able to run the alexa.sh command.  If an hour passes, you'll need to run the refresh_token.sh, then run alexa.sh
NOTE: Be sure to update refresh_token.sh with your CLIENT_ID and CLIENT_SECRET

I setup the refresh_token.sh to run every hour in cron, then I don't worry about it again.

<b>Note:</b> The steps 1-7 above should only be needed once.  The refresh_token should be able to keep an active token from that point on.

<h2>Sample:</h2>
./alexa.sh "Tell me a joke"

<h2>Troubleshooting:</h2>
Look at the various log files for errors.  Also, I 'tee' out the audio sent and audio response.

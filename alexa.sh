############################################################
# First we creat a bunch of variables to hold data.
############################################################
QUESTION=${1}

# Auth token (replace with yours).
TOKEN=`cat token.dat`

# Boundary name, must be unique so it does not conflict with any data.
BOUNDARY="BOUNDARY1234"
BOUNDARY_DASHES="--"

# Newline characters.
NEWLINE='\r\n';

# Metadata headers.
METADATA_CONTENT_DISPOSITION="Content-Disposition: form-data; name=\"metadata\"";
METADATA_CONTENT_TYPE="Content-Type: application/json; charset=UTF-8";

# Metadata JSON body.
METADATA="{\
\"messageHeader\": {},\
\"messageBody\": {\
\"profile\": \"alexa-close-talk\",\
\"locale\": \"en-us\",\
\"format\": \"audio/L16; rate=16000; channels=1\"\
}\
}"

# Audio headers.
AUDIO_CONTENT_TYPE="Content-Type: audio/L16; rate=16000; channels=1";
AUDIO_CONTENT_DISPOSITION="Content-Disposition: form-data; name=\"audio\"";

############################################################
# Then we start composing the body using the variables.
############################################################

# Compose the start of the request body, which contains the metadata headers and
# metadata JSON body as the first part of the multipart body.
# Then it starts of the second part with the audio headers. The binary audio
# will come later as you will see.
POST_DATA_START="
${BOUNDARY_DASHES}${BOUNDARY}${NEWLINE}${METADATA_CONTENT_DISPOSITION}${NEWLINE}\
${METADATA_CONTENT_TYPE}\
${NEWLINE}${NEWLINE}${METADATA}${NEWLINE}${NEWLINE}${BOUNDARY_DASHES}${BOUNDARY}${NEWLINE}\
${AUDIO_CONTENT_DISPOSITION}${NEWLINE}${AUDIO_CONTENT_TYPE}${NEWLINE}"

# Compose the end of the request body, basically just adding the end boundary.
POST_DATA_END="${NEWLINE}${NEWLINE}${BOUNDARY_DASHES}${BOUNDARY}${BOUNDARY_DASHES}${NEWLINE}"

############################################################
# Now we create a request body file to hold everything including the binary audio data.
############################################################

# Write metadata to a file which will contain the multipart request body content.
echo -e $POST_DATA_START > multipart_body.txt

# Here we append the binary audio data to request body file
# by spitting out the contents. We do it this way so that
# the encoding do not get messed with.
#cat $AUDIO_FILENAME >> multipart_body.txt
echo "Question: ${QUESTION}"
echo "Creating voice..."
#espeak -v en-us "${QUESTION}" --stdout | tee espeak.out | sox - -c 1 -r 16000 -e signed -b 16 -t wav - >> multipart_body.txt
rm /tmp/pipe.wav
ln -s /dev/stdout /tmp/pipe.wav
pico2wave -w /tmp/pipe.wav "${QUESTION}" | tee pico2wav.wav | sox - -c 1 -r 16000 -e signed -b 16 -t wav - >> multipart_body.txt

# Then we append closing boundary to request body file.
echo -e $POST_DATA_END >> multipart_body.txt

############################################################
# Finally we get to compose the cURL request command
# passing it the generated request body file as the multipart body.
############################################################

# Compose cURL command and write to output file.
echo "Making request..."
curl -s -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: multipart/form-data; boundary=${BOUNDARY}" \
  --data-binary @multipart_body.txt \
  https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize \
  | perl -pe 'BEGIN{undef $/;} s/--.*Content-Type: audio\/mpeg.*(ID3.*)--.*--/$1/smg' \
  | tee response.mp3 | play -t mp3 -q -

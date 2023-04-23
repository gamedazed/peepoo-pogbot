# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch and record the live stream. Once the stream finishes, it downloads chat and renders it. That final product is placed in a Google Cloud Storage bucket and a discord notification is generated once finalized. The product of both renders are concatenated creating a UX similar to lurking for the live stream. 

The serverless design has been tabled in favor of a more viable MVP. I may get back to it, but not holding my breath right now.

Dependencies:
WWW::Twitch
Parallel::ForkManager
WWW::Mechanize::Chrome
WebService::Discord::Webhook

The logic is there for adapting this, but making this a shippable product isn't the idea right now.

------------------------------------------------------------------------------------------------------

If you have a Twitch subscription to someone you're watching with this, you can follow these simple steps to get the same benefits through the script. It's easiest if you use Firefox (even if only once) to login to Twitch, and with the browser still open, run the following in a terminal from this repo's directory:

```
sqlite3 -separator '    ' [!! Enter path to mozilla cookies !!]/cookies.sqlite <<- EOF > ./cookies.sqlite
.mode tabs
.header off
select host,
case substr(host,1,1)='.' when 0 then 'FALSE' else 'TRUE' end,
path,
case isSecure when 0 then 'FALSE' else 'TRUE' end,
expiry,
name,
value
from moz_cookies;
EOF
```

If you're using Windows (I think Vista and later adopted this structure?) you can find you mozilla cookies relative to the WSL instance `/mnt/c/Users/$(wslvar USERNAME)/AppData/Roaming/Mozilla/Firefox/Profiles/*/cookies.sqlite`, from that point until the cookie expires this script will have a replica of your own browser's sessions for the purposes of avoiding ads.


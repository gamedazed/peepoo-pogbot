# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch. This has been refactored significantly with the intent of running this in a serverless environment. It's a fully containerized solution now, a perl script manages the polling for streamers and program logic, it kicks off yt-dlp to record the stream and twitch-chat-dumper to record the twitch-chat as json in such a way that it can be rendered into a video using twitch-downloader-cli, and finally the twitch chat and twitch stream are joined together with the help of ffmpeg.

You can have several streamers you record with a single instance of this script, but each streamer is given a dedicated polling process so one streamer's liveness doesn't take away from another's being noticed. Too many streamers will, however, cause an increasingly heavy load on your host. If you're noticing a taxing load from the script, try removing some streamers from the list. Similarly, the final encoding stage is configured to use GPU passthrough for combining chat and video, if this is problemsome by accounts of load or hardware availability, I suggest switching that container for a standard ffmpeg.

Though not ready to be implemented for a wider audience yet, the script will move the finished vods to a Google Cloud Storage bucket upon finishing with encoding. The project currently uses a Docker-in-Docker design, which I must admit I was only able to get working under a root user, I am still deciding between creating a new container specifically for the mount point and creating a new user in the container running the perl script.

I don't know how often I'll be able to work on this, I'd like to get it in a state more capable of distribution, but in case someone else finds it helpful/useful in its current stage, I figure why not make it public.

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


# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch. This is still roughly beta phase. Not sure if I'll put any effort into parameterization, depends on whether there's an apetite for it or not.

- Transcoding Extraordinaire: ffmpeg    (cheers erupt, the crowd's going wild!)

- Downloading Live Stream => yt-dlp

- Rendering Chat => (to come) uses a websocket, will probably keep this native Perl, this pulls down the JSON which can be rendered via ffmpeg by TwitchDownloaderCLI

- Detecting Live state of streamer => WWW:Twitch module

- Managing parent/child-processes and message queues => Parallel::ForkManager

- Redundancy and Scaling => Docker, or your containerization platform of choice

- Storage and Distribution => Google Cloud Storage buckets mounted to the container using gcsFuse

---------------------------------------------------------------------------------------


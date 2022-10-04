# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch. The channels defined are currently coded in, but that'll open up to configuration in future iterations. This is still roughly alpha phase. 

- Transcoding Extraordinaire: ffmpeg    (cheers erupt, the crowd's going wild!)

- Downloading Live Stream => yt-dlp

- Rendering Chat => TwitchDownloaderCLI (VOD) | not sure yet (Live) [ probably bot ]

- Detecting Live state of streamer => WWW:Twitch module

- Managing parent/child-processes and message queues => Parallel::ForkManager

---------------------------------------------------------------------------------------

While I can accomplish all of this with VODs, development is still in progress for live streams.


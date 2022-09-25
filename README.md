# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch. The channels defined are currently coded in, but that'll open up to configuration in future iterations. This is still roughly alpha phase. 

- Transcoding Extraordinaire: ffmpeg    (cheers erupt, the crowd's going wild!)

- Downloading Live Stream => youtube-dl

- Rendering Chat => TwitchDownloaderCLI

- Detecting Live state of streamer => WWW:Twitch module

- Managing parent/child-processes and message queues => Parallel::ForkManager

---------------------------------------------------------------------------------------

### Criteria

- Capture live recording, beginning as early as possible from when the streamer starts.
    
    * I don't think this needs to be part of MVP design but redundancy and recovery from crashes *will* be a thing

    * Aethel tends to warm the castle gates for about 15m at intro, somewhat curiously those first 15 minutes are potentially the most important ones for this project.

        * The script knowing when Aethel (or another streamer) goes live is therefore the true battle. Webhooks are too slow, by the time the live notification hits discord, or X comms platform, waits for your webhook to poll, then delivers the message, and the recording actually starts - well, I think ~5m loss is a reasonable average to presume is lost with that method.

------------------------------------------------------------------------------------------


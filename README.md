# Recording Twitch Streams

This tool is designed to poll for liveness from a streamer on Twitch and record the live stream. Once the stream finishes, it downloads chat and renders it. That final product is placed in a Google Cloud Storage bucket and a discord notification is generated once finalized. The product of both renders are concatenated creating a UX similar to lurking for the live stream. 

The serverless design has been tabled in favor of a more viable MVP. I may get back to it, but not holding my breath right now.

Dependencies:

* [WWW::Twitch](https://metacpan.org/pod/WWW::Twitch)

* [Parallel::ForkManager](https://metacpan.org/pod/Parallel::ForkManager)

* [WWW::Mechanize::Chrome](https://metacpan.org/pod/WWW::Mechanize::Chrome)

* [WebService::Discord::Webhook](https://metacpan.org/pod/WebService::Discord::Webhook)

The logic is there for adapting this to a lot of different implementations, but making this a shippable product isn't the idea right now.

------------------------------------------------------------------------------------------------------

If you have a Twitch subscription to someone you're watching with this, for the purposes of avoiding ads, run cookie_monster.pl with a firefox instance open. Note that you must have a cached login to Twitch from firefox for that to work.


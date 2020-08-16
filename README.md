# BlogParser
Script to parse the latest post on my blog and check if it's new enough to be automatically pushed to Mastodon. Leverages a local file for the "watermark" on the previous post. It also stores configuration information (Mastodon instance, Mastodon API key, and blog RSS feed) in a configuration file. If the configuration file is missing, or if any of the 3 pieces required of it are missing, then running the script will trigger an interactive mode to provide the information.

The script was designed with my own blog, but should work for any blog that leverages the [default Hugo feed format](https://github.com/gohugoio/hugo/blob/master/tpl/tplimpl/embedded/templates/_default/rss.xml). Other formats could likely be used with minor tweaking of the `xmllint` sequence.

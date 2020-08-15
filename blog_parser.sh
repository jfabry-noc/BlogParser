#!/bin/bash
# Verify a URL was passed.
if (( $# != 1 )); then
    echo "The index file must be passed as a parameter!"
    exit
fi

# Get the most recent post title, link, and date.
POST_TITLE=$(curl -s $1 | xmllint --xpath "//rss/channel/item/title/text()" - | head -1)
POST_LINK=$(curl -s $1 | xmllint --xpath "//rss/channel/item/link/text()" - | head -1)
POST_DATE=$(curl -s $1 | xmllint --xpath "//rss/channel/item/pubDate/text()" - | head -1)


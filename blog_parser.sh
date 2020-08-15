#!/bin/bash
# Define some files we'll use.
WATERMARK="./watermark.txt"

# Verify a URL was passed.
if (( $# != 1 )); then
    echo "The index file must be passed as a parameter!"
    exit
fi

# Get the most recent post title, link, and date.
#POST_TITLE=$(curl -s $1 | xmllint --xpath "//rss/channel/item/title/text()" - | head -1)
#POST_LINK=$(curl -s $1 | xmllint --xpath "//rss/channel/item/link/text()" - | head -1)
#POST_DATE=$(curl -s $1 | xmllint --xpath "//rss/channel/item/pubDate/text()" - | head -1)

# Compare the date to the watermark.
POST_DATE="Mon, 10 Aug 2020 00:00:00 +0000"
if [ -f "$WATERMARK" ]; then
    # Get the stored watermark.
    WATERMARK_VALUE=$(cat $WATERMARK)

    # Make sure it actually contained something.
    if [ -n "${WATERMARK_VALUE}" ]; then
        # Compare the two.
        if [[ "$WATERMARK_VALUE" == "$POST_DATE" ]]; then
            echo "Nothing to do!"
        else
            echo "We need to post to Masto!"
        fi
    else
        # Post to Masto because the watermark is blank.
        echo "We need to post to Masto!"
    fi
else
    # Post to Masto because there is no watermark file.
    echo "We need to post to Masto!"
fi

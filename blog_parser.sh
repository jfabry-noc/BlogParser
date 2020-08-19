#!/bin/bash
# Function to handle posting to Mastodon.
masto_post() {
    # Parse together the post content.
    local POST_CONTENT="$POST_TITLE\n\n$POST_LINK"
    local FORMATTED_CONTENT=$(echo -e "$POST_CONTENT")
    local FULL_URL=$(echo "$MASTO_INSTANCE/api/v1/statuses")

    # Make the post via curl.
    curl -s -X POST -H "Authorization: Bearer $MASTO_KEY" \
        --form "status=$FORMATTED_CONTENT" \
        $FULL_URL > /dev/null
}

# Get to the expected directory.
cd /home/john/code/BlogParser

# Define variables.
WATERMARK="./watermark.txt"
UPDATE_WATERMARK=false
CONFIG_FILE="./config.sh"

# Make sure xmllint is installed.
XMLLINT_PATH=$(which xmllint 2> /dev/null)
if [[ -z $XMLLINT_PATH ]]; then
    echo "xmllint is missing from this system."
    exit
fi

# Check for the configuration file.
if [ ! -f $CONFIG_FILE ]; then
    # Start the interactive prompt for user information.
    echo "Enter your Mastodon instance."
    echo -n "> "
    read MASTO_INSTANCE
    echo "Enter your Mastodon key."
    echo -n "> "
    read MASTO_KEY
    echo "Enter your RSS feed."
    echo -n "> "
    read RSS_PATH

    # Save in a file for future use.
    echo "MASTO_INSTANCE=$MASTO_INSTANCE" > $CONFIG_FILE
    echo "MASTO_KEY=$MASTO_KEY" >> $CONFIG_FILE
    echo "RSS_PATH=$RSS_PATH" >> $CONFIG_FILE
else
    # Import the file.
    source $CONFIG_FILE

    # Verify there are values for all 3 variables.
    if [ -z "$MASTO_INSTANCE" ]; then
        echo "Enter your Mastodon instance."
        echo -n "> "
        read MASTO_INSTANCE
        echo "MASTO_INSTANCE=$MASTO_INSTANCE" >> $CONFIG_FILE
    fi

    if [ -z "$MASTO_KEY" ]; then
        echo "Enter your Mastodon key."
        echo -n "> "
        read MASTO_KEY
        echo "MASTO_KEY=$MASTO_KEY" >> $CONFIG_FILE
    fi

    if [ -z "$RSS_PATH" ]; then
        echo "Enter your RSS feed."
        echo -n "> "
        read RSS_PATH
        echo "RSS_PATH=$RSS_PATH" >> $CONFIG_FILE
    fi
fi

# Get the most recent post title, link, and date.
POST_TITLE=$(curl -s $RSS_PATH | xmllint --xpath "//rss/channel/descendant::item[1]/title/text()" -)
POST_LINK=$(curl -s $RSS_PATH | xmllint --xpath "//rss/channel/descendant::item[1]/link/text()" -)
POST_DATE=$(curl -s $RSS_PATH | xmllint --xpath "//rss/channel/descendant::item[1]/pubDate/text()" -)

# Compare the date to the watermark.
if [ -f "$WATERMARK" ]; then
    # Get the stored watermark.
    WATERMARK_VALUE=$(cat $WATERMARK)

    # Make sure it actually contained something.
    if [ -n "${WATERMARK_VALUE}" ]; then
        # Compare the two.
        if [[ ! "$WATERMARK_VALUE" == "$POST_DATE" ]]; then
            UPDATE_WATERMARK=true
        fi
    else
        # Post to Masto because the watermark is blank.
        UPDATE_WATERMARK=true
    fi
else
    # Post to Masto because there is no watermark file.
    UPDATE_WATERMARK=true
fi

# Check if the watermark needs to be updated and if the post needs to be pushed.
if [[ "$UPDATE_WATERMARK" == true ]]; then
    masto_post
    echo $POST_DATE > $WATERMARK
fi

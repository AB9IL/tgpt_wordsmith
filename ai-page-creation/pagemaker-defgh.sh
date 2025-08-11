#!/bin/bash

# Copyright (c) 2025 by Philip Collier, github.com/AB9IL
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version. There is NO warranty; not even for
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script reads topical information and several subtoical items to
# create a prompt and generate html suitable for insertion in live web
# pages. It uses golang based tgpt.

# This script is intended for creation of deep, thousand word pages, each
# on a specific topic but covering the "items"" in relation to the various
# main topics.
#
#  For example, a list of "pizza restaurants" for topics and a list of
#  pizza aspects for coverage on each page: pepperoni, supreme, corn-and-peppers,
#  and so forth.
#
#  To round out a website, you should prepare dozens of pairs of topic and items
#  files!

SITE_CODE="defgh"
PROV_NAME="phind"
PROMPT_SOURCES=(misc/"$SITE_CODE"-misc/group*)
OUTPUTPATH="finished-pages/$SITE_CODE"
TOPICS_FILE="topics"                          # broader subject to discuss
ITEMS_FILE="items"                            # more specific topics
TOP_DATA="$(<misc/$SITE_CODE-misc/top)"       # generic top of page
BOTTOM_DATA="$(<misc/$SITE_CODE-misc/bottom)" # generic bottom of page
TGPT_PATH="/usr/local/src/gotgpt/tgpt-linux-amd64"

###############################################################################
# DRAGONS BELOW!
###############################################################################

# put a link to tgpt into the path if not already existing
[ -z "$(which tgpt)" ] && ln -sf $TGPT_PATH "$HOME"/.local/bin/tgpt
export TGPT="tgpt"

# create an output directory if it does not exist
[ -d "$OUTPUTPATH" ] || mkdir $OUTPUTPATH

for SOURCE in "${PROMPT_SOURCES[@]}"; do
    # read topics and items
    IFS=$'\n' read -rd '' -a TOPICS <<<"$(\cat "$SOURCE"/"$TOPICS_FILE")"
    IFS=$'\n' read -rd '' -a ITEMS <<<"$(\cat "$SOURCE"/"$ITEMS_FILE")"
    S=1 # sequence number
    for K in "${TOPICS[@]}"; do
        TIME="$(date +"%Y-%m-%d_%H-%M-%S")" #timestamp
        echo -e "\n$TOP_DATA" >"${OUTPUTPATH}/${TIME}-${S}.html"
        for Q in "${ITEMS[@]}"; do
            echo "Working on $K and $Q"
            PROMPT="You will create HTML body text for an existing page; do not
            create any <head> or <h1> elements. Find recent information about $K with
            emphasis and details on $Q, and create HTML formatted text. Follow a narrative
            (storytelling) style. Use <h3> headers, bold, and italic text for emphasis,
            where appropriate. Avoid emdashes and bullet
            points."

            CONTENT="$($TGPT --provider "${PROV_NAME}" "${PROMPT}")"
            echo -e "\n$CONTENT\n" >>"${OUTPUTPATH}/${TIME}-${S}.html"
        done
        echo -e "\n$BOTTOM_DATA" >>"${OUTPUTPATH}/${TIME}-${S}.html"
        ((S++))
    done
done

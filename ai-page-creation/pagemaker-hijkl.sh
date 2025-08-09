#!/bin/bash

# Copyright (c) 2025 by Philip Collier, github.com/AB9IL
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version. There is NO warranty; not even for
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script reads topical information, creates a prompt and generates
# html suitable for insertion in live web pages. It uses golang based
# tgpt.

PROV_NAME="pollinations"
OUTPUTPATH="output"
TOPICS_FILE="hijkl-misc/topics" # broader subject to discuss
ITEMS_FILE="hijkl-misc/items"   # more specific topic
TOP_DATA="$(<misc/hijkl-misc/top)"
BOTTOM_DATA="$(<misc/hijkl-misc/bottom)"
export TGPT="/usr/local/src/gotgpt/tgpt-linux-amd64"

IFS=$'\n' read -rd '' -a ITEMS <<<"$(\cat "$ITEMS_FILE")"
IFS=$'\n' read -rd '' -a TOPICS <<<"$(\cat "$TOPICS_FILE")"

for K in "${TOPICS[@]}"; do
    for Q in "${ITEMS[@]}"; do
        TIME="$(date +"%Y-%m-%d_%H-%M-%S")"
        echo "Working on $K and $Q"
        PROMPT="You will create HTML body text for an existing page; do not
        create any <head> or <h1> elements. Find recent information about $K with
        emphasis and details on $Q, and create HTML formatted text. Start your text with
        <h2>$Q Timeline of Gaffes</h3>."

        CONTENT="$($TGPT --provider "${PROV_NAME}" "${PROMPT}")"
        echo -e "$TOP_DATA\n$CONTENT\n$BOTTOM_DATA" >"${OUTPUTPATH}/${TIME}.html"
    done
done

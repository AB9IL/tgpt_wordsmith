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
TOPICS_FILE="defgh-miscc/topics" # broader subject to discuss
ITEMS_FILE="defgh-misc/items"    # more specific topic
TOP_DATA="$(<misc/defgh-misc/top)"
BOTTOM_DATA="$(<misc/defgh-misc/bottom)"
export TGPT="/usr/local/src/gotgpt/tgpt-linux-amd64"

IFS=$'\n' read -rd '' -a ITEMS <<<"$(\cat "$ITEMS_FILE")"
IFS=$'\n' read -rd '' -a TOPICS <<<"$(\cat "$TOPICS_FILE")"

for K in "${TOPICS[@]}"; do
    for Q in "${ITEMS[@]}"; do
        TIME="$(date +"%Y-%m-%d_%H-%M-%S")"
        echo "Working on $K and $Q"
        PROMPT="Write a comprehensive HTML formatted page about $K with emphasis on $Q.
        Use bold and italic text for emphasis, where appropriate."

        CONTENT="$($TGPT --provider "${PROV_NAME}" "${PROMPT}")"
        echo -e "$TOP_DATA\n$CONTENT\n$BOTTOM_DATA" >"${OUTPUTPATH}/${TIME}.html"
    done
done

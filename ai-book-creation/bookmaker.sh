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

export PROV_NAME="phind"
export BOOKDATA=(book-*)
TGPT_PATH="/usr/local/src/gotgpt/tgpt-linux-amd64"

###############################################################################
# DRAGONS BELOW!
###############################################################################

# put a link to tgpt into the path if not already existing
[ -z "$(which tgpt)" ] && ln -sf $TGPT_PATH "$HOME"/.local/bin/tgpt
export TGPT="tgpt"

make_chapter() {
    # 1 - sequentially read notes within each chapter
    # 2 - create content and APPEND to the chapter text
    X=1
    for K in "$CHAPTER"/*; do
        DELAY="$((RANDOM % 9 + 1))"
        # TIME="$(date +"%Y-%m-%d_%H-%M-%S")"
        echo "Working on $CHAPTER and item $X"
        read -rd '' NOTE <<<"$(\cat "$K")"

        PROMPT="Create an essay in plain text according to the following criteria:
        1) formatted in paragraphs, 2) styled in a narrative (storytelling)
        format, 3) avoid numbered or bullet pointed lists, 4) focus on
        subject matter in the following markdown formatted snippet: $NOTE"

        # random delay befor querying AI service
        sleep "$DELAY"
        CONTENT="$("$TGPT" --provider "${PROV_NAME}" "${PROMPT}")"

        # append results to the chapter
        echo -e "$CONTENT" >>"output/${CHAPTER}".txt
        ((X++))
    done
}
export -f make_chapter

for BOOK in "${BOOKDATA[@]}"; do
    echo -e "\nWorking on $BOOK ...\n"
    CHAPTERS=("$BOOK"/*)
    for CHAPTER in "${CHAPTERS[@]}"; do
        export CHAPTER
        [ -d "output/$BOOK" ] || mkdir "output/$BOOK"
        sem -j 4 make_chapter
    done
    echo -e "Book $BOOK complete!\n"
done
echo -e "All boks complete! \n"

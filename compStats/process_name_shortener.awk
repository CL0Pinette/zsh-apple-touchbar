#!/usr/bin/awk -f

#  Shortens the first word of every line so has at most 12 characaters. If it has more than 12, it takes the first 9
#  characters and adds an ellipse to the end
BEGIN {
    maxCharacters = 12
    shortenLength = 9
}
{
    processLength = length($1)
    if (processLength > maxCharacters) {
        print substr($1, 0, shortenLength) "... " $2
    } else {
        print $0
    }
}

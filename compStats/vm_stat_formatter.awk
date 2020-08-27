#!/usr/bin/awk -f

# Prints a breif summary of the memory usage on the computer using output from vm_stat
# Is in the format: X.XXG/XX.XG

# Total is Free + Active + Spec + Cache + Wired + Compressed

# Converts a page to its size in gigs
function pagesToGigs(pages, pageSize) {
    return (pages * pageSize) / 1000000000
}

NR == 1 {
        # Get Page Size from first line
        pageSize = $8
    }
$2 == "free:" {
        freePages = substr($3, 0, length($3) - 1);
    }
$2 == "active:" {
        activePages = substr($3, 0, length($3) - 1);
    }
$2 == "inactive:" {
        inactivePages = substr($3, 0, length($3) - 1);
    }
$2 == "speculative:" {
        specPages = substr($3, 0, length($3) - 1);
    }
$1 == "File-backed" {
        fileBackedPages = substr($3, 0, length($3) - 1);
    }
$2 " " $3 " " $4 == "occupied by compressor:" {
        compressedPages = substr($5, 0, length($5) - 1);
    }
$2 " " $3 == "wired down:" {
        wiredDownPages = substr($4, 0, length($4) - 1);
    }
END {
        totalPages = freePages + activePages + specPages + wiredDownPages + fileBackedPages + compressedPages
        usedPages = activePages + specPages

        totalGigs = pagesToGigs(totalPages, pageSize)
        usedGigs = pagesToGigs(usedPages, pageSize)

        printf("%.2f/%.2f\n", usedGigs, totalGigs)
    }

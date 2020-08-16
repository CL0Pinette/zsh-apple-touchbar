#!/usr/bin/awk -f

# Prints a breif summary of the memory usage on the computer using output from vm_stat
# Is in the format: X.XXG/XX.XG

# Total is Free + Active + Inactive + Spec + Wired Down
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
$2 == "wired" && $3 == "down:" {
        wiredDownPages = substr($4, 0, length($4) - 1);
    }
END {
        print "Page size: " pageSize
        print "Free pages: " freePages
        print "Active pages: " activePages
        print "Inactive pages: " inactivePages
        print "Spec pages: " specPages
        print "Wired down pages: " wiredDownPages
        print "-----------------"
        totalPages = freePages + activePages + inactivePages + specPages + wiredDownPages
        usedPages = totalPages - freePages
        print "totalPages: " totalPages
        print "usedPages: " usedPages
        print "-----------------"
        totalGigs = pagesToGigs(totalPages, pageSize)
        usedGigs = pagesToGigs(usedPages, pageSize)
        print "totalGigs: " totalGigs
        print "usedGigs: " usedGigs
        print "-----------------"
        printf("totalGigs Rounded: %.3g\n", totalGigs)
        printf("usedGigs Rounded: %.3g\n", usedGigs)
    }

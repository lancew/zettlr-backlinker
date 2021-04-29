use strict;
use warnings;

use lib './lib';
use Zettlr::Backlinker;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 2;

my $ZB = Zettlr::Backlinker->new;

my $files     = $ZB->get_file_list('/home/lancew/zettel');

for my $file (@$files) {
    if ($ZB->number_of_links_out($file) == 0) {
        print "NO LINKS OUT: $file\n";
    }

    # dies any file link to this file?
    # if not, say so.

}


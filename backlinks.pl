use strict;
use warnings;

use lib './lib';
use Zettlr::Backlinker;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent   = 2;

my $ZB = Zettlr::Backlinker->new;

my $files     = $ZB->get_file_list('/home/lancew/zettelkasten');
my $links     = $ZB->get_links_from_files(@$files);
my $backlinks = $ZB->backlinks_from_links($links);

for my $link_id ( keys %$backlinks ) {

    my $file
        = $ZB->filename_from_linkid( $link_id, '/home/lancew/zettelkasten' );

    if ( @{ $backlinks->{$link_id} } > 0 ) {
        $ZB->insert_backlinks( $file, @{ $backlinks->{$link_id} } );

    }

}


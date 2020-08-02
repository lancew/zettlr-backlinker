use strict;
use warnings;

use lib './lib';
use Zettlr::Backlinker;
use Data::Dumper;
$Data::Dumper::Sortkeys =1;
$Data::Dumper::Indent =2;


my $ZB = Zettlr::Backlinker->new;

my $files = $ZB->get_file_list('/home/lancew/zettelkasten');
my $backlinks = $ZB->get_backlinks_from_files(@$files);

#warn Dumper $backlinks;


my @no_links;
for my $file (keys %$backlinks) {
    warn $file if @{$backlinks->{$file}} > 0;

}




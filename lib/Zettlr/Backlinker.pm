package Zettlr::Backlinker;

use strict;
use warnings;

use List::MoreUtils 'uniq';
use Moo;

sub get_backlinks_from_files {
    my ( $self, @filenames ) = @_;
    my %backlinks;

    for my $filename (@filenames) {
        if ( $filename =~ /\d{14}/ ) {
            $/ = undef;
            open( my $fh, "<", $filename ) or die;
            my $content = <$fh>;
            close $fh;

            my $links = $self->get_links($content);

            $backlinks{$filename} = $links;
        }

    }

    return \%backlinks;
}

sub get_links {
    my ( $self, $text ) = @_;
    my @link_ids = uniq ( $text =~ /\[\[(\d*)\]\]/g );



    return \@link_ids;
}

sub get_file_list {
    my ( $self, $directory ) = @_;
    my @files;


    opendir( my $dh, $directory ) || die "Can't open $directory: $!";
    #@files = grep { /^\d{14}.*\.md$/ && -f "$_" } readdir($dh);
    #@files = readdir($dh);
    for my $file (readdir($dh)) {
        next if $file =~ m/^\./;
        next unless $file =~ m/^\d{14}/;
        next unless $file =~ m/\.md$/;
        push @files, "$directory/$file";
    }
    closedir $dh;

    return \@files;
}

1;


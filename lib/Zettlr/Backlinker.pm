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
            $/ = "\n";

            my $links = $self->get_links($content);

            $backlinks{$filename} = $links;
        }

    }

    return \%backlinks;
}

sub get_links {
    my ( $self, $text ) = @_;
    my @link_ids = uniq( $text =~ /\[\[(\d*)\]\]/g );

    return \@link_ids;
}

sub get_file_list {
    my ( $self, $directory ) = @_;
    my @files;

    opendir( my $dh, $directory ) || die "Can't open $directory: $!";
    for my $file ( readdir($dh) ) {
        next if $file =~ m/^\./;
        next unless $file =~ m/^\d{14}/;
        next unless $file =~ m/\.md$/;
        push @files, "$directory/$file";
    }
    closedir $dh;

    return \@files;
}

sub get_file_title {
    my ( $self, $filename ) = @_;
    my $output;

    open( my $fh, "<", $filename ) or die;
    for my $line (<$fh>) {
        $line =~ s/^# //;
        chomp $line;
        $output = $line;
        last;
    }
    close $fh;

    return $output;
}

sub insert_backlinks {
    my ( $self, $filename, @link_ids ) =@_;

    $/ = undef;
    open( my $fh, "<", $filename ) or die "unable to open $filename", $!;
    my $content = <$fh>;
    close $fh;
    $/ = "\n";


    #TODO: Magic number: "-1" means not found, i.e. links not already there
    my $backlink_index = index($content, "\nZettlr-Backlinks");

    if ($backlink_index > 0) {
        $content = substr($content, 0, $backlink_index);
    }

    $content .= "\n";
    $content .= "Zettlr-Backlinks:\n";
    for my $link (@link_ids) {
        # TODO: add the file title after the link i.e. "[[12345678901234]] some thing interesting"
        $content .= " * [[$link]]\n";
    }
    $content .= "\n";

    open( $fh, ">", $filename ) or die "unable to open $filename", $!;
    print $fh $content;
    close $fh;
}

1;


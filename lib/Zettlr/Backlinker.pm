package Zettlr::Backlinker;
# ABSTRACT: Create backlinks in a directory of Zettlr files

use strict;
use warnings;

use File::Find;
use List::MoreUtils 'uniq';
use Moo;

sub get_links_from_files {
    my ( $self, @filenames ) = @_;
    my %links;

    for my $file (@filenames) {
        if ( $file =~ /\d{14}/ ) {
            my $content = $self->get_file_contents($file);

            my $link_ids = $self->get_links($content);

            $links{$file} = $link_ids;
        }

    }
    return \%links;
}

sub get_links {
    my ( $self, $text ) = @_;
    my @link_ids = uniq( $text =~ /\[\[(\d*)\]\]/g );

    return \@link_ids;
}

sub number_of_links_out {
    my ($self, $filename) = @_;

    my $links = $self->get_links_from_files($filename);


    return scalar(@{$links->{$filename}});
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

    open( my $fh, "<", $filename ) or die "Unable to open $filename: $!";
    for my $line (<$fh>) {
        $line =~ s/^# //;
        chomp $line;
        $output = $line;
        last;
    }
    close $fh;

    return $output;
}

sub get_file_contents {
    my ( $self, $filename ) = @_;

    $/ = undef;
    open( my $fh, "<", $filename ) or die "unable to open $filename", $!;
    my $content = <$fh>;
    close $fh;
    $/ = "\n";

    my $backlink_index = index( $content, "Zettlr-Backlinks" );

    if ( $backlink_index > 0 ) {
        $content = substr( $content, 0, $backlink_index );
    }

    return $content;
}

sub filename_from_linkid {
    my ( $self, $linkid, $directory ) = @_;
    my $files = $self->get_file_list($directory);

    for my $file (@$files) {
        return $file if $file =~ /$linkid/;
    }
    return undef;
}

1;


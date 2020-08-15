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

sub insert_backlinks {
    my ( $self, $filename, @link_ids ) = @_;

    my $content = $self->get_file_contents($filename);

    $content .= "\n\n";
    $content .= "Zettlr-Backlinks:\n";
    for my $link (@link_ids) {
        # TODO: add the file title after the link
        #       i.e. "[[12345678901234]] some thing interesting"
        $content .= " * [[$link]]\n";
    }
    $content .= "\n";

    open( my $fh, ">", $filename ) or die "unable to open $filename", $!;
    print $fh $content;
    close $fh;
}

sub get_file_contents {
    my ( $self, $filename ) = @_;

    $/ = undef;
    open( my $fh, "<", $filename ) or die "unable to open $filename", $!;
    my $content = <$fh>;
    close $fh;
    $/ = "\n";

    my $backlink_index = index( $content, "\n\nZettlr-Backlinks" );

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

sub backlinks_from_links {
    my ( $self, $links ) = @_;

    my %backlinks;
    for my $file ( keys %$links ) {
        $file =~ m/(\d{14})/;
        for my $link ( @{ $links->{$file} } ) {
            push @{ $backlinks{$link} }, $1;
        }
    }
    for my $link ( keys %backlinks ) {
        my @backlinks = @{ $backlinks{$link} };
        @backlinks = sort @backlinks;
        $backlinks{$link} = \@backlinks;
    }

    return \%backlinks;

}

1;


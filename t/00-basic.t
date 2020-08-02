use strict;
use warnings;

use Test::MockFile;
# Test::MockFile must come before the Test2::V0 use linei, else it does not mock the file open
use Test2::V0 -target => 'Zettlr::Backlinker';

my $file_1_content = <<HERE;
# This is the first file
#tag1 ~tag2

Paragraph one has no links.

Paragraph 2 links to [[20200716164925]] Coding standards.
Which is only the ID and not the full file name


Paragraph 3 links to [[20200802022902]] Made up at the time I wrote the test.

Paragraph 34 links to [[20200802022902]] and [[20200716164911]] to test a bug.

HERE

my $file_2_content = <<HERE;
# This is the second file
#tag1 ~tag2

Paragraph one has no links.


HERE

my $mock_file_1
    = Test::MockFile->file( '20200716164925 some file.md', $file_1_content );
my $mock_file_2 = Test::MockFile->file( '20200802022902 another file.md',
    $file_2_content );
my $mock_file_3 = Test::MockFile->file( 'README.md', $file_1_content );

my @file_list = (
    '20200716164925 some file.md',
    '20200802022902 another file.md',
    'README.md',
);

my $mock_dir = Test::MockFile->dir( '/foo', \@file_list, { mode => 0700 } );

subtest 'Zettlr::Backlinker->get_file_list' => sub {
    is $CLASS->get_file_list('/foo'),
        [
        '/foo/20200716164925 some file.md',
        '/foo/20200802022902 another file.md',
        ],
        'Returns the correct list of files';
};

subtest 'Zettlr::Backlinker->get_links' => sub {
    is $CLASS->get_links($file_1_content),
        [ '20200716164925', '20200802022902', '20200716164911' ],
        'Got the correct three links';

    is $CLASS->get_links($file_2_content), [],
        'Returns empty array when no links found in text';
};

subtest 'Zettlr::Backlinker->backlinks_from_files' => sub {
    my @filenames = (
        '20200716164925 some file.md',
        '20200802022902 another file.md',
        'README.md',
    );

    is $CLASS->get_backlinks_from_files(@filenames), {
        '20200716164925 some file.md' =>
            [ '20200716164925', '20200802022902', '20200716164911' ],
        '20200802022902 another file.md' => [],

    };

};

subtest 'Zettlr::Backlinker->get_file_title' => sub {
    is $CLASS->get_file_title('20200716164925 some file.md'),
        'This is the first file',
        'Retrieves the title from first line of the file and removes the "# " at the beginning and the "\n" at the end';

};

subtest 'Zettlr::Backlinker->insert_backlinks' => sub {
    $CLASS->insert_backlinks(
        '20200802022902 another file.md',
        ( '20200716164925', '20200716164911' )
    );

    $/ = undef;
    open( my $fh, "<", '20200802022902 another file.md' ) or die;
    my $content = <$fh>;
    close $fh;
    $/ = "\n";

    is $content,
        "# This is the second file\n#tag1 ~tag2\n\nParagraph one has no links.\n\n\n\nZettlr-Backlinks:\n * [[20200716164925]]\n * [[20200716164911]]\n\n",
        'The backlinks were inserted properly, the first time';

};

done_testing;

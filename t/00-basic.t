use strict;
use warnings;

use Test::MockFile;
use Test::More;

use Zettlr::Backlinker;

my $CLASS = Zettlr::Backlinker->new;

my $file_1_content = <<HERE;
# This is the first file
#tag1 ~tag2

Paragraph one has no links.

Paragraph 2 links to [[20200716164925]] Coding standards.
Which is only the ID and not the full file name


Paragraph 3 links to [[20200802022902]] Made up at the time I wrote the test.

Paragraph 4 links to [[20200802022902]] and [[20200716164911]] to test a bug.

Paragraph 4 links to the second file [[22222222222222]] So should be a backlink for that file

HERE

my $file_2_content = <<HERE;
# This is the second file
#tag1 ~tag2

Paragraph one has no links.


HERE

my $file_3_content = <<HERE;
# This is the second file
#tag1 ~tag2

Links to [[11111111111111]] and [[22222222222222]]

HERE
my $mock_file_1
    = Test::MockFile->file( '11111111111111 some file.md', $file_1_content );
my $mock_file_2 = Test::MockFile->file( '22222222222222 another file.md',
    $file_2_content );
my $mock_file_3
    = Test::MockFile->file( '33333333333333 third file.md', $file_2_content );
my $mock_file_4 = Test::MockFile->file( 'README.md', $file_1_content );

my @file_list = (
    '11111111111111 some file.md',
    '22222222222222 another file.md',
    '33333333333333 third file.md',
    'README.md',
);

my $mock_dir = Test::MockFile->dir( '/foo', \@file_list, { mode => 0700 } );

subtest 'Zettlr::Backlinker->get_file_list' => sub {
    is_deeply $CLASS->get_file_list('/foo'),
        [
        '/foo/11111111111111 some file.md',
        '/foo/22222222222222 another file.md',
        '/foo/33333333333333 third file.md',
        ],
        'Returns the correct list of files';
};

subtest 'Zettlr::Backlinker->get_file_contents' => sub {
    is $CLASS->get_file_contents('22222222222222 another file.md'),
        $file_2_content,
        'File contents read successfully';
};

subtest 'Zettlr::Backlinker->get_links' => sub {
    is_deeply $CLASS->get_links($file_1_content),
        [
        '20200716164925', '20200802022902',
        '20200716164911', '22222222222222'
        ],
        'Got the correct four links';

    is_deeply $CLASS->get_links($file_2_content), [],
        'Returns empty array when no links found in text';
};

subtest 'Zettlr::Backlinker->links_from_files' => sub {
    my @filenames = (
        '11111111111111 some file.md',
        '22222222222222 another file.md',
        'README.md',
    );

    is_deeply $CLASS->get_links_from_files(@filenames), {
        '11111111111111 some file.md' => [
            '20200716164925', '20200802022902',
            '20200716164911', '22222222222222'
        ],
        '22222222222222 another file.md' => [],

    };

};

subtest 'Zettlr::Backlinker->get_file_title' => sub {
    is $CLASS->get_file_title('11111111111111 some file.md'),
        'This is the first file',
        'Retrieves the title from first line of the file and removes the "# " at the beginning and the "\n" at the end';

};

subtest 'Zetter::Backlinker->filename_from_linkid' => sub {
    is $CLASS->filename_from_linkid( '11111111111111', '/foo' ),
        '/foo/11111111111111 some file.md',
        '[[11111111111111]] -> "111111111111111 some file.md"';

    is $CLASS->filename_from_linkid( '99999999999999', '/foo' ),
        undef,
        '[[99999999999999]] (non-existent) -> undef';
};

done_testing;


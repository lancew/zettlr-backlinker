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
    = Test::MockFile->file( '33333333333333 third file.md', $file_3_content );
my $mock_file_4 = Test::MockFile->file( 'README.md', $file_1_content );

my @file_list = (
    '11111111111111 some file.md',
    '22222222222222 another file.md',
    '33333333333333 third file.md',
    'README.md',
);

my $mock_dir = Test::MockFile->dir( '/foo', \@file_list, { mode => 0700 } );

subtest 'number_of_links_out' => sub {
    is $CLASS->number_of_links_out('11111111111111 some file.md'),
        4, 'Has 4 unique links in it, 5 in total as one is repeate2d';
    is $CLASS->number_of_links_out('22222222222222 another file.md'),
        0, 'Has no links in it';
    is $CLASS->number_of_links_out('33333333333333 third file.md'),
        2, 'Has 2 links in it';
};

subtest 'number_of_links_in' => sub {
    is $CLASS->number_of_links_in(
        '11111111111111 some file.md', @file_list
        ),
        1, 'Only the third file links to file 1';
    is $CLASS->number_of_links_in(
        '22222222222222 another file.md', @file_list
        ),
        2, 'Both the other files link to this file';
    is $CLASS->number_of_links_in(
        '33333333333333 third file.md', @file_list
        ),
        0, 'Neither of the other files link to this file';
};
done_testing;


#!/usr/bin/env perl

# Unit tests for biotool.
#
# usage: perl biotool_test.pl

use strict;
use warnings 'FATAL' => 'all';
use Test::More;
use IO::String;
require 'biotool.pl';

# Test wrapper for the process_file function from biotool.
#
# Arguments:
sub test_process_file {
    my ($contents, $minlen_threshold, $expected, $test_name) = @_;
    my $file_handle = IO::String->new($contents);
    my $result = process_file($file_handle, $minlen_threshold);
    is_deeply($result, $expected, $test_name);
}

test_process_file(
    "",
    0,
    [0, 0, '-', '-', '-'],
    "Test input containing zero bytes");

test_process_file(
    "\n",
    0,
    [0, 0, '-', '-', '-'],
    "Test input containing a single newline character");

# The test below fails because Bio::SeqIO raises an exception on this input,
# which we don't currently handle
#test_process_file(
#    ">",
#    0,
#    [1, 0, 0, 0, 0],
#    "Test input containing a single greater-than (>) character");

test_process_file(
    ">header\nATGC\nA",
    0,
    [1, 5, 5, 5, 5],
    "Test input containing one sequence");

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    0,
    [2, 9, 2, 4, 7],
    "Test input containing two sequences");

# This test below fails because Bio::SeqIO raises an exception on this input,
# which we don't currently handle
#test_process_file(
#    "no header\n",
#    0,
#    [0, 0, '-', '-', '-'],
#    "Test input containing sequence without preceding header");

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    2,
    [2, 9, 2, 4, 7],
    "Test input when --minlen is less than 2 out of 2 sequences");

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    3,
    [1, 7, 7, 7, 7],
    "Test input when --minlen is less than 1 out of 2 sequences");

test_process_file(
    ">header1\nATGC\nAGG\n>header2\nTT\n",
    8,
    [0, 0, '-', '-', '-'],
    "Test input when --minlen is greater than 2 out of 2 sequences");

done_testing();

#!/usr/bin/perl
use warnings;
use strict;

use Text::CSV;

my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

my ($oggfilename, @columnnames, @columndata);

sub usage() {
	die "Usage: $0 datafile.csv\n";
}

usage() unless $#ARGV == 0;
my $csvfilename = $ARGV[0];
open my $csvfilehandle, "<:encoding(utf8)", "$csvfilename" or die "$csvfilename: $!";

my $firstline = <$csvfilehandle>;
chomp $firstline;

print "Parsing column definitions...\n";
$csv->parse($firstline) or die "Couldn't parse column definitions: $csv->error_diag()\n";
(undef, @columnnames) = $csv->fields();
print "Got these columns:";
foreach (@columnnames) {
	print " " . $_;
}
print "\n";

foreach my $line (<$csvfilehandle>) {
	$csv->parse($line) or (print "Line parsing failed: $csv->error_diag()\n" and next);
	($oggfilename, @columndata) = $csv->fields();
	(print "$oggfilename: not found.\n" and next) unless -e $oggfilename;
	print "Adding tags to $oggfilename\n";
	for my $i (0 .. $#columndata) {
		next if $columndata[$i] eq "";
		print ("\tAdding tag " . $columnnames[$i] . "=" . $columndata[$i] . "\n");
		`vorbiscomment -a $oggfilename -t "$columnnames[$i]=$columndata[$i]"`;
	}
	print "\n";
}

#!/usr/bin/perl
use warnings;
use strict;

# CSV2Vorbis
# Applies CSV-formatted metadata to OGG/Vorbis audio files.
# Author: Cass (Github: cassvs)
# July 17, 2017

use Text::CSV;

#Initialize Text::CSV object
my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();

#Globals
my ($oggfilename, @columnnames, @columndata);

#A meaningful epitaph message
sub usage() {
	die "Usage: $0 datafile.csv\n";
}

#We need exactly 1 argument, the name of the CSV file.
usage() unless $#ARGV == 0;
my $csvfilename = $ARGV[0];
open my $csvfilehandle, "<:encoding(utf8)", "$csvfilename" or die "$csvfilename: $!";

#The first line of the CSV file holds the column name definitions. Get 'em.
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

#Loop once for each remaining line in the CSV file:
foreach my $line (<$csvfilehandle>) {
	$csv->parse($line) or (print "Line parsing failed: $csv->error_diag()\n" and next);
	#The value in the first column is always the filename.
	($oggfilename, @columndata) = $csv->fields();
	#If a file by that name doesn't exist, move in to the next line.
	(print "$oggfilename: not found.\n" and next) unless -e $oggfilename;
	print "Adding tags to $oggfilename\n";
	#Loop once for each column of data:
	for my $i (0 .. $#columndata) {
		#Skip if this column is empty.
		next if $columndata[$i] eq "";
		#Add the tag.
		print ("\tAdding tag " . $columnnames[$i] . "=" . $columndata[$i] . "\n");
		`vorbiscomment -a $oggfilename -t "$columnnames[$i]=$columndata[$i]"`;
	}
	print "\n";
}

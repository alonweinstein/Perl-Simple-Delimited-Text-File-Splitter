#!/usr/bin/perl


# usage: psplit.pl sourcefile [number of lines per file]
use File::Basename;


# constructs the filename for the next part file
# takes the arguments: part number, filename (just the base filename), extension and the first row for the file (columns row)
# returns a reference to the file handle to write to 
sub setNewFile {
	$part = shift;
	$targetFilename = shift;
	$targetExtension = shift;
	$columns = shift;
	
	$newFilename = $targetFilename . $part . $targetExtension;
	open (NEWTARGET, ">>$newFilename");
	print NEWTARGET $columns;
	
 	return (NEWTARGET);	
}


# open the source file
open (SOURCE, $ARGV[0]);

# parse the source filename
($baseFilename, $dir, $baseFilenameExt) = fileparse($ARGV[0], qr/\.[^.]*/);

# create a base filename -- the directory path + filename, without the extension
$baseFilename = $dir . $baseFilename;

# will hold the current line number
$line = 0;

# lines-per-file defaults to 5000, unless there's a second command line argument which specifies a different value
$linesPerFile = 5000;
if ($#ARGV>1) {
	$linesPerFile = $ARGV[1];
}

# read the first line of the file into the $sourceColumns variable
$sourceColumns = <SOURCE>;

print "Splitting: " . $ARGV[0] . " each " . $linesPerFile . " lines."."\n";

# while there's a next line to read
while (<SOURCE>) {
	# is it time to start a new file?
	if ($line % $linesPerFile==0) {
		$part = $line/$linesPerFile + 1;
		print "Part " . "$part" . "\n";
		
		#close current file and start a new one
		close($target);
		$target = setNewFile ($part, $baseFilename, $baseFilenameExt, $sourceColumns);
	}
	
	$line = $line + 1;
	chomp;
	print $target "$_\n";
}

close ($target);
close(SOURCE);
exit;
#
# test.pl
#

use Env qw(PATH);

#use Env::Array { DEBUG => 1 }, qw(PATH ;); # For Win32.
use Env::Array { DEBUG => 0 }, qw(PATH :); # For Unix/Linux.


#
# unique()
#

sub unique
{
	my @temp;
	my $this;
	my $last;

	return ( ) unless @_;

	$last = shift;
	push @temp, $last;

	while (1) {
		last unless @_;
		my $this = shift;
		next if ($this eq $last); # TODO: What about numbers?
		push @temp, $this;
		$last = $this;
	};
	
	return @temp;
}


#
# unique2()
#

sub unique2
{
	my %cache;
	my @temp;
	my $this;

	return ( ) unless @_;

	$this = shift;
	push @temp, $this;
	$cache{$this}++;

	while (1) {
		last unless @_;
		my $this = shift;
		next if ($cache{$this});
		$cache{$this}++;
		push @temp, $this;
	};
	
	return @temp;
}

print "\n";

print "Raw \$PATH:\n    $PATH\n";
print "\n";

#print "Underlying object (class '", ref $path_obj, "'):\n";
#my $path_obj = tied @PATH;
#foreach (sort keys %$path_obj) {
#	print "    $_ => '", $path_obj->{$_}, "'\n";
#}
#print "\n";

print "Raw \@PATH:\n    ";
print join("\n    ", @PATH), "\n";
print "\n";

print "Output of sort and unique on \@PATH:\n    ";
print join("\n    ", unique sort @PATH), "\n";
print "\n";

print "Output of unique2 on \@PATH:\n    ";
print join("\n    ", unique2 @PATH), "\n";
print "\n";


#
# End of file.
#


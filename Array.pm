#
# Array.pm
#
# Env::Array Perl Module
#
# Uses tie to accomplish its job. DESTROY not implemented because
# we are not allocating any external resources.
#
# Copyright (C) 1999-2000 Gregor N. Purdy. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Env::Array;

require 5.005; # The tied array stuff doesn't work right in 5.004.

use vars qw($VERSION $DEBUG);
$VERSION = '1.002';
 
use Config; # To get $Config{path_sep}.


#
# import()
#
# TODO: Should allow a three-arg version for name, delim, escape?
#

sub import
{
	my ($callpack) = caller(0);
	my $pack       = shift;

	$DEBUG = 0;

	if (@_ and ref($_[0]) eq 'HASH') {
		$opt = shift;
		$DEBUG = $opt->{DEBUG} if exists($opt->{DEBUG});
	}

	if ($DEBUG) {
		my $args = join(", ", map { "'$_'" } @_);
		print "Env::Array::import(package => '$pack', $args) [caller => '$callpack']\n";
	}

	return unless @_; # Nothing to do.

	if (@_ == 1) { push @_, $Config::Config{path_sep}; }
	if (@_ % 2)  { die "use Env::Array requires a delimiter for each variable"; }

	while (@_) {
		my $name  = shift;
		my $delim = shift;

		$name =~ s/^@//; # Allow either '@PATH' or 'PATH'.

		die "Illegal variable name '$name'!" unless $name =~ m/^[a-zA-Z]/;

		die "Env::Array requires a delimiter!" unless $delim; # Can't Happen (TM)

		eval "package $callpack; use vars qw(\@$name);";
		die $@ if $@;
		tie @{"${callpack}::$name"}, $pack, $name, $delim;
	}

	return unless @_;
}


#
# TIEARRAY()
#
# TODO: Should allow also an escape character?
#

sub TIEARRAY
{
	my ($class, $name, $delim) = @_;
	my $self;

	if ($DEBUG) {
		print "Env::Array::TIEARRAY(class => '$class', name => '$name', delim => '$delim')\n";
	}

	$self = { NAME => $name, DELIM => $delim };

	bless $self, $class;

#	if ($DEBUG) {
#		print "    Object (class = '", ref $self, "') =\n";
#		foreach (sort keys %$self) {
#			print "        $_ => '", $self->{$_}, "'\n";
#		}
#	}

	return $self;
}


#
# DESTROY()
#

sub DESTROY
{
	if ($DEBUG) {
		print "Env::Array::DESTROY()\n";
	}
}


#
# get()
#
# TODO: Should unescape escaped delimiters before returning it?
#

sub get
{
	my $self  = shift;
	my $name  = $self->{NAME};
	my $delim = $self->{DELIM};

#	if ($DEBUG) {
#		print "Env::Array::get()\n";
#		print "    Name        = '$name'\n";
#		print "    Delimiter   = '$delim'\n";
#		print "    Environment = '$ENV{$name}'\n";
#	}

#	return split(quotemeta($delim), $ENV{$name});
	return split($delim, $ENV{$name});
}


#
# set()
#
# TODO: Should make sure $delim is not present in any of @_?
# TODO: Should, in fact, escape them if possible (or die otherwise?)
#

sub set
{
	my $self  = shift;
	my $name  = $self->{NAME};
	my $delim = $self->{DELIM};
	
	$ENV{$name} = join($delim, @_);

#	if ($DEBUG) {
#		print "Env::Array::set()\n";
#		print "    Name        = '$name'\n";
#		print "    Delimiter   = '$delim'\n";
#		print "    Environment = '$ENV{$name}'\n";
#	}
}


#
# FETCHSIZE()
#

sub FETCHSIZE
{
	my $self = shift;
	my $size = scalar($self->get);

	if ($DEBUG) {
		print "Env::Array::FETCHSIZE() = $size\n";
	}

	return $size;
}


#
# STORESIZE()
#

sub STORESIZE
{
	my $self = shift;
	my $size = shift;

	if ($DEBUG) {
		print "Env::Array::STORESIZE(size => $size)\n";
	}
}


#
# EXTEND()
#

sub EXTEND
{
	my $self = shift;
	my $size = shift;

	if ($DEBUG) {
		print "Env::Array::EXTEND(size => $size)\n";
	}
}


#
# CLEAR()
#

sub CLEAR
{
	my $self = shift;

	if ($DEBUG) {
		print "Env::Array::CLEAR()\n";
	}

	$self->set('');
}


#
# FETCH()
#

sub FETCH
{
	my ($self, $index) = @_;

	if ($DEBUG) {
		print "Env::Array::FETCH(index => $index)\n";
	}

	return ($self->get)[$index];
}


#
# STORE()
#

sub STORE
{
	my ($self, $index, $value) = @_;

	if ($DEBUG) {
		print "Env::Array::STORE(index => $index, value => '$value')\n";
	}

	my @temp = $self->get;
	$temp[$index] = $value;
	$self->set(@temp);

	return $value;
}


#
# PUSH()
#

sub PUSH
{
	my $self = shift;

	if ($DEBUG) {
		my $values = join(", ", map { "'$_'" } @_);
		print "Env::Array::PUSH($values)\n";
	}

	$ENV{$self->{NAME}} = join($self->{DELIM}, $ENV{$self->{NAME}}, @_);
}


#
# Return a true value:
#

1;

__END__


=head1 NAME

Env::Array - Perl module that "imports" environment variables as arrays


=head1 SYNOPSIS

With explicit delimiters:

    use Env::Array qw(PATH :);
    use Env::Array qw(@MANPATH :);

With inferred delimiters:

    use Env::Array qw(@LD_LIBRARY_PATH);


=head1 DESCRIPTION

The C<Env::Array> Perl module allows environment variables to be treated
as Perl array variables, analogous to the way the C<Env> module allows
them to be treated as scalar variables.

The Env::Array::import() function requires pairs of environment variable
names and delimiter strings to be presented in the C<use> statement. If
just one argument is given, then C<$Config::Config{path_sep}> is taken
as the delimiter. C<Env::Array> allows the variable name to have the
'C<@>' array type prefix, if desired. The variable being tied must
otherwise begin with a letter. Unlike C<Env>, C<Env::Array> does nothing
if the C<use> list is empty.

After an environment variable is tied, just use it like an ordinary array.
Bear in mind, however, that each access to the variable requires splitting
the string anew.

The code:

    use Env::Array qw(@PATH);
    push @PATH, '.';

is equivalent to:

    use Env qw(PATH);
	$PATH .= ":.";

except that the C<Env::Array> approach does the right thing for both
Unix-like operating systems and for Win32. Also, if C<$ENV{PATH}> was
the empty string, the C<Env> approach leaves it with the (odd) value
"C<:.>", but the C<Env::Array> approach leaves it with "C<.>".

C<Env::Array> requires Perl 5.005 or later for proper operation due to its
use of tied arrays.


=head1 SEE ALSO

The C<Env> Perl module.


=head1 AUTHOR

Gregor N. Purdy E<lt>F<gregor@focusresearch.com>E<gt>


=head1 COPYRIGHT

Copyright (C) 1999-2000 Gregor N. Purdy. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut



#
# End of file.
#



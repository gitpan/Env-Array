#
# Array.pm
#
# Env::Array Perl Module
#
# Uses tie to accomplish its job. DESTROY not implemented because
# we are not allocating any external resources.
#
# Copyright (C) 1999 Gregor N. Purdy. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Env::Array;

use vars qw($VERSION);
$VERSION = '1.000';

#
# import()
#
# TODO: Should allow a three-arg version for name, delim, escape?
#

sub import
{
	my ($callpack) = caller(0);
	my $pack       = shift;

#print "Env::Array::import()\n";
#print "    Caller  = $callpack\n";
#print "    Package = $pack\n";
#print "    Arguments = '", join("', '", @_), "'\n";

	if (@_ % 2) { die "use Env::Array requires an even number of arguments"; }
	if (!@_)    { die "use Env::Array requires at least two arguments"; }

	while (@_) {
		my $name  = shift;
		my $delim = shift;

		die "Env::Array requires a delimiter!" unless $delim;

		eval "package $callpack; use vars qw(\@$name);";
		die $@ if $@;
		tie @{"${callpack}::$name"}, Env::Array, $name, $delim;
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

#print "Env::Array::TIEARRAY()\n";
#print "    Class     = '$class'\n";
#print "    Name      = '$name'\n";
#print "    Delimiter = '$delim'\n";

	return bless { NAME => $name, DELIM => $delim }, $class;
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

#print "Env::Array::get()\n";
#print "    Name        = '$name'\n";
#print "    Delimiter   = '$delim'\n";
#print "    Environment = '$ENV{$name}'\n";

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

#print "Env::Array::set()\n";
#print "    Name        = '$name'\n";
#print "    Delimiter   = '$delim'\n";
#print "    Environment = '$ENV{$name}'\n";
}


#
# FETCHSIZE()
#

sub FETCHSIZE
{
	my $self = shift;

	return scalar($self->get);
}


#
# FETCH()
#

sub FETCH
{
	my ($self, $index) = @_;

#print "Env::Array::FETCH()\n";
#print "    Index = $index\n";

	return ($self->get)[$index];
}


#
# STORE()
#

sub STORE
{
	my ($self, $index, $value) = @_;

#print "Env::Array::STORE()\n";
#print "    Index = $index\n";
#print "    Value = '$value'\n";

	my @temp = $self->get;
	$temp[$index] = $value;
	$self->set(@temp);

	return $value;
}

__END__

=pod

=head1 NAME

Env::Array - perl module that imports environment variables as arrays

=head1 SYNOPSIS

  use Env::Array qw(PATH :);

=head1 DESCRIPTION

The Perl module C<Env::Array> allows environment variables to be treated
as array variables, much the way that the module C<Env> them to be treated
as scalar variables.

The Env::Array::import() function requires pairs of environment variable
names and delimiter strings to be presented in the C<use> statement. Unlike
C<Env>, there is no default behavior when no arguments are given to C<use>
(except to print an error message and die).

After an environment variable is tied, just use it like an ordinary array.
Bear in mind, however, that each access to the variable requires splitting
the string anew.

=head1 SEE ALSO

Env

=head1 AUTHOR

Gregor N. Purdy E<lt>F<gregor@focusresearch.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 1999 Gregor N. Purdy. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut



#
# End of file.
#



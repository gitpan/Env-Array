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

require 5.005; # The tied array stuff doesn't work right in 5.004.

use vars qw($VERSION $DEBUG);
$VERSION = '1.001';

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

	if (@_ % 2) { die "use Env::Array requires an even number of arguments"; }
	if (!@_)    { die "use Env::Array requires at least two arguments"; }

	while (@_) {
		my $name  = shift;
		my $delim = shift;

		die "Env::Array requires a delimiter!" unless $delim;

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

Requires Perl 5.005 or later for proper operation due to the use of tied
arrays.

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



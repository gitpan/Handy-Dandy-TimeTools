
use strict;
use Test;

# use a BEGIN block so we print our plan before module is loaded
BEGIN { use Handy::Dandy::TimeTools }
BEGIN { plan tests => scalar(@Handy::Dandy::TimeTools::EXPORT_OK), todo => [] }
BEGIN { $| = 1 }

# load your module...
use lib './';

# automated empty subclass test

# subclass Handy::Dandy::TimeTools in package _Foo
package _Foo;
use strict;
use warnings;
use Handy::Dandy::TimeTools qw( :all );
$Foo::VERSION = 0.00_0;
@_Foo::ISA = qw( Handy::Dandy::TimeTools );
1;

# switch back to main package
package main;

# see if _Foo can do everything that Handy::Dandy::TimeTools can do
map {

   ok ref(UNIVERSAL::can('_Foo', $_)) eq 'CODE'

} @Handy::Dandy::TimeTools::EXPORT_OK;


exit;

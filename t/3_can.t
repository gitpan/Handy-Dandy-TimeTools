
use strict;
use Test;

# use a BEGIN block so we print our plan before MyModule is loaded
BEGIN { plan tests => 21, todo => [] }
BEGIN { $| = 1 }

# load your module...
use lib './';
use Handy::Dandy::TimeTools qw( :all );

stamp;
to_seconds;
convert_time;
seconds_since;
second;
minute;
hour;
month;
year;
dayofweek;
dayofyear
minutestart;
hourstart;
daystart;
weekstart;
monthstart;
yearstart;
UTC_OFFSET;

my($f) = Handy::Dandy::TimeTools->new();

# check to see if non-autoloaded Handy::Dandy::TimeTools methods are can-able ;O)
map { ok(ref(UNIVERSAL::can($f,$_)),'CODE') } qw
   (
      stamp
      to_seconds
      convert_time
      seconds_since
      second
      minute
      hour
      month
      year
      dayofweek
      dayofyear
      minutestart
      hourstart
      daystart
      weekstart
      monthstart
      yearstart
      UTC_OFFSET

      VERSION
      DESTROY
      AUTOLOAD
   );

exit;

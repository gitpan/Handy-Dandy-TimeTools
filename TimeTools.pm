package Handy::Dandy::TimeTools;
use strict;
use vars qw( $VERSION   @ISA   @EXPORT_OK   %EXPORT_TAGS
            $AUTOLOAD   $ATL   $SEC   $MIN   $HOUR   $DAY
            $WEEK   $YEAR   $UTC_OFFSET );
use Exporter;
use Handy::Dandy qw( :all );
$VERSION     = 0.01_8; # 12/23/02, 1:35 am
@ISA         = qw( Exporter Handy::Dandy );
@EXPORT_OK   = ( @Handy::Dandy::EXPORT_OK, qw
   (
      UTC_OFFSET
      stamp   to_seconds   convert_time   seconds_since
      second   minute   hour   month   year   dayofweek   dayofyear
      minutestart   hourstart   daystart   weekstart   monthstart   yearstart
   ));
%EXPORT_TAGS = ( 'all' => [ @Handy::Dandy::TimeTools::EXPORT_OK ] );

$UTC_OFFSET = -6; # default to US Central time zone

$SEC  = qr/^SEC/;  $MIN  = qr/^MIN/; $HOUR = qr/^HOUR/;
$DAY  = qr/^DAY/; $WEEK = qr/^WEEK/; $YEAR = qr/^YEAR/;


# --------------------------------------------------------
# Handy::Dandy::TimeTools::stamp()
# --------------------------------------------------------
{
   my($months) =
      [
         'January',   'February', 'March',   'April',
         'May',       'June',     'July',    'August',
         'September', 'October',  'November', 'December',
      ];

   my($days) =
      [
         'Sunday',   'Monday', 'Tuesday', 'Wednesday',
         'Thursday', 'Friday', 'Saturday'
      ];

   sub stamp  {

      my($opts)            = shave_opts(\@_);
      my($argtime,$offset) = myargs(@_);

      $argtime ||= time unless Handy::Dandy->isint($argtime);
      $offset  ||= $UTC_OFFSET unless Handy::Dandy->isint($offset);
      $argtime  += ($offset * 3600);

      my($sec,$min,$h24,$date,$mon,$year,$wday,$yday) = gmtime($argtime);

      my($hour) = $h24;

      $hour = $h24 - 12 if ($h24 > 12); $hour = 12 if ($hour == 0);

      my($AMPM) = ($h24 >= 12) ? 'pm' : 'am';

      goto DEFAULT if ($opts->{'--short'} or !scalar(keys(%$opts)));

      # -June-15-2002-16.22.43
      return
        (
         sprintf(
            q[-%s-%u-%u-%u.%02u.%02u],
            $months->[$mon], $date, $year + 1900,
            $h24,          $min,          $sec
         )
        ) if ($opts->{'--file'} || $opts->{'--filename'});

      # 5/15/02
      return
        (
         sprintf(
            q[%s/%s/%2s],
            $mon + 1, $date, substr($year + 1900, 2)
         )
        ) if $opts->{'--mdy'};

      # Saturday, June 15, 2002, 4:22 pm
      return
        (
         sprintf(
            q[%s, %s %u, %u, %s:%02u %s],
            $days->[$wday], $months->[$mon], $date, $year + 1900,
            $hour,        $min,         $AMPM
         )
        )  if ($opts->{'--formal'} || $opts->{'--long'});

      # Sat, 15 Jun 2002 16:22:43 GMT
      return
        (
         sprintf(
            q[%s, %02u %s %s %02u:%02u:%02u GMT],
            substr($days->[$wday],0,3), $date, substr($months->[$mon],0,3),
            $year + 1900,  abs($h24 + $UTC_OFFSET),  $min, $sec
         )
        )  if $opts->{'--iso'};

      # Sat 5/15/02 16:22:43
      return
        (
         sprintf(
            q[%s %s/%s/%2s %s:%02u:%02u],
            substr($days->[$wday],0,3), $mon + 1, $date,
            substr($year + 1900, 2),  $h24,  $min, $sec
         )
        )  if $opts->{'--succinct'};

      # 4:22 pm
      return
        (
         sprintf(
            q[%s:%02u %s],
            $hour, $min, $AMPM
         )
        ) if $opts->{'--hm'};

      # 4:22:43 pm
      return
        (
         sprintf(
            q[%s:%02u:%02u %s],
            $hour, $min, $sec, $AMPM
         )
        ) if $opts->{'--hms'};

      # 16:22:43
      return
        (
         sprintf(
            q[%s:%02u:%02u],
            $h24, $min, $sec
         )
        ) if $opts->{'--24hms'};


      # MOVING TO IF-ELSIF-ELSE SEQUENCE NOW...
      if ($opts->{'--dayofmonth'}) {

         # (number of the date) 1 - [28-31]
         return($date);
      }
      elsif ($opts->{'--dayofweek'}) {

         # (number for day of the week) 1 - 7
         return($wday+1) if $opts->{'--num'};

         # (name of the day) Sunday - Saturday
         return($days->[$wday]);
      }
      elsif ($opts->{'--dayofyear'}) {

         # (number for day of the year) 1 - 365 (non-leap)
         return($yday);
      }
      elsif ($opts->{'--month'}) {

         # (number of the month) 1 - 12
         return($mon+1) if $opts->{'--num'};

         # (name of the month) January - December
         return($months->[$mon]);
      }
      elsif ($opts->{'--year'}) {

         # (year number) 2002
         return($year + 1900);
      }
      elsif ($opts->{'--shortyear'}) {

         # (abbreviated year number)
         return(substr($year + 1900, 2));
      }
      elsif ($opts->{'--minute'}) {

         # (number of the minute) 0 - 59
         return($min);
      }
      elsif ( $opts->{'--hour'}) {

         # (number of the hour) 0 - 24
         return($h24);
      }
      elsif ($opts->{'--second'}) {

         # (number of the second) 0 - 59
         return($sec);
      }
      else {

         DEFAULT:

         # 5/15/02, 4:22 pm
         return
           (
            sprintf(
               q[%s/%u/%2s, %s:%02u %s],
               $mon + 1, $date, substr($year + 1900, 2),
               $hour, $min, $AMPM
            )
           );
      }

      '';
   }
}


# --------------------------------------------------------
# Handy::Dandy::TimeTools::to_seconds()
# --------------------------------------------------------
sub to_seconds {

   my($unit)   = ${\myargs(@_)} || return(undef);
   my($amt)    = 0;

   ($amt,$unit) = split(/ /,$unit); $unit = uc($unit);

   return(0) unless Handy::Dandy::isnum($amt);

   if    ($unit =~ /$SEC/)   { return($amt);            }
   elsif ($unit =~ /$MIN/)   { return($amt * 60);       }
   elsif ($unit =~ /$HOUR/)  { return($amt * 3600);     }
   elsif ($unit =~ /$DAY/)   { return($amt * 86400);    }
   elsif ($unit =~ /$WEEK/)  { return($amt * 604800);   }
   elsif ($unit =~ /$YEAR/)  { return($amt * 31536000); }

   -1;
}


# --------------------------------------------------------
# Handy::Dandy::TimeTools::seconds_since()
# --------------------------------------------------------
sub seconds_since {

   my($opts)    = shave_opts(\@_);
   my($h,$m,$s) = (
      stamp('--hour'),
      stamp('--minute'),
      stamp('--second') );

   $h = to_seconds(qq[$h hours]);
   $m = to_seconds(qq[$m minutes]);

   my($hms) = $h+$m+$s;

   if    ($opts->{'--minutestart'}) { $s }
   elsif ($opts->{'--hourstart'})   { $m + $s }
   elsif ($opts->{'--daystart'})    { $hms }
   elsif ($opts->{'--weekstart'})   {

      $hms + to_seconds(stamp('--dayofweek','--num') - 1 . q[ days])
   }
   elsif ($opts->{'--monthstart'}) {

      $hms + to_seconds(stamp('--dayofmonth') - 1 . q[ days])
   }
   elsif ($opts->{'--yearstart'}) {

      $hms + to_seconds(stamp('--dayofyear') . q[ days])
   }
   else { undef }
}


# Handy::Dandy::TimeTools::-------------------------------
#   minutestart(),   hourstart(),   daystart(),
#   weekstart(),   monthstart(),   yearstart()
# --------------------------------------------------------
sub minutestart   { time - seconds_since '--minutestart' }
sub hourstart     { time - seconds_since '--hourstart'   }
sub daystart      { time - seconds_since '--daystart'    }
sub weekstart     { time - seconds_since '--weekstart'   }
sub monthstart    { time - seconds_since '--monthstart'  }
sub yearstart     { time - seconds_since '--yearstart'   }


# --------------------------------------------------------
# Handy::Dandy::TimeTools::AUTOLOAD()
# --------------------------------------------------------
sub AUTOLOAD {

   my($sub) = $AUTOLOAD; $sub =~ s/^.*\:\://o;

   if (ref($ATL) ne 'HASH') { $ATL = eval($ATL); }

   if (ref(eval(qq[\$sub])) eq 'CODE') { goto &$sub; }

   unless ($ATL->{ $sub }) {

      die(qq[BAD AUTOLOAD. Can't do $sub().  Don't know what it is.]);
   }

   eval($ATL->{ $sub }); CORE::delete($ATL->{ $sub });

   goto &$sub;
}


# --------------------------------------------------------
# Handy::Dandy::TimeTools::DESTROY()
# --------------------------------------------------------
sub DESTROY {}



BEGIN { $ATL = <<'___AUTOLOADED___'; }
   {
'UTC_OFFSET' => <<'__SUB__',
# --------------------------------------------------------
# Handy::Dandy::TimeTools::UTC_OFFSET()
# --------------------------------------------------------
sub UTC_OFFSET { my($o) = myargs(@_); $UTC_OFFSET = $o if $o; $UTC_OFFSET }
__SUB__

'convert_time' => <<'__SUB__',
# --------------------------------------------------------
# Handy::Dandy::TimeTools::convert_time()
# --------------------------------------------------------
sub convert_time {

   # syntax: $dandy->convert_time($int, q[days to hours])

   my($amt, $cmd) = myargs(@_);

   return(undef) unless Handy::Dandy::isnum($amt);

   my(@specs)     = split(/ /,uc($cmd));
   my($from)      = $specs[0];
   my($to)        = $specs[-1];

   # FROM conversions
   # (note: conversion FROM seconds TO unit x is implicit)
   if    ($from =~ /$MIN/)   { $amt *= 60;        }
   elsif ($from =~ /$HOUR/)  { $amt *= 3600;      }
   elsif ($from =~ /$DAY/)   { $amt *= 86400;     }
   elsif ($from =~ /$WEEK/)  { $amt *= 604800;    }
   elsif ($from =~ /$YEAR/)  { $amt *= 31536000;  }

   # TO conversions
   if    ($to =~ /$MIN/)     { return($amt / 60);        }
   elsif ($to =~ /$HOUR/)    { return($amt / 3600);      }
   elsif ($to =~ /$DAY/)     { return($amt / 86400);     }
   elsif ($to =~ /$WEEK/)    { return($amt / 604800);    }
   elsif ($to =~ /$YEAR/)    { return($amt / 31536000);  }

   return($amt);
}
__SUB__

# Handy::Dandy::TimeTools::-------------------------------
#   second(),  minute(),  hour(),  month(),  year()
#   dayofmonth(),  dayofweek(),  dayofyear()
# --------------------------------------------------------
'second'       => <<'__SUB__',
sub second     { stamp('--second');             }
__SUB__
'minute'       => <<'__SUB__',
sub minute     { stamp('--minute');             }
__SUB__
'hour'         => <<'__SUB__',
sub hour       { stamp('--hour');               }
__SUB__
'month'        => <<'__SUB__',
sub month      { stamp('--month','--num');      }
__SUB__
'year'         => <<'__SUB__',
sub year       { stamp('--year');               }
__SUB__
'dayofmonth'   => <<'__SUB__',
sub dayofmonth { stamp('--dayofmonth','--num'); }
__SUB__
'dayofweek'    => <<'__SUB__',
sub dayofweek  { stamp('--dayofweek','--num');  }
__SUB__
'dayofyear'    => <<'__SUB__',
sub dayofyear  { stamp('--dayofyear');          }
__SUB__
}
___AUTOLOADED___


# --------------------------------------------------------
# end Handy::Dandy::TimeTools Class, return true on import
# --------------------------------------------------------
1;

=pod

=head1 NAME
Handy::Dandy::TimeTools - Get the time in lots of ways, in lots of formats

=head1 VERSION
0.01_8

=head1 @ISA
   Exporter
   OOorNO
   Handy::Dandy::TimeTools

=head1 @EXPORT
None by default.

=head1 @EXPORT_OK
All available methods.

=head1 %EXPORT_TAGS
   :all (exports all of @EXPORT_OK)

=head1 Methods
   stamp()
   to_seconds()
   convert_time()
   seconds_since()
   second()
   minute()
   hour()
   month()
   year()
   dayofweek()
   dayofyear
   minutestart()
   hourstart()
   daystart()
   weekstart()
   monthstart()
   yearstart()
   UTC_OFFSET()

=head2 AUTOLOAD-ed methods
   convert_time()
   UTC_OFFSET()
   second()
   minute()
   hour()
   month()
   year()
   dayofmonth()
   dayofweek()
   dayofyear()

=head1 PREREQUISITES
OOorNO.pm

=head1 AUTHOR
Tommy Butler <cpan@atrixnet.com>

=head1 COPYRIGHT
Copyright(c) 2001-2003, Tommy Butler.  All rights reserved.

=head1 LICENSE
This library is free software, you may redistribute
and/or modify it under the same terms as Perl itself.

=cut

use ExtUtils::MakeMaker;
require 5.6.0;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
   (
   'ABSTRACT'     => 'Get time in lots of ways, in lots of formats',
   'AUTHOR'       => 'Tommy Butler <cpan@atrixnet.com>',
   'INSTALLDIRS'  => 'perl',
   'NAME'         => 'Handy::Dandy::TimeTools',
   'VERSION_FROM' => 'TimeTools.pm',
   'linkext'      => { LINKTYPE => '' }, # no link needed
   'PREREQ_PM'    =>
      {
         'OOorNO' => 0.00_2,
         'Handy::Dandy' => 1.30_6,
      },
   'dist'         =>
      {
         'COMPRESS'  => 'gzip -9f',
         'SUFFIX'    => 'gz',
         'ZIP'       => '/usr/bin/zip',
         'ZIPFLAGS'  => '-rl',
      }
   );

__END__
   * NAME
   * SYNOPSIS
   * DESCRIPTION
   * INSTALLATION
   * EXPORT
   * EXPORT_OK
   * GLOBAL VARIABLES
   * PUBLIC METHODS
   * PRIVATE METHODS
   * EXAMPLES
   * BUGS
   * AUTHOR
   * COPYRIGHT
   * SEE ALSO

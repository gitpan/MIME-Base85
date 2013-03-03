use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'MIME::Base85',
    'VERSION_FROM'	=> 'Base85.pm', # finds $VERSION
    'PREREQ_PM'		=> {Inline::Python => 0.36}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ? (
      ABSTRACT_FROM => 'Base85.pm', 
      AUTHOR     => '-',
    ) : ()),
);

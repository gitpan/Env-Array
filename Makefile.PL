use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME		=> 'Env::Array',
   VERSION_FROM	=> 'Array.pm',
   dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
  );


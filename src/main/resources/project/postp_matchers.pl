use ElectricCommander;

push (@::gMatchers,
  {
        id =>          "BuildWarnings",
        pattern =>     q{(.+) Warning.+},
        action =>           q{ incValue('warnings', $1); }
  }
);

push (@::gMatchers,
  {
        id =>          "BuildErrors",
        pattern =>     q{(.+) Error.+},
        action =>     q{ incValue('errors', $1); }
  }
);


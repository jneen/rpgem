## Why?

Gems have a habit of building native extensions from source.
On development machines, this is not a problem.
On production machines, it means we require gcc, and
gems are painfully slow to install.


## What RPGem does

RPGem will create a binary RPM with the *compiled* extensions,
which you can install on a machine painlessly.

## Usage

    rpgem [gem_name] [OPTIONS]

    Options:

    -v VER, --version VER       Specify a specific version of the gem to use.

    -V VER, --version-req VER   Specify a version requirement,
                                i.e. '< 2.3', or '~> 1'

    -d DEP, --depends DEP       Specify an rpm (non-gem) dependency.

    -R, --recursive             Recursively package gem dependencies

    -p PFX, --prefix PFX        Specify a prefix to use in the rpm.
                                Defaults to /usr, but could easily be
                                /usr/local, /opt, etc.


    -f, --fetch                 Only fetch the gem(s)

    -s, --make-spec             Only fetch the gem(s) and create the specfile

    -b, --build                 Fetch the gems, create the specfile, and build the rpm
                                (this is the default)

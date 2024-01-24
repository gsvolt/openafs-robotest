# OpenAFS Robotest Changes

## [prerelease]

* Remove cookiecutter and provide molecule files in the tree.

## [v1.1.0]

* Convert all of the Robot Framework files from space-separated to the more
  modern and less error prone pipe-separated format.

* Improve sphinx generated documentation.

* Add a new test for creating mountpoints in the root.cell volume.

* Various updates to test cases:
  - Removed double test 'with command alias'
  - Add check 'Dir should not exists' in Teardown
  - Move 'set/check ACL' in Setup block

* Fix multi-fs-required support on Solaris.

* Fix the 'vos restore' command option in some cases.

* Remove unimplemented OpenAFS version info from the test report.

* Add the robotab.py script to format tables in robot files.

* Update platforms in cookiecutter template to generate an Anisible Molecule
  scenario.

## [v1.0.0]

* Ansible Molecule test cell template

* Sphinx documentation

## [v0.7.0]

* Moved afsutil to https://github.com/openafs-contrib/afsutil
* Moved OpenAFSLibrary to https://github.com/openafs-contrib/robotframework-openafs
* Reverted acl tests
* Fixes for real kerberos kdc support

## [v0.6.0]

### Tests

* Reorg test suites into client and server tests
* Add more bos and pts tests
* Made pts test independent
* Add more basic client tests
* Add a pagsh test
* Add client find tests
* Add client dir tests
* Add client huge file tests
* Add client acl tests
* Add 'bug' tag to exclude tests of known bugs

### Library

* Add PAG keywords for the pagsh test
* Add Link, Symlink, Unlink keywords
* Add cache parameter keywords
* Remove fs flushall when creating test volumes

### Other

* Add setup scripts for various linux distros and solaris
* Add bootstrap.sh script to quickly setup a single system test
* User documentation added
* Rename afs-robotest to afsrobot (and provide a compat wrapper)
* Add --user option to install.sh to avoid accidental local installs
* Add --srcdir option to 'afsutil build' to support out-of-tree builds
* Modernize afsutil getdeps on solaris 11
* Add env vars setup in afsutil build on solaris 11
* Add more needed packages on debian
* Add fedora support in install
* Fix afsutil getdeps on ubuntu
* Carry on if we cannot delete the temporary keytab during teardown
* Remove the afsrobot --user and --root options and related env vars
* Save the installation path for afsrobot init and uninstall
* Install to /opt/afsrobotest on Solaris
* Add afsutil package --source option to build SRPM only


## [v0.5.0]

### Setup/Teardown

* Support RPM installations for RHEL and Centos.
* Support for systemd for rhel/centos 7.x.
* New `afsrobot` package: Convert the largish `afs-robotest` script into a proper python package with a small front-end.
* Automatically add new configuration options with default values when upgrading.
* New `host:$HOSTNAME.use` option to indicate which hosts are in use.
* New `options.dafs` option to specify when DAFS is to be setup.
* New `afsd` and `bosserver` options to speficy command line arguments.
* Provide usable "transarc-style" init scripts for solaris and for linux, based on the examples in OpenAFS.
* Support the modern style `openafs.ko` kernel module naming, even with transarc-style binaries.
* Make `afs-robotest teardown` safer.  Remove volume data only on partitions which have the `PURGE_VOLUMES` file.  The `PURGE_VOLUMES` is automatically added to the vicepa and vicepb partitions if they are created by `afs-robotest setup`.  When using pre-existing test partitions, the tester may create the `PURGE_VOLUMES` file in the partitions to be purged by `afs-robtest teardown`.
* Set the correct `rxkad.keytab` file permissions.
* Use the same random fake key for akimpersonate on each server.
* Fix the handling of non-dynroot setups so the cache manager is not started until the root volumes are online to avoid the cm from hanging in the non-dynroot environment.
* More robust cell host address detection.
* Better error messages for command not found errors.
* Print a warning and continue if akimpersonate is enabled but the path to a usable `aklog` is not specified.
* The `AFS_ROBOTEST_CONF` environment variable now gives the fully qualified filename of the configuration file. This value can be overridden with the `--config` option.
* Require a configuration file, instead of attempting to use default values if not present.
* Add the `afs-robotest config copy` and `afs-robotest config unset` subcommands.
* Removed the per host configuration options: `build`,`builddir`,`setclock`,`nuke`,`auto_*`.
* Use the actual hostname in the configuration section name instead of the hard-coded `[host:localhost]`.
* Renamed `afs-robotest sshkeys` subcommand to `afs-robotest ssh`.
* Add the `afs-robotest ssh exec` subcommand to run remote commands hosts listed in the configuration file.
* Add the `afs-robotest version` subcommand to print version information.
* Cleanup the akimpersonate fake keytab file.
* Install: automatically install external dependenices on some platforms
* Install: put per user data under $HOME/.afsrobotestrc/ and tests under /usr/local/afsrobotest/

### Tests

* `afs-robotest run`: Add `--include` option to allow tests to be included by tag.
* Add `afs-robotest run` as an alias for `afs-robotest test`
* `echo -n` is not portable; avoid it in the tests.
* Fix false failure in write-to-read-only volume test.

### Keyword Library

* Always run `fs checkvolumes` after creating, removing, and releasing volumes to avoid stale volume cache entries and resulting ENODEV errors.
* Log stdout and stderr from commands issued via keywords `Command Should Succeed` and `Command Should Not Succeed`.
* When a command fails, it's helpful to see what the arguments were, so log them too.

### Building/Development

* Support building RPM packages for RHEL and CentOS.
* Support modern kernel module naming standards on linux (`openafs.ko`), even for transarc-style builds.
* Avoid `git clean` of the wrong directory. Do additional checks and check the `afsutil.clean` git config before running git clean.
* Add `--cf` option for transarc-style builds. Do not add extra configure options when `--cf` is given.
* New `afsutil reload` command to reload the kernel module after rebuilding it.
* `afsutil login`: Add the `--user` option to specify the username.
* `afsutil build --jobs` option for parallel builds on Linux. (`nproc` determines the default number of jobs.)
* `afsutil build` create tarball of transarc-style distribution files

## [v0.4.0] 2016-02-23

* Support multi-server AFS Cell setup.

## [v0.3.0] 2016-01-08

* New `afsutil` package: New python package and script to install and setup OpenAFS before running tests. This package is independent of Robot Framework.

## [v0.2.0] 2015-04-13

* New `OpenAFSLibary` Robot Framework keyword library for writing tests.

## [v0.1.0] 2013-05-23

* Initial

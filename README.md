# gpgfile

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with gpgfile](#setup)
    * [What gpgfile affects](#what-gpgfile-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gpgfile](#beginning-with-gpgfile)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

`gpgfile` is an attempt at a `file` replacement that supports gpg-encrypted files.

Because of security concerns, some organizations don't want encrypted data to
be decrypted on the puppet master (whether due to protection of the secret key
or concerns that decrypted data might appear in the catalog, and thus in cached
files on the puppet server and host).  Every other encrypted data solution I've
found for Puppet involves having the puppet master do the decryption from encrypted
Hiera keys.  This module attempts to provide an alternative solution, doing the
decryption on the agent itself.

## Setup

### Setup Requirements

This module will not manage gpg keys.  It's assumed that your gpg secret keyring
is already prepared.

### Beginning with gpgfile

    gpgfile { '/etc/secret/passwordfile':
      ensure           => decrypted ,
      owner            => root ,
      group            => root ,
      mode             => '0600' ,
      encrypted_suffix => '.asc' ,
      source           => "puppet:///${module_name}/passwordfile.gpg" ,
      gpg_keyring      => 'secring.gpg' ,
    }

## Usage

`gpgfile` transfers a single encrypted file to the host and locally
decrypts it using `gpg`.  The file will be decrypted as the final owner,
but can be decrypted using any gpg secret keyring to which that user has
access.  The encrypted file is preserved, so that the agent can determine
if it's changed or not, rather than attempting to decrypt every time.
The encrypted file can be saved into the same directory as the target file
or into any specified directory, and it can be named after the target file
(with a suffix, `.gpg` by default) or can be given an arbitrary name.

## Reference

### Types

#### gpgfile

#### Parameters

All parameters are optional, unless otherwise noted.

* `ensure`:
  Ensures whether the resource is present.  Valid options: `decrypted`,
  `encrypted`, `absent`, or `present` (which is the same as `decrypted`).
  Defaults to `decrypted`.
* `content`:
  The encrypted file contents.  Either `source` or `content` must be
  specified.
* `encrypted_dir`:
  The directory in which to store the encrypted file.  Defaults to the
  same directory as the decrypted file.
* `encrypted_mode`
  The permissions to use for the encrypted file.  Defaults to the same
  permissions as the decrypted file.
* `encrypted_name`
  The filename to use when storing the encrypted file.  Defaults to
  undefined.  If provided, overrides the `encrypted_suffix`.
* `encrypted_suffix`
  The suffix to append to the decrypted filename when storing the
  encrypted file.  Defaults to `.gpg`.
* `group`
  The group that owns both the decrypted and encrypted files.  Defaults to
  `root`.
* `keyring`
  The gpg keyring to use for decryption.  Must be accessible by `owner`.
  If it begins with `~`, it will be relative to `owner`'s home directory.
  If this is a bare file, it will be located in `~/.gnupg`.  Defaults to
  `secring.gpg`.
* `mode`
  The permission of the decrypted file.  Must be an octal mode for
  this type.  Defaults to `0600`.  A warning will be generated if any
  permissions are granted to `other` (i.e. the last octal digit is
  anything other than `0`)
* `owner`
  The owner of both the decrypted and encrypted files.  Defaults to
  `root`.
* `source`
  The source of the encrypted file.  Either `source` or `content` must
  be specified.

## Limitations

Only tested on RedHat 5.x and 6.x systems.

## Development

See [CONTRIBUTING.md](https://github.com/jearls/puppet-gpgfile/blob/master/CONTRIBUTING.md)

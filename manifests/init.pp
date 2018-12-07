# Defined Type: gpgfile
# ===========================
#
# This implements the `gpgfile` defined type.
#
# Parameters
# ----------
#
# * `ensure`:
#   Ensures whether the resource is present.  Valid options: `decrypted`,
#   `encrypted`, `absent`, or `present` (which is the same as `decrypted`).
#   Defaults to `decrypted`.
# * `content`:
#   The encrypted file contents.  Either `source` or `content` must be
#   specified.
# * `encrypted_dir`:
#   The directory in which to store the encrypted file.  Defaults to the
#   same directory as the decrypted file.
# * `encrypted_mode`
#   The permissions to use for the encrypted file.  Defaults to the same
#   permissions as the decrypted file.
# * `encrypted_name`
#   The filename to use when storing the encrypted file.  Defaults to
#   undefined.  If provided, overrides the `encrypted_suffix`.
# * `encrypted_suffix`
#   The suffix to append to the decrypted filename when storing the
#   encrypted file.  Defaults to `.gpg`.
# * `group`
#   The group that owns both the decrypted and encrypted files.  Defaults to
#   `root`.
# * `keyring`
#   The gpg keyring to use for decryption.  Must be accessible by `owner`.
#   If it begins with `~`, it will be relative to `owner`'s home directory.
#   If this is a bare file, it will be located in `~/.gnupg`.  Defaults to
#   `secring.gpg`.
# * `mode`
#   The permission of the decrypted file.  Must be an octal mode for
#   this type.  Defaults to `0600`.  A warning will be generated if any
#   permissions are granted to `other` (i.e. the last octal digit is
#   anything other than `0`)
# * `owner`
#   The owner of both the decrypted and encrypted files.  Defaults to
#   `root`.
# * `source`
#   The source of the encrypted file.  Either `source` or `content` must
#   be specified.
#
# Examples
# --------
#
# @example
#   gpgfile { '/etc/secret/passwordfile':
#     ensure           => decrypted ,
#     owner            => root ,
#     group            => root ,
#     mode             => '0600' ,
#     encrypted_suffix => '.asc' ,
#     source           => "puppet:///${module_name}/passwordfile.gpg" ,
#     gpg_keyring      => 'secring.gpg' ,
#   }
#
# Authors
# -------
#
# Johnson Earls <johnson.earls@gmail.com>
#
# Copyright
# ---------
#
# Copyright 2016 Johnson Earls
#

define gpgfile (
  $ensure           = 'decrypted' ,
  $content          = undef ,
  $encrypted_dir    = undef ,
  $encrypted_mode   = undef ,
  $encrypted_name   = undef ,
  $encrypted_suffix = '.gpg' ,
  $group            = 'root' ,
  $keyring          = 'secring.gpg' ,
  $mode             = '0600' ,
  $owner            = 'root' ,
  $path             = undef ,
  $source           = undef ,
) {

  include gpgfile::params

  # validations

  # ensure either 'content' or 'source' is provided
  if $content == undef and $source == undef {
    fail('Either `content` or `source` must be provided')
  }

  # validate `ensure`
  validate_re($ensure,
              [ '^absent$', '^encrypted$', '^decrypted$', '^present$' ],
              '`ensure` must be one of `decrypted`, `encrypted`, `present`, or `absent`')

  # validate mode: must be numeric, and must end with `0` digit.
  validate_re($mode, '^0[0-7][0-7]+0$', '`mode` must be numeric, and must end with `0`')

  # encrypted_name must not have a directory component.
  if $encrypted_name != undef {
    validate_re($encrypted_name, '^[^/]+$', '`encrypted_name` must not contain `/`')
  }

  # fill in unspecified parameters

  if $path != undef {
    $decrypted_file = $path
  } else {
    $decrypted_file = $name
  }

  if $encrypted_mode != undef {
    $real_encrypted_mode = $encrypted_mode
  } else {
    $real_encrypted_mode = $mode
  }

  if $encrypted_dir != undef {
    $real_encrypted_dir = $encrypted_dir
  } else {
    $real_encrypted_dir = dirname($decrypted_file)
  }

  if $encrypted_name != undef {
    $encrypted_file = "${real_encrypted_dir}/${encrypted_name}"
  } else {
    $decrypted_filename = basename($decrypted_file)
    $encrypted_file = "${real_encrypted_dir}/${decrypted_filename}${encrypted_suffix}"
  }

  if $encrypted_file == $decrypted_file {
    fail('encrypted and decrypted files must not be identical')
  }

  $esc_keyring = regsubst($keyring, "'", "'\\\\''", 'G')
  $esc_enc_file = regsubst($encrypted_file, "'", "'\\\\''", 'G')
  $esc_dec_file = regsubst($decrypted_file, "'", "'\\\\''", 'G')

  case $ensure {
    absent: {
      $encrypted_ensure = absent
      $decrypted_ensure = absent
      $decrypted_replace = undef
      $exec_noop = true
    }
    encrypted: {
      $encrypted_ensure = file
      $decrypted_ensure = undef
      $decrypted_replace = undef
      $exec_noop = true
    }
    decrypted, present: {
      $encrypted_ensure = file
      $decrypted_ensure = file
      $decrypted_replace = false
      $exec_noop = false
    }
    default: {
      fail('Should not have gotten here!')
    }
  }

  file { $encrypted_file:
    ensure  => $encrypted_ensure ,
    owner   => $owner ,
    group   => $group ,
    mode    => $real_encrypted_mode ,
    source  => $source ,
    content => $content ,
    notify  => Exec["gpgfile-${decrypted_file}"] ,
  }

  if $decrypted_ensure {
    file { $decrypted_file:
      ensure  => $decrypted_ensure ,
      owner   => $owner ,
      group   => $group ,
      mode    => $mode ,
      replace => $decrypted_replace ,
      notify  => Exec["gpgfile-${decrypted_file}"] ,
    }
  }

  # decrypt the file using the correct filename
  # on failure, remove the encrypted file so it will try again
  $gpg_exec = "${gpgfile::params::gpg_command} --decrypt \
--keyring '${esc_keyring}' \
--yes \
-o '${esc_dec_file}' \
'${esc_enc_file}' \
|| ( ${gpgfile::params::rm_command} -f '${esc_enc_file}'; exit 2 )"

  exec { "gpgfile-${decrypted_file}":
    path        => $gpgfile::params::exec_path ,
    command     => $gpg_exec ,
    refreshonly => true ,
    user        => $owner ,
    group       => $group ,
    noop        => $exec_noop ,
  }

}

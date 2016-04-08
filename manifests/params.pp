
class gpgfile::params {
  case $::osfamily {
    'RedHat': {
      $gpg_command = '/usr/bin/gpg'
    }
    default: {
      warning("Warning - unsupported OS family ${::osfamily} - correct operation not guaranteed")
      $gpg_command = '/usr/bin/gpg'
    }
  }
}


class gpgfile::params {
  case $::osfamily {
    'RedHat': {
      $exec_path = [ '/bin', '/usr/bin' ]
      $gpg_command = 'gpg'
      $rm_command = 'rm'
    }
    default: {
      warning("Warning - unsupported OS family ${::osfamily} - correct operation not guaranteed")
      $exec_path = [ '/bin', '/usr/bin' ]
      $gpg_command = 'gpg'
      $rm_command = 'rm'
    }
  }
}

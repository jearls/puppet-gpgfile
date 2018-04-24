require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'
require 'puppet/util/checksums'

Puppet::Type.newtype(:gpgfile) do
  @doc = <<-ENDDOC
      Manages files that come from GPG-encrypted sources.
      The `gpgfile` type accepts GPG-encrypted content (either directly
      in the `content` attribute or from the Puppet fileserver via the
      `source` attribute) and decrypts it locally on the target system;
      the content does not appear in the catalog or "over the wire" in
      unencrypted form.
    ENDDOC

  ensurable do
    defaultvalues

    defaultto :present
  end

  newparam(:path, namevar: true) do
    desc "The decrypted file"

    validate do |value|
      unless (Puppet::Util.absolute_path?(value, :posix) or Puppet::Util.absolute_path?(value, :windows))
        raise ArgumentError, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Desired file owner."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Desired file group."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Desired file mode."
  end

  newparam(:gpguser, required_features: :decrypt_as_user) do
    desc "The user as whom the file should be decrypted."
  end

  newparam(:backup) do
    desc "Controls the filebucketing behavior of the final file and see File type reference for its use."
    defaultto 'puppet'
  end

  newparam(:replace, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Whether to replace a file that already exists on the local system."
    defaultto :true
  end

  newparam(:validate_cmd) do
    desc "Validates file."
  end

  # Inherit File parameters
  newparam(:selinux_ignore_defaults) do
  end

  newparam(:selrange) do
  end

  newparam(:selrole) do
  end

  newparam(:seltype) do
  end

  newparam(:seluser) do
  end

  newparam(:show_diff) do
  end
  # End file parameters

  # Autorequire the file we are generating below
  autorequire(:file) do
    [self[:path]]
  end

end

require 'spec_helper'

describe 'gpgfile', :type => :define do

  let(:title) { '/tmp/data' }

  let(:facts) {{ :osfamily => 'RedHat' }}

  context 'with neither `content` nor `source` parameter' do
    let(:params) {{ }}
    it { should raise_error(Puppet::Error, /Either `content` or `source` must be provided/) }
  end

  context 'with invalid `ensure` parameter' do
    let(:params) {{ :content => 'data' , :ensure => 'foo'}}
    it { should raise_error(Puppet::Error, /`ensure` must be one of `decrypted`, `encrypted`, `present`, or `absent`/) }
  end

  context 'with non-numeric `mode` parameter' do
    let(:params) {{ :content => 'data' , :mode => 'ug=rw'}}
    it { should raise_error(Puppet::Error, /`mode` must be numeric, and must end with `0`/) }
  end

  context 'with too-permissive `mode` parameter' do
    let(:params) {{ :content => 'data' , :mode => '0755'}}
    it { should raise_error(Puppet::Error, /`mode` must be numeric, and must end with `0`/) }
  end

  context 'with directory in `encrypted_name` parameter' do
    let(:params) {{ :content => 'data' , :encrypted_name => 'foo/bar'}}
    it { should raise_error(Puppet::Error, /`encrypted_name` must not contain `\/`/) }
  end

  context 'with default parameters' do
    let(:params) {{ :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.gpg').with({
        'ensure'  => 'file' ,
        'owner'   => 'root' ,
        'group'   => 'root' ,
        'mode'    => '0600' ,
        'content' => 'data' ,
      })
      is_expected.to contain_file('/tmp/data').with({
        'ensure'  => 'file' ,
        'owner'   => 'root' ,
        'group'   => 'root' ,
        'mode'    => '0600' ,
        'replace' => false ,
      })
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command("/usr/bin/gpg --decrypt --keyring 'secring.gpg' < '/tmp/data.gpg' > '/tmp/data'")
    }
  end

  context 'with source instead of content' do
    let(:params) {{ :source => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.gpg').with_source('data')
    }
  end

  context 'with path' do
    let(:params) {{ :path => '/tmp/foo' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/foo.gpg').with_content('data')
      is_expected.to contain_file('/tmp/foo')
      is_expected.to contain_exec('gpgfile-/tmp/foo').with_command(/< '\/tmp\/foo.gpg' > '\/tmp\/foo'/)
    }
  end

  context 'with different encrypted suffix' do
    let(:params) {{ :encrypted_suffix => '.asc' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.asc').with_content('data')
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/< '\/tmp\/data.asc'/)
    }
  end

  context 'with different encrypted directory' do
    let(:params) {{ :encrypted_dir => '/var/tmp' , :content => 'data'}}
    it {
      is_expected.to contain_file('/var/tmp/data.gpg').with_content('data')
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/< '\/var\/tmp\/data.gpg'/)
    }
  end

  context 'with different encrypted name' do
    let(:params) {{ :encrypted_name => 'foo' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/foo').with_content('data')
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/< '\/tmp\/foo'/)
    }
  end

  context 'with different encrypted mode' do
    let(:params) {{ :encrypted_mode => '0644' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.gpg').with_mode('0644')
    }
  end

  context 'with different owner' do
    let(:params) {{ :owner => 'foo' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.gpg').with_owner('foo')
      is_expected.to contain_file('/tmp/data').with_owner('foo')
      is_expected.to contain_exec('gpgfile-/tmp/data').with_user('foo')
    }
  end

  context 'with different group' do
    let(:params) {{ :group => 'foo' , :content => 'data'}}
    it {
      is_expected.to contain_file('/tmp/data.gpg').with_group('foo')
      is_expected.to contain_file('/tmp/data').with_group('foo')
      is_expected.to contain_exec('gpgfile-/tmp/data').with_group('foo')
    }
  end

  context 'with different keyring' do
    let(:params) {{ :keyring => 'foo' , :content => 'data'}}
    it {
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/--keyring 'foo'/)
    }
  end

  context 'with decrypted filename with special character' do
    let(:params) {{ :path => "/tmp/foo's", :content => 'data'}}
    it {
      is_expected.to contain_exec("gpgfile-/tmp/foo's").with_command(/< '\/tmp\/foo'\\''s.gpg' > '\/tmp\/foo'\\''s'/)
    }
  end

  context 'with encrypted filename with special character' do
    let(:params) {{ :encrypted_name => "foo's", :content => 'data'}}
    it {
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/< '\/tmp\/foo'\\''s'/)
    }
  end

  context 'with keyring with special character' do
    let(:params) {{ :keyring => "foo's", :content => 'data'}}
    it {
      is_expected.to contain_exec('gpgfile-/tmp/data').with_command(/--keyring 'foo'\\''s'/)
    }
  end

# context 'on a non-RedHat OS' do
#   let(:facts) {{ :osfamily => 'Debian' }}
#   let(:params) {{ :content => 'data'}}
#   it 'should give warning' do
#     scope.expects(:warning)
#   end
# end

end

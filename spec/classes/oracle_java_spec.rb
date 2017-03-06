require 'spec_helper'
 
describe 'oracle_java', :type => 'class' do

  context "Should install oracle java 7" do
  let(:facts) { { 
    :host => Hash.new,
    :osfamily => 'RedHat',
    :kernel => 'Linux',
    :architecture => 'x86_64' } }
  
    it do
      should contain_java__oracle('7').with(
        :ensure => 'present')
    end
  end

  context "Should install sun java 6 on Debian" do

    let(:params) { { :versions => ['6'] } }
    let(:facts) { { :host => Hash.new, :osfamily => 'Debian', :lsbdistid => 'ubuntu', 
      :lsbdistcodename => 'trusty',
      :lsbdistrelease => '14.04',
      :lsbdistid => 'Ubuntu',
      :kernel => 'Linux',
      :architecture => 'x86_64' } }
    it do
      should contain_package('oracle-java6-installer')
      should contain_exec('Set default Java version: java-6-sun').with(
        'command'   => 'update-java-alternatives -s java-6-sun'
      )
    end
  end

  context "Should install oracle java  6 and 7" do

    let(:params) { { :versions => ['7','6'] } }
    let(:facts) { { :host => Hash.new, :osfamily => 'RedHat',
    :kernel => 'Linux',
    :architecture => 'x86_64' } }
    it do
      should contain_java__oracle('6')
      should contain_java__oracle('7')
    end
  end

  context "Should install sun java 6 and oracle java 8, setting 8 as the default" do

    let(:params) { { :versions => ['6','8'], :default_ver => '8' } }
    let(:facts) { { :host => Hash.new, :osfamily => 'RedHat',
    :kernel => 'Linux',
    :architecture => 'x86_64' } }
    it do
      should contain_java__oracle('8')
      should contain_java__oracle('6')
      should contain_exec('Set default Java version: jdk1.8')
    end
  end

  context "Should fail with unsupported OS family" do

    let(:facts) { { :osfamily => 'Solaris',
    :kernel => 'Linux',
    :architecture => 'x86_64' } }

    it do
      should raise_error(Puppet::Error, /oracle_java - Unsupported Operating System family: Solaris/)
    end
  end

  context "Should link to jdk's on Redhat family" do
    let(:facts) { { :host => Hash.new, :osfamily => 'RedHat',
    :kernel => 'Linux',
    :architecture => 'x86_64' } }
    let(:params) { { :versions => ['7','8'], :default_ver => '8' } }

    it do
      should contain_java__oracle('7')
      should contain_java__oracle('8')
      should contain_exec('Create symlink for jdk in /var/lib/jvm/jdk8').with(
        'command' => 'ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort | tail -1) /usr/lib/jvm/jdk8'
      )
      should contain_exec('Create symlink for jdk in /var/lib/jvm/jdk7').with(
          'command' => 'ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort | tail -1) /usr/lib/jvm/jdk7'
      )
      should contain_exec('Install alternatives for java 7').with(
          'command' => 'alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort -V| tail -1)/bin/java 200000'
      )
      should contain_exec('Install alternatives for javac 7').with(
          'command' => 'alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort -V| tail -1)/bin/javac 200000'
      )
      should contain_exec('Install alternatives for java 8').with(
          'command' => 'alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort -V| tail -1)/bin/java 200000'
      )
      should contain_exec('Install alternatives for javac 8').with(
          'command' => 'alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort -V| tail -1)/bin/javac 200000'
      )
    end
  end
end

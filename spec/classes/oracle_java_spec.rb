require 'spec_helper'
 
describe 'oracle_java', :type => 'class' do

  let(:facts) { { :host => Hash.new, :osfamily => 'Debian' } }
  
  context "Should install oracle java 7" do
    it do
      should contain_package('oracle-java7-jdk')
    end
  end

  context "Should install sun java 6" do

    let(:params) { { :versions => ['6'] } }

    it do
      should contain_package('sun-java6-jdk')
      should contain_exec('Set default Java version: java-6-sun').with(
        'command'   => 'update-java-alternatives -s java-6-sun'
      )
    end
  end

  context "Should install sun java 6 and oracle java 7" do

    let(:params) { { :versions => ['7','6'] } }

    it do
      should contain_package('sun-java6-jdk')
      should contain_package('oracle-java7-jdk')
    end
  end

  context "Should install sun java 6 and oracle java 8, setting 8 as the default" do

    let(:params) { { :versions => ['6','8'], :default_ver => '8' } }

    it do
      should contain_package('oracle-java8-jdk')
      should contain_package('sun-java6-jdk')
      should contain_exec('Set default Java version: java-8-oracle').with(
        'command'   => 'update-java-alternatives -s java-8-oracle'
      )
    end
  end

  context "Should fail with unsupported OS family" do

    let(:facts) { { :osfamily => 'Solaris' } }

    it do
      should raise_error(Puppet::Error, /oracle_java - Unsupported Operating System family: Solaris/)
    end
  end

  context "Should link to jdk's on Redhat family" do
    let(:facts) { { :host => Hash.new, :osfamily => 'RedHat' } }
    let(:params) { { :versions => ['7','8'], :default_ver => '8' } }

    it do
      should contain_package('jdk-1.7*')
      should contain_package('jdk1.8*')
      should contain_exec('Create symlink for jdk in /var/lib/jvm/jdk8').with(
        'command' => 'ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort | tail -1) /usr/lib/jvm/jdk8'
      )
      should contain_exec('Create symlink for jdk in /var/lib/jvm/jdk7').with(
          'command' => 'ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort | tail -1) /usr/lib/jvm/jdk7'
      )
      should contain_exec('Install alternatives for java 7').with(
          'command' => 'alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort | tail -1)/bin/java 200000'
      )
      should contain_exec('Install alternatives for javac 7').with(
          'command' => 'alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.7 | sort | tail -1)/bin/javac 200000'
      )
      should contain_exec('Install alternatives for java 8').with(
          'command' => 'alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort | tail -1)/bin/java 200000'
      )
      should contain_exec('Install alternatives for javac 8').with(
          'command' => 'alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.8 | sort | tail -1)/bin/javac 200000'
      )
    end
  end
end

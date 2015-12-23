require 'spec_helper'
 
describe 'oracle_java', :type => 'class' do

  let(:facts) { { :host => Hash.new, :osfamily => 'Debian' } }
  
  context "Should install oracle java 7" do
    it do
      should contain_package('oracle-java7-jdk')
    end
  end

  context "Should install sun java 6" do

    let(:params) { { :versions => [6] } }

    it do
      should contain_package('sun-java6-jdk')
      should contain_exec('Set default Java version: java-6-sun').with(
        'command'   => 'update-java-alternatives -s java-6-sun'
      )
    end
  end

  context "Should install sun java 6 and oracle java 7" do

    let(:params) { { :versions => [7,6] } }

    it do
      should contain_package('sun-java6-jdk')
      should contain_package('oracle-java7-jdk')
    end
  end

  context "Should install sun java 6 and oracle java 8, setting 8 as the default" do

    let(:params) { { :versions => [6,8], :default_ver => 8 } }

    it do
      should contain_package('oracle-java8-jdk')
      should contain_package('sun-java6-jdk')
      should contain_exec('Set default Java version: java-8-oracle').with(
        'command'   => 'update-java-alternatives -s java-8-oracle'
      )
    end
  end
end

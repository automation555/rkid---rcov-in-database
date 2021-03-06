require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rkid do
  
  before(:all) do
    require 'spec/fixtures/test_class.rb'
    Rkid.analyze { TestedClass.new.tested_method }
  end
  
  describe '::analyze' do
    before do
      @file = Rkid::File.find_by_name("./spec/fixtures/test_class.rb")
    end
    
    it 'records classes and methods' do
      methods = Rkid::Klass.find_by_name('TestedClass').methods
      methods.find_by_name('tested_method').should_not be_nil
      methods.find_by_name('untested_method').should be_nil
    end
  
    it 'records callsites of methods' do
      method = Rkid::Klass.find_by_name('TestedClass').methods.find_by_name('tested_method')
      callsite = method.callsites.first
      callsite.count.should == 1
      callsite.frames.first.line.number.should == File.open(__FILE__).readlines.index("    Rkid.analyze { TestedClass.new.tested_method }\n") + 1
      callsite.frames.first.line.file.name.should == "./spec/rkid/analyzer_spec.rb"
    end

    it 'records the source of parsed files' do
      @file.lines.first.body.should == File.open("./spec/fixtures/test_class.rb").readline
    end
    
    it 'indicates whether lines are covered' do
      @file.lines.first.should_not be_covered
      @file.lines[1].should be_covered
      @file.lines[-1].should_not be_covered
    end
  end
end
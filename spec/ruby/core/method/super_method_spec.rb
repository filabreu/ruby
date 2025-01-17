require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Method#super_method" do
  it "returns the method that would be called by super in the method" do
    obj = MethodSpecs::C.new
    obj.extend MethodSpecs::OverrideAgain
    meth = obj.method(:overridden)

    s_meth = meth.super_method
    s_meth.owner.should == MethodSpecs::C
    s_meth.receiver.should == obj
    s_meth.name.should == :overridden

    ss_meth = meth.super_method.super_method
    ss_meth.owner.should == MethodSpecs::BetweenBAndC
    ss_meth.receiver.should == obj
    ss_meth.name.should == :overridden

    sss_meth = meth.super_method.super_method.super_method
    sss_meth.owner.should == MethodSpecs::B
    sss_meth.receiver.should == obj
    sss_meth.name.should == :overridden
  end

  it "returns nil when there's no super method in the parent" do
    method = Object.new.method(:method)
    method.super_method.should == nil
  end

  it "returns nil when the parent's method is removed" do
    klass = Class.new do
      def overridden; end
    end
    sub = Class.new(klass) do
      def overridden; end
    end
    object = sub.new
    method = object.method(:overridden)

    klass.class_eval { undef :overridden }

    method.super_method.should == nil
  end

  # https://github.com/jruby/jruby/issues/7240
  context "after changing an inherited methods visibility" do
    it "calls the proper super method" do
      MethodSpecs::InheritedMethods::C.new.derp.should == 'BA'
    end

    ruby_version_is ""..."3.2" do
      it "returns the expected super_method" do
        method = MethodSpecs::InheritedMethods::C.new.method(:derp)
        method.super_method.owner.should == MethodSpecs::InheritedMethods::A
      end
    end

    ruby_version_is "3.2" do
      it "returns the expected super_method" do
        method = MethodSpecs::InheritedMethods::C.new.method(:derp)
        method.super_method.owner.should == MethodSpecs::InheritedMethods::B
      end
    end
  end

  context "after aliasing an inherited method" do
    it "returns the expected super_method" do
      method = MethodSpecs::InheritedMethods::C.new.method(:meow)
      method.super_method.owner.should == MethodSpecs::InheritedMethods::A
    end
  end
end

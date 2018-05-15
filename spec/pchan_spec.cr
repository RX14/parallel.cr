require "./spec_helper"

describe PChan do
  it "sends and recieves" do
    chan = PChan(Int32).new

    chan.send 1
    chan.receive.should eq(1)

    chan.send Int32::MAX
    chan.receive.should eq(Int32::MAX)
  end

  it "sends and receives across processes" do
    in_chan = PChan(Int32).new
    out_chan = PChan(Int32).new

    pspawn do
      2.times do
        item = in_chan.receive
        out_chan.send item
      end
    end

    in_chan.send 1
    out_chan.receive.should eq(1)

    in_chan.send Int32::MAX
    out_chan.receive.should eq(Int32::MAX)
  end

  it "raises a compile-time error when creating a PChan of a Reference" do
    status, output = build_code "PChan(String).new"
    status.success?.should eq(false)
    output.should contain("Type is a pointer!")
  end

  it "raises a compile-time error when creating a PChan of a Struct containing a pointer" do
    status, output = build_code "PChan(Bytes).new"
    status.success?.should eq(false)
    output.should contain("Type is a pointer!")
  end
end

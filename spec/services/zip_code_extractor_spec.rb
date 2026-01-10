require 'rails_helper'

RSpec.describe ZipCodeExtractor do
  it "extracts the ZIP code from a valid address" do
    address = "123 Main St, Springfield, IL 62701"
    expect(ZipCodeExtractor.extract(address)).to eq("62701")
  end

  it "returns nil when no ZIP code is present" do
    address = "123 Main St, Springfield, IL"
    expect(ZipCodeExtractor.extract(address)).to be_nil
  end
end

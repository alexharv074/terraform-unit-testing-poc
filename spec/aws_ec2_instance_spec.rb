require "spec_helper"
require "json"

describe "aws_instance.this" do
  context "with instance_count 0" do
    subject(:r) do
      TerraformTesting.new.eval(".", "aws_instance.this", {
        "variables": {
          "instance_count": 0,
        },
      })
    end

    it "should have be an empty list" do
      expect(r).to eq []
    end
  end

  context "with no EBS volumes" do
    subject(:r) do
      TerraformTesting.new.eval(".", "aws_instance.this", {
        "variables": {
          "instance_count": 1,
          "ami": "ami-08589eca6dcc9b39c",
          "instance_type": "t2.micro",
          "ebs_block_device": []
        },
        "locals": {
          "key_name": "default"
        }
      })[0]
    end

    it "should have AMI ami-08589eca6dcc9b39c" do
      expect(r.ami).to eq "ami-08589eca6dcc9b39c"
    end

    it "should have instance_type t2.micro" do
      expect(r.instance_type).to eq "t2.micro"
    end
  end

  context "with an EBS volume" do
    subject(:r) do
      TerraformTesting.new.eval(".", "aws_instance.this", {
        "variables": {
          "instance_count": 1,
          "ami": "ami-08589eca6dcc9b39c",
          "instance_type": "t2.micro",
          "ebs_block_device": [
            {
              "device_name": "/dev/sdg",
              "volume_size": 5,
              "volume_type": "gp2",
              "delete_on_termination": false,
            }
          ]
        },
        "locals": {
          "key_name": "default"
        }
      })[0]
    end

    it "should have an ebs_block_device list" do
      expect(r.ebs_block_device).to be_an Array
    end

    it "should have one ebs_block_device" do
      expect(r.ebs_block_device.length).to eq 1
    end

    it "device_name should be /dev/sdg" do
      expect(r.ebs_block_device[0].device_name).to eq "/dev/sdg"
    end
  end
end

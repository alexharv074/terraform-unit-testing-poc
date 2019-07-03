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

  context "with two EBS volumes" do
    subject(:r) do
      TerraformTesting.new.eval(".", "aws_instance.this", {
        "variables": {
          "instance_count": 1,
          "ami": "ami-08589eca6dcc9b39c",
          "instance_type": "t2.micro",
          "ebs_block_device": [
            {
              "device_name": "/dev/sdg",
              "volume_size": 10,
              "volume_type": "gp2",
              "delete_on_termination": false,
              "mount_point": "/data"
            },
            {
              "device_name": "/dev/sdh",
              "volume_size": 5,
              "volume_type": "gp2",
              "delete_on_termination": false,
              "mount_point": "/home"
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

    it "should have two ebs_block_devices" do
      expect(r.ebs_block_device.length).to eq 2
    end

    it "device_name 0 should be /dev/sdg" do
      expect(r.ebs_block_device[0].device_name).to eq "/dev/sdg"
    end

    context 'user_data' do
      before do
        @lines = r.user_data.split("\n")
      end
      it "should have a mkfs line" do
        expect(@lines[1]).to match %r{mkfs -t xfs /dev/.*}
      end
      it "should have a mkdir line" do
        expect(@lines[2]).to match %r{mkdir -p /.*}
      end
      it "should have a mount line" do
        expect(@lines[3]).to match %r{mount /.* /.*}
      end
    end
  end
end

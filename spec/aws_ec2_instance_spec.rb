require "spec_helper"
require "json"

$terraform = "#{ENV['HOME']}/go/bin/terraform"

def terraform_eval(addr, mock_data)
  mock_data_json = mock
  %x{#{$terraform} testing eval . #{addr} -}
end

describe "aws_instance.this" do
  context "instance_count is 0" do
    result = terraform_eval("aws_instance.this", {
      "variables" => {
        "instance_count" => 0,
      },
    })
  require 'pry'; binding.pry
  end
end

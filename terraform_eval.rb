require 'json'
require 'open3'

class TerraformTesting
  @@terraform = "#{ENV['HOME']}/go/bin/terraform"

  def eval(path, addr, mock_data)
    command = "#{@@terraform} testing eval #{path} #{addr} -"
    stdout, status = Open3.capture2(command, stdin_data: mock_data.to_json)
    result_raw = JSON.parse(stdout)
    return prepare_result(result_raw["value"], result_raw["type"])
  end

 private

  def prepare_result(value, type)
    if value.nil?
      return nil
    end

    if type.is_a?(Array)
      case type[0]
      when "object"
        ret = Object.new
        value.each do |k,v|
          ret.singleton_class.instance_eval { attr_reader k.to_sym }
          ret.instance_variable_set("@#{k}", prepare_result(v, type[1][k]))
        end
        return ret
      when "tuple"
        ret = []
        value.each_with_index do |v, i|
          ret << prepare_result(v, type[1][i])
        end
        return ret
      when "list"
        ret = []
        value.each do |v|
          ret << prepare_result(v, type[1])
        end
        return ret
      when "map"
        ret = {}
        value.each do |k,v|
          ret[k] = prepare_result(v, type[1])
        end
        return ret
      when "set"
        ret = []
        value.each do |v|
          ret << prepare_result(v, type[1])
        end
        return ret
      end
    end

    return value
  end
end

mock_data = {
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
}

t = TerraformTesting.new
result = t.eval(".", "aws_instance.this", mock_data)

r = result[0]
require 'pry'; binding.pry

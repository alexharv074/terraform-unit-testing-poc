import json
import subprocess


def terraform_eval(addr, mock_data):
    mock_data_json = json.dumps(mock_data)

    proc = subprocess.Popen(
        ['/Users/alexharvey/go/bin/terraform', 'testing', 'eval', '.', addr, '-'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    (out, err) = proc.communicate(mock_data_json)

    try:
        result_raw = json.loads(out)
    except:
        raise RuntimeError(err)

    if "diagnostics" in result_raw:
        errs = [diag for diag in result_raw["diagnostics"]
                if diag["severity"] == "error"]
        if len(errs) > 0:
            raise RuntimeError(errs)

    return prepare_result(result_raw["value"], result_raw["type"])


def prepare_result(rawVal, ty):
    class Object(object):
        pass

    if rawVal == None:
        return None

    if isinstance(ty, list):
        kind = ty[0]
        if kind == "object":
            ret = Object()
            for k, v in rawVal.iteritems():
                attrTy = ty[1][k]
                setattr(ret, k, prepare_result(v, attrTy))
            return ret
        if kind == "tuple":
            return [prepare_result(v, ty[1][i]) for i, v in enumerate(rawVal)]
        elif kind == "list":
            return [prepare_result(v, ty[1]) for v in rawVal]
        elif kind == "map":
            return {k: prepare_result(v, ty[1]) for k, v in rawVal.iteritems()}
        elif kind == "set":
            # Not using set here because not all of our representations are hashable
            return [prepare_result(v, ty[1]) for v in rawVal]

    return rawVal

result = terraform_eval('aws_instance.this', {
  "variables": {
    "instance_count": 1,
    "ami": "ami-08589eca6dcc9b39c",
    "instance_type": "t2.micro",
    "ebs_block_device": []
  },
  "locals": {
    "key_name": "default"
  }
})
print result

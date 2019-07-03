# Terraform Testing Eval Proof of Concept

See [Issue #21628](https://github.com/hashicorp/terraform/issues/21628).

## Installation

To install and build dependencies including the modified Terraform binary:

```text
▶ brew install golang
▶ git clone git@github.com:hashicorp/terraform.git
▶ cd terraform/
▶ git checkout f-testing-eval-prototype
▶ git rebase master
▶ make dev
==> Checking that code complies with gofmt requirements...
GO111MODULE=off go get -u golang.org/x/tools/cmd/stringer
GO111MODULE=off go get -u golang.org/x/tools/cmd/cover
GO111MODULE=off go get -u github.com/golang/mock/mockgen
GOFLAGS=-mod=vendor go generate ./...
2019/06/15 17:15:42 Generated command/internal_plugin_list.go
# go fmt doesn't support -mod=vendor but it still wants to populate the
# module cache with everything in go.mod even though formatting requires
# no dependencies, and so we're disabling modules mode for this right
# now until the "go fmt" behavior is rationalized to either support the
# -mod= argument or _not_ try to install things.
GO111MODULE=off go fmt command/internal_plugin_list.go > /dev/null
go install -mod=vendor .
▶ ~/go/bin/terraform -v
Terraform v0.12.3-dev
```

## Usage

### Testing terraform testing eval manually

```text
▶ export PATH=~/go/bin:$PATH
▶ terraform testing eval . aws_instance.this spec/fixtures/simplest_instance_count_0.json
{
  "value": [],
  "type": [
    "tuple",
    []
  ]
}
```

### Installing Rspec dependencies

Assumes you have:

- Ruby (tested on 2.4.1)
- RubyGems
- Bundler

```text
▶ bundle install
```

### Run the suite

```text
▶ bundle exec rake
```

Expected output:

```text
▶ bundle exec rake
/Users/alexharvey/.rvm/rubies/ruby-2.4.1/bin/ruby -I/Users/alexharvey/.rvm/gems/ruby-2.4.1/gems/rspec-core-3.8.1/lib:/Users/alexharvey/.rvm/gems/ruby-2.4.1/gems/rspec-support-3.8.2/lib /Users/alexharvey/.rvm/gems/ruby-2.4.1/gems/rspec-core-3.8.1/exe/rspec --pattern spec/\*\*\{,/\*/\*\*\}/\*_spec.rb

aws_instance.this
  with instance_count 0
    should have be an empty list
  with no EBS volumes
    should have AMI ami-08589eca6dcc9b39c
    should have instance_type t2.micro
  with two EBS volumes
    should have an ebs_block_device list
    should have two ebs_block_devices
    device_name 0 should be /dev/sdg
    user_data
      should have a mkfs line
      should have a mkdir line
      should have a mount line

Finished in 8 seconds (files took 0.18005 seconds to load)
9 examples, 0 failures
```

The suite is in [./spec/aws_ec2_instance_spec.rb](./spec/aws_ec2_instance_spec.rb). Supporting Ruby code is in [./spec/spec_helper.rb](./spec/spec_helper.rb).

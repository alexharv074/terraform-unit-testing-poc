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

### Simplest test case - instance_count 0

```text
▶ ~/go/bin/terraform plan
```

All good.

```text
▶ ~/go/bin/terraform testing eval . aws_instance.this spec/fixtures/simplest_instance_count_0.json
{
  "value": [],
  "type": [
    "tuple",
    []
  ]
}
```

### Simplest test case - instance_count 1

```text
▶ ~/go/bin/terraform testing eval . aws_instance.this spec/fixtures/simplest_instance_count_1.json
```

Errors out with:

```json
  "diagnostics": [
    {
      "severity": "error",
      "summary": "Unsupported block type",
      "detail": "Blocks of type \"dynamic\" are not expected here.",
      "range": {
        "filename": "main.tf",
        "start": {
          "line": 13,
          "column": 3,
          "byte": 197
        },
        "end": {
          "line": 13,
          "column": 10,
          "byte": 204
        }
      }
    }
  ]
```

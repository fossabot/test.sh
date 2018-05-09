# test.sh
Tiny expect library for unit testing bash scripts

test.sh provides two functions: `expect` and `test-end`.

`expect` takes three arguments:
$1 - command to be called
$2 - an argument
$3 - the expected exit code

each `expect` call stores the functions exit code and whether the exit code matched the expected code.

`test-end` takes a single argument:
$1 - the name of your test suite

the `test-end` call should only be made once all tests fns have finished. 
this will echo a report to stdout that gives some detail about the suite run
and if there were any failures, gives a breakdown of the test function that
failed, and what parameters were used when the failure happened.

### Get
```bash
wget -N https://raw.githubusercontent.com/DavidBindloss/test.sh/master/test.sh
# or
curl -O https://raw.githubusercontent.com/DavidBindloss/test.sh/master/test.sh
```

### Use
```bash
#!/usr/bin/env bash

. test.sh

my-test-fn() {
  expect echo "0" 0
  expect echo "1" 1
}

my-test-fn
# more fns...

test-end my-test-suite

```


[![Build Status](https://drone.akito.ooo:52222/api/badges/Akito/akito-libbash/status.svg)](https://drone.akito.ooo:52222/Akito/akito-libbash)

# Akito's BASH library

Some useful functions I commonly use in scripts.

To use, add the following to the top of your script:
```bash
shopt -s expand_aliases
source bishy.bash
```
Library has to be in the same directory as your script.
The `shopt` line is only necessary if you need to use aliases defined in the above script.

Commonly used functions between e.g. OS setups:
```bash
source setup.bash
```

## Examples

#### get_longOpt
Given the following script `glo_example.sh`:
```bash
#!/bin/bash

source bishy.bash

declare name
declare -i age
declare isFine=false

echo
echo
echo "Values of our variables before parsing options:"
echo "name = $name"
echo "age = $age"
echo "isFine = $isFine"

get_longOpt $@

echo
echo "Values of our variables after parsing options:"
echo "name = $name"
echo "age = $age"
echo "isFine = $isFine"
```
Executing the script results in:
```bash
bash glo_example.sh --name Augustinus --isFine --age 57


Values of our variables before parsing options:
name = 
age = 
isFine = false

Values of our variables after parsing options:
name = Augustinus
age = 57
isFine = true
```
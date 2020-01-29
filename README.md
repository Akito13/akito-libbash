[![Build Status](https://drone.akito.ooo:52222/api/badges/Akito/akito-libbash/status.svg)](https://drone.akito.ooo:52222/Akito/akito-libbash)

## Akito's BASH library

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
# Hamnix

Hamnix is a collection of software for amateur radio users which uses Nix to
make easy what is often considered to be difficult to run software.

## Examples

### RufzXP

![RufzXP](/../images/rufzxp.webp)

[RufzXP](https://www.rufzxp.net/) is considered to be difficult to run. If you
run RufzXP from this repository like this:

`nix run github:matthewcroughan/hamnix#rufzxp`

It will:

1. Install RufzXP silently into `~/.rufzxp`

   ```
   user: matthew ~ 
   ❯ ls .rufzxp/
   dosdevices  drive_c  state  system.reg  userdef.reg  user.reg  winetricks.log
   ```

2. Put all state associated with the program into `~/.rufzxp/state`

   ```
   user: matthew ~ 
   ❯ ls .rufzxp/state/
   Attempts  Backgrounds  Config.rfz  Help  Languages  PrsData  ScoreBoard.scb
   ```
3. Run `rufzxp`

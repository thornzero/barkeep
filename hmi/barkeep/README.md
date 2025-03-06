# barkeep

A new Flutter project.

## Flutter docs

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [online documentation](https://docs.flutter.dev/)

## Industrial Automation Card

```bash
        Usage:          megaind -v
        Usage:          megaind -h    Display command options list
        Usage:          megaind -h <param>   Display help for <param> command option
        Usage:          megaind -warranty
        Usage:          megaind -list
        Usage:          megaind <stack> board
        Usage:          megaind <stack> vbrd
        Usage:          megaind <id> optord <channel>
        Usage:          megaind <id> optord
        Usage:          megaind <id> countrd <channel>
        Usage:          megaind <id> ifrd <channel>
        Usage:          megaind <id> countrst <channel>
        Usage:          megaind <id> edgerd <channel> 
        Usage:          megaind <id> edgewr <channel> <val>
        Usage:          megaind <id> uoutrd <channel>
        Usage:          megaind <id> uoutwr <channel> <value(V)>
        Usage:          megaind <id> ioutrd <channel>
        Usage:          megaind <id> ioutwr <channel> <value(mA)>
        Usage:          megaind <id> odrd <channel>
        Usage:          megaind <id> odfrd <channel>
        Usage:          megaind <id> odwr <channel> <value>
        Usage:          megaind <id> odfwr <channel[1..3]> <value[10..6400]>
        Usage:          megaind <id> dodrd <channel>
        Usage:          megaind <id> dodrd
        Usage:          megaind <id> dodwr <channel> <val>
        Usage:          megaind <id> ledrd <channel>
        Usage:          megaind <id> ledrd
        Usage:          megaind <id> ledwr <channel> <state>
        Usage:          megaind <id> uinrd <channel>
        Usage:          megaind <id> pmuinrd <channel>
        Usage:          megaind <id> iinrd <channel>
        Usage:          megaind <id> uincal <channel> <value(V)>
        Usage:          megaind <id> iincal <channel> <value(mA)>
        Usage:          megaind <id> uincalrst <channel>
        Usage:          megaind <id> iincalrst <channel>
        Usage:          megaind <id> uoutcal <channel> <value(V)>
        Usage:          megaind <id> ioutcal <channel> <value(mA)>
        Usage:          megaind <id> uoutcalrst <channel>
        Usage:          megaind <id> ioutcalrst <channel>
        Usage:          megaind <id> wdtr
        Usage:          megaind <id> wdtpwr <val> 
        Usage:          megaind <id> wdtprd 
        Usage:          megaind <id> wdtipwr <val> 
        Usage:          megaind <id> wdtiprd 
        Usage:          megaind <id> wdtopwr <val> 
        Usage:          megaind <id> wdtoprd 
        Usage:          megaind <id> wdtrcrd 
        Usage:          megaind <id> wdtrcclr
        Usage:          megaind <id> rs485rd
        Usage:          megaind <id> rs485wr <mode> <baudrate> <stopBits> <parity> <slaveAddr>
        Usage:          megaind <id> rtcrd 
        Usage:          megaind <id> rtcwr <mm> <dd> <yy> <hh> <mm> <ss> 
        Usage:          megaind <stack> owbtrd <sensor (1..16)>
        Usage:          megaind <stack> owbidrd <sensor (1..16)>
        Usage:          megaind <stack> owbcntrd
        Usage:          megaind <stack> owbscan
Where: <id> = Board level id = 0..7
Type megaind -h <command> for more help
```

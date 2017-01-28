#!/bin/bash

# clear

function color (){
  echo "\e[$1m$2\e[0m"
}

function extend (){
  local str="$1"
  let spaces=60-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  echo "$str"
}

function extendIP (){
  local str="$1"
  let spaces=15-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  echo "$str"
}

function extendIP_rjust (){
  local str=""
  let spaces=15-${#1}
  while [ $spaces -gt 0 ]; do
    str="$str "
    let spaces=spaces-1
  done
  str="$str$1"
  echo "$str"
}

function center (){
  local str="$1"
  let spacesLeft=(79-${#1})/2
  let spacesRight=79-spacesLeft-${#1}
  while [ $spacesLeft -gt 0 ]; do
    str=" $str"
    let spacesLeft=spacesLeft-1
  done

  while [ $spacesRight -gt 0 ]; do
    str="$str "
    let spacesRight=spacesRight-1
  done

  echo "$str"
}

function sec2time (){
  local input=$1

  if [ $input -lt 60 ]; then
    echo "$input seconds"
  else
    ((days=input/86400))
    ((input=input%86400))
    ((hours=input/3600))
    ((input=input%3600))
    ((mins=input/60))

    local daysPlural="s"
    local hoursPlural="s"
    local minsPlural="s"

    if [ $days -eq 1 ]; then
      daysPlural=""
    fi

    if [ $hours -eq 1 ]; then
      hoursPlural=""
    fi

    if [ $mins -eq 1 ]; then
      minsPlural=""
    fi

    echo "$days day$daysPlural, $hours hour$hoursPlural, $mins minute$minsPlural"
  fi
}

BRed='1;31'
BGreen='1;32'
Yellow='0;33'
BMagenta='1;35'
BCyan='1;36'
Cyan='0;36'
BWhite='1;37'

borderColor=$BMagenta
headerLeafColor=$BGreen
headerRaspberryColor=$BRed
greetingsColor1=$BCyan
greetingsColor2=$Cyan
statsLabelColor=$Yellow
IPColor=$BWhite

# No border on colored background
#borderLine="                                                                                "
borderLine=" # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
borderTopLine=$(color $borderColor "#$borderLine")
borderBottomLine=$(color $borderColor "#$borderLine")
borderBar=$(color $borderColor "#")
# With border
#borderLine=$"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
#borderTopLine=$(color $borderColor "┏$borderLine┓")
#borderBottomLine=$(color $borderColor "┗$borderLine┛")
#borderBar=$(color $borderColor "┃")
borderEmptyLine="$borderBar                                                                               $borderBar"

localIP=$(color $IPColor "$(extendIP "$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')")")
wanIP=$(color $IPColor "$(extendIP_rjust "$(wget -q -O - http://ipv4.icanhazip.com/ | tail)")")

# Header
header="$borderTopLine\n$borderEmptyLine\n"
header="$header$borderBar$(color $headerLeafColor "          .~~.   .~~.                                                          ")$borderBar\n"
header="$header$borderBar$(color $headerLeafColor "         '. \ ' ' / .'                                                         ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          .~ .~~~..~.                      _                          _        ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         : .~.'~'.~. :     ___ ___ ___ ___| |_ ___ ___ ___ _ _    ___|_|       ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ (   ) (   ) ~   |  _| .'|_ -| . | . | -_|  _|  _| | |  | . | |       ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "       ( : '~'.~.'~' : )  |_| |__,|___|  _|___|___|_| |_| |_  |  |  _|_|       ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "        ~ .~ (   ) ~. ~               |_|                 |___|  |_|           ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "         (  : '~' :  )                                                         ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "          '~ .~~~. ~'     $localIP                $wanIP       ")$borderBar\n"
header="$header$borderBar$(color $headerRaspberryColor "              '~'                                                              ")$borderBar"

me=$(whoami)

# Greetings
greetings="$borderBar$(color $greetingsColor1 "$(center "Welcome back, $me!")")$borderBar\n"
greetings="$greetings$borderBar$(color $greetingsColor2 "$(center "$(date +"%A, %d %B %Y, %T")")")$borderBar"

# System information

lastLoginIp="$(lastlog -u $me | sed -ne '2{p;q}' | cut -c 27-62)"

if [[ $lastLoginIp != "" ]]; then
  login=$lastLoginIp
else
  # Not enough logins
  login="None"
fi

label1="$(extend "$login")"
label1="$borderBar   $(color $statsLabelColor "Last Login....:") $label1$borderBar"

uptime="$(sec2time $(cut -d "." -f 1 /proc/uptime))"
uptime="$uptime ($(date -d "@"$(grep btime /proc/stat | cut -d " " -f 2) +"%d-%m-%Y %H:%M:%S"))"

label2="$(extend "$uptime")"
label2="$borderBar   $(color $statsLabelColor "Uptime........:") $label2$borderBar"

label3="$(extend "$(free -m | awk 'NR==2 { printf "Total: %sMB, Used: %sMB, Free: %sMB",$2,$3,$4; }')")"
label3="$borderBar   $(color $statsLabelColor "Memory........:") $label3$borderBar"

label4="$(extend "$(df -h ~ | awk 'NR==2 { printf "Total: %sB, Used: %sB, Free: %sB",$2,$3,$4; }')")"
label4="$borderBar   $(color $statsLabelColor "Home space....:") $label4$borderBar"

proCount=$(ps ax | wc -l | tr -d " ")
label5="$(extend "Total $proCount running")"
label5="$borderBar   $(color $statsLabelColor "Procesess.....:") $label5$borderBar"

cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))
TODAY=$(date)

# gpuTemp0=$(/opt/vc/bin/vcgencmd measure_temp)
# gpuTemp0=${gpuTemp0//\'/°}
# gpuTemp0=${gpuTemp0//temp=/}
cpuTemp=$cpuTemp1"."$cpuTempM"ºC"

label6="$(extend "$cpuTemp")"
label6="$borderBar   $(color $statsLabelColor "CPU Temp......:") $label6$borderBar"

# label7="$(extend "$gpuTemp0")"
# label7="$borderBar  $(color $statsLabelColor "GPU Temp......:") $label7$borderBar"

# labeleth0="$(extend "$(ifconfig eth0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')")"
# labeleth0="$borderBar  $(color $statsLabelColor "IP of eth0....:") $labeleth0$borderBar"

# labelwlan0="$(extend "$(ifconfig wlan0 | grep "inet ad" | cut -f2 -d: | awk '{print $1}')")"
# labelwlan0="$borderBar  $(color $statsLabelColor "IP of wlan0...:") $labelwlan0$borderBar"

# labelIPv4="$(extend "$(wget -q -O - http://ipv4.icanhazip.com/ | tail)")"
# labelIPv4="$borderBar  $(color $statsLabelColor "IPv4 of WAN...:") $labelIPv4$borderBar"

# labelIPv6="$(extend "$(wget -q -O - http://ipv6.icanhazip.com/ | tail)")"
# labelIPv6="$borderBar  $(color $statsLabelColor "IPv6 of WAN.....:") $labelIPv6$borderBar"

stats="$label1\n$label2\n$label3\n$label4\n$label5\n$label6"

# Print motd
echo -e "$header\n$border$greetings\n$borderEmptyLine\n$stats\n$borderEmptyLine\n$borderBottomLine"

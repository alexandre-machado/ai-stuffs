# Common Examples (.rsc)

Refer to the official manual for detailed syntax:
https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting

## IP Address – idempotent add
```
# adds address to /interface only if it does not exist
:local iface "bridge";
:local addr "192.168.88.1/24";
:if ([:len [/ip address find where interface=$iface and address=$addr]] = 0) do={
    /ip address add interface=$iface address=$addr comment="defconf"
}
```

## Firewall Filter – single rule
```
# accepts DNS on forward chain if it does not exist
:local cm "allow-dns";
:if ([:len [/ip firewall filter find where chain=forward and protocol=udp and dst-port=53 and action=accept and comment=$cm]] = 0) do={
    /ip firewall filter add chain=forward protocol=udp dst-port=53 action=accept comment=$cm
}
```

## DHCP Client – add via lenient scheduler
```
/system script add name=add-dhcp owner=admin policy=read,write source="/ip dhcp-client add interface=ether2; :put \"Added DHCP\"";
/system scheduler add name=run-add-dhcp interval=10s on-event="/system script run add-dhcp" policy=read,write
```

## Single script per instance
```
:if ([/system script job print count-only as-value where script=[:jobname]] > 1) do={
  :error "script instance already running"
}
```

## Import with dry-run and onerror (≥ 7.16.x)
```
# locate errors without applying
import test.rsc verbose=yes dry-run

# error capture
onerror e in={ import test.rsc } do={ :put "Failure - $e" }
```

## Remove by find (avoid fixed IDs)
```
# remove rule by comment
/ ip firewall filter remove [ find where comment="old-rule" ]
```

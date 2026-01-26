# Exemplos Comuns (.rsc)

Consulte o manual oficial para sintaxe detalhada:
https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting

## IP Address – adicionar idempotente
```
# adiciona endereço /interface somente se não existir
:local iface "bridge";
:local addr "192.168.88.1/24";
:if ([:len [/ip address find where interface=$iface and address=$addr]] = 0) do={
    /ip address add interface=$iface address=$addr comment="defconf"
}
```

## Firewall Filter – regra única
```
# aceita DNS na chain forward se não existir
:local cm "allow-dns";
:if ([:len [/ip firewall filter find where chain=forward and protocol=udp and dst-port=53 and action=accept and comment=$cm]] = 0) do={
    /ip firewall filter add chain=forward protocol=udp dst-port=53 action=accept comment=$cm
}
```

## DHCP Client – adicionar via scheduler permissivo
```
/system script add name=add-dhcp owner=admin policy=read,write source="/ip dhcp-client add interface=ether2; :put \"Added DHCP\"";
/system scheduler add name=run-add-dhcp interval=10s on-event="/system script run add-dhcp" policy=read,write
```

## Script único por instância
```
:if ([/system script job print count-only as-value where script=[:jobname]] > 1) do={
  :error "script instance already running"
}
```

## Import com dry-run e onerror (≥ 7.16.x)
```
# localizar erros sem aplicar
import test.rsc verbose=yes dry-run

# captura de erro
onerror e in={ import test.rsc } do={ :put "Failure - $e" }
```

## Remover por find (evitar IDs fixos)
```
# remover regra por comentário
/ ip firewall filter remove [ find where comment="old-rule" ]
```

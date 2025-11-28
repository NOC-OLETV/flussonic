#!/bin/bash

#SALVANDO TODAS AS OIDS
cd /usr/local/src
snmpwalk -c admin -v 2c -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB 127.0.0.1:4000 . > gera_oid.txt

ARQOIDS="/usr/local/src/gera_oid.txt"

#COLETANDO LINHA DO CANAL PARA EXECUTAR OS STATUS
COLETA1=$(grep "live/MONITOR_TVClubeHD" $ARQOIDS | cut -c21-22)
COLETA2=$(grep "live/MONITOR_BANDPIAUI" $ARQOIDS | cut -c21-22)
COLETA3=$(grep "live/MONITOR_TVAntena10HD" $ARQOIDS | cut -c21-22)
COLETA4=$(grep "live/MONITOR_CIDADEVERDEHD" $ARQOIDS | cut -c21-22)

#EXECUTANDO SNMPTRANSLATE PARA GERAR A OID
GLOBO=$(snmptranslate -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -On STREAMER-MIB::sStatus.$COLETA1)
BAND=$(snmptranslate -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -On STREAMER-MIB::sStatus.$COLETA2)
RECORD=$(snmptranslate -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -On STREAMER-MIB::sStatus.$COLETA3)
SBT=$(snmptranslate -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -On STREAMER-MIB::sStatus.$COLETA4)

#CONVERSANDO OID EM "ACTIVE" (STATUS DO CANAL) COM SNMPGET
GETGLOBO=$(snmpget -c admin -v 2c -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -Oqv 127.0.0.1:4000 $GLOBO)
GETBAND=$(snmpget -c admin -v 2c -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -Oqv 127.0.0.1:4000 $BAND)
GETRECORD=$(snmpget -c admin -v 2c -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -Oqv 127.0.0.1:4000 $RECORD)
GETSBT=$(snmpget -c admin -v 2c -M +/opt/flussonic/lib/mibs -m +STREAMER-MIB -Oqv 127.0.0.1:4000 $SBT)

#CONVERTENDO STRING ("active") EM NÚMEROS INTEIROS PARA O ZABBIX AGENT
if [ $GETGLOBO = "active" ]
then
	echo 1 > $ARQOIDS
else
	echo 2 > $ARQOIDS
fi

if [ $GETBAND = "active" ]
then
	echo 1 >> $ARQOIDS
else
	echo 2 >> $ARQOIDS
fi

if [ $GETRECORD =  "active" ]
then
        echo 1 >> $ARQOIDS
else
	echo 2 >> $ARQOIDS
fi

if [ $GETSBT = "active" ]
then
	echo 1 >> $ARQOIDS
else
	echo 2 >> $ARQOIDS
fi

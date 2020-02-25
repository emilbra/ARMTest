#!/bin/bash

#Oppdaterer systemet, installerer deretter tjenesten OpenVPN
sudo apt update
sudo apt install openvpn

#Laster ned EasyRSA, som brukes til å generere nøkkelpar.
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz

#Pakker ut EasyRSA på mappen til brukeren. Kopierer eksempelvila vars.example
cd ~
tar xvf EasyRSA-3.0.4.tgz
cd ~/EasyRSA-3.0.4/

#Laster ned "vår" egendefinerte vars fil fra git.
wget -P ~/ https://raw.githubusercontent.com/emilbra/ARMTest/master/vars

#Setter opp Public Key Infrastrutcture gjennom sctiptet ./easyrsa
./easyrsa init-pki

#Bygger Certificate Authority, som egentlig burde være på en egen host, men vi setter det opp på denne VM-en for å få fortgang i det
./easyrsa build-ca nopass

#Requester et server sertifikat, lager en privat nøkkel og en $serverName.req
./easyrsa gen-req $serverName nopass
cp ~/EasyRSA-3.0.4/pki/private/${serverName}.key /etc/openvpn/

#Signerer requesten som type server, og kopierer de over til /etc/openvpn
./easyrsa sign-req server $serverName
cp pki/issued/${serverName}.crt /etc/openvpn
cp pki/ca.crt /etc/openvpn

#Generereer Diffe-Hellman nøkkel
./easyrsa gen-dh

#Generer en HMAC signatur
openvpn --genkey --secret ta.key
cp ~/EasyRSA-3.0.4/ta.key /etc/openvpn/
cp ~/EasyRSA-3.0.4/pki/dh.pem /etc/openvpn/

#gjør klart til å generere Client Certifikater og nøkkelpar
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs

#laster ned og legger inn server.conf, for deretter å endre filnavn som refereres til
wget -P ~/etc/openvpn/server.conf https://raw.githubusercontent.com/emilbra/ARMTest/master/server.conf
sed "s/cert server.crt/cert \\${serverName}.crt" ~/etc/openvpn/server.conf
sed "s/key server.key/key \\${serverName}.key" ~/etc/openvpn/server.conf

#endrer nettverkskonfigurasjon på tjeneren, setter det slik at iptables ikke endres etter omstart.
sed "s/#net.ipv4_ip_forward=1/net.ipv4_ip_forward=1" ~/etc/sysctl.conf
apt-get install iptables-persistent
service iptables-persistent start

#I tillegg endres Brannmursregler
wget -P ~/etc/ufw/before.rules https://raw.githubusercontent.com/emilbra/ARMTest/master/before.rules
sed "s/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"" 
ufw allow 1194/udp
ufw allow OpenSSH
ufw disable
ufw enable

echo "kjør client_make.sh for å generer .ovpn fil for bruker. Dette må deretter føres over til brukeren vha WinSCP eller lignende."
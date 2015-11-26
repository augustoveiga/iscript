#!/bin/bash
#Version 5.0 - November 2015
#Written by Augusto Veiga

bold=$(tput bold)

function help() {

	##############################################
	# Banner do script e Funcao HELP do script   #
	##############################################
	echo ""
	echo "  @@@@@@   @@@@@@     @@@@@@   @@@@@@@   @@@@@@  @@@@@@@   @@@@@@@@"
    	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@    @@     @@"
    	echo "    @@    @@         @@        @@    @@    @@    @@    @@     @@"
    	echo "    @@     @@@@@@    @@        @@@@@@@     @@    @@@@@@@      @@"
    	echo "    @@          @@   @@        @@    @@    @@    @@           @@"
    	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@           @@"
    	echo "  @@@@@@   @@@@@@     @@@@@@   @@    @@  @@@@@@  @@           @@"
	echo ""
	echo "iscript - Simple script to run NMAP + NIKTO + SSLSCAN TEST."
	echo ""
	echo "-i to input a IP or many IPs as a target - eg: 192.168.1.1 or 192.168.1.1/24 or 192.168.1.1-100"
	echo "-l to input a file with target(s)"
	echo "--help to show help menu"
	echo ""

}

if [ $1 ] #Condicao para utilizar os argumentos -i e -l
then
	case "$1" in 
	-i) # Argumento para aceitar o input de um IP, Range ou Barramento

	##############################################
	# Banner do script                           #
	##############################################
	echo ""
	echo "  @@@@@@   @@@@@@     @@@@@@   @@@@@@@   @@@@@@  @@@@@@@   @@@@@@@@"
	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@    @@     @@"
	echo "    @@    @@         @@        @@    @@    @@    @@    @@     @@"
	echo "    @@     @@@@@@    @@        @@@@@@@     @@    @@@@@@@      @@"
	echo "    @@          @@   @@        @@    @@    @@    @@           @@"
	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@           @@"
	echo "  @@@@@@   @@@@@@     @@@@@@   @@    @@  @@@@@@  @@           @@"

	################################################
	# Cria a estrutura de diretorios e copia o     #
	# nmap.xsl para a pasta do NMAP                #
	################################################
	mkdir /root/Desktop/iscriptResult
	mkdir /root/Desktop/iscriptResult/NMAP
	mkdir /root/Desktop/iscriptResult/SSLSCAN
	mkdir /root/Desktop/iscriptResult/NIKTO
	mkdir /root/Desktop/iscriptResult/LOG
	cp /usr/share/nmap/nmap.xsl /root/Desktop/iscriptResult/NMAP

	echo ""

	echo -e "\e[1;31m${bold}UPLIST - NMAP\e[0m"
	#################################################
	# Port scan para identificar os hosts que estao #
	# UP.                                           #    
	#################################################
	nmap -sP -T4 $2 -oG /root/Desktop/iscriptResult/NMAP/pingscan

	#################################################
	# Grep para criar um arquivo com os hosts UPs   #
	#################################################
	grep Up /root/Desktop/iscriptResult/NMAP/pingscan | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/uplist | tee /root/Desktop/iscriptResult/LOG/pingscan.log

	echo ""

	echo -e "\e[1;31m${bold}NMAP SCAN - PORT SCANNER + BANNER\e[0m"
	#################################################
	# NMAP - Port Scanner                           #
	# 3 OUTPUTS + LOG                               #
	#################################################
	nmap -Pn -A -vv $2 --stylesheet nmap.xsl -oA /root/Desktop/iscriptResult/NMAP/nmap_result | tee /root/Desktop/iscriptResult/LOG/nmap_result.log

	################################################
	# Grep para criar os arquivos "port80' e       #
	# "port443" a partir do NMAP - Arquivos serao  #
	# utilizados ao decorrer do script             #
	################################################
	grep 80/open /root/Desktop/iscriptResult/NMAP/nmap_result.gnmap | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port80
	grep 443/open /root/Desktop/iscriptResult/NMAP/nmap_result.gnmap | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port443
	
	echo ""

	echo -e "\e[1;31m${bold}SSLSCAN\e[0m"
	################################################
	# Comando para executar o SSLCAN               #
	################################################
	sslscan --no-failed --show-certificate --xml=/root/Desktop/iscriptResult/SSLSCAN/$2 --targets=/root/Desktop/iscriptResult/NMAP/port443 | tee /root/Desktop/iscriptResult/LOG/SSLSCAN.log

	echo ""

	echo -e "\e[1;31m${bold}NIKTO SCAN\e[0m"
	################################################
	# NIKTO - Criamos os FORs para rodar o comando #
	# em todos os IPs que estao nos arquivos       #
	# "port80" e "port443"                         #
	################################################
	for ip in `cat /root/Desktop/iscriptResult/NMAP/port80`
		do 
			nikto -host $ip -port 80 -Format HTML -o /root/Desktop/iscriptResult/NIKTO/result_nikto.html | tee /root/Desktop/iscriptResult/LOG/nikto80.log
		done

	for ip in `cat /root/Desktop/iscriptResult/NMAP/port443`
		do 
			nikto -host $ip -port 443 -Format HTML -o /root/Desktop/iscriptResult/NIKTO/result_nikto.html | tee /root/Desktop/iscriptResult/LOG/nikto443.log
		done

	###############################################
	# Mover os arquivos da pasta NMAP para a      #
	# LOG                                         #
	###############################################
	mv /root/Desktop/iscriptResult/NMAP/uplist /root/Desktop/iscriptResult/LOG
	mv /root/Desktop/iscriptResult/NMAP/pingscan /root/Desktop/iscriptResult/LOG
	mv /root/Desktop/iscriptResult/NMAP/port80 /root/Desktop/iscriptResult/LOG
	mv /root/Desktop/iscriptResult/NMAP/port443 /root/Desktop/iscriptResult/LOG

	;;

	-l) #Argumento para aceitar como input um arquito
	if [[ -e $2 ]] #Condicao para tratar um arquivo como input
	then
		##############################################
		# Banner do script                           #
		##############################################
		echo ""
        	echo "  @@@@@@   @@@@@@     @@@@@@   @@@@@@@   @@@@@@  @@@@@@@   @@@@@@@@"
        	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@    @@     @@"
       		echo "    @@    @@         @@        @@    @@    @@    @@    @@     @@"
        	echo "    @@     @@@@@@    @@        @@@@@@@     @@    @@@@@@@      @@"
        	echo "    @@          @@   @@        @@    @@    @@    @@           @@"
        	echo "    @@    @@    @@   @@    @@  @@    @@    @@    @@           @@"
        	echo "  @@@@@@   @@@@@@     @@@@@@   @@    @@  @@@@@@  @@           @@"
		echo ""

		################################################
		# Cria a estrutura de diretorios e copia o     #
		# nmap.xsl para a pasta do NMAP                #
		################################################
		mkdir /root/Desktop/iscriptResult
        	mkdir /root/Desktop/iscriptResult/NMAP
        	mkdir /root/Desktop/iscriptResult/SSLSCAN
        	mkdir /root/Desktop/iscriptResult/NIKTO
        	mkdir /root/Desktop/iscriptResult/LOG
		cp /usr/share/nmap/nmap.xsl /root/Desktop/iscriptResult/NMAP

		echo ""

		echo -e "\e[1;31m${bold}UPLIST - NMAP\e[0m"
		#################################################
		# Port scan para identificar os hosts que estao #
		# UP.                                           #    
		#################################################
		nmap -sP -T4 -iL $2 -oG /root/Desktop/iscriptResult/NMAP/pingscan | tee /root/Desktop/iscriptResult/LOG/pingscan.log

		#################################################
		# Grep para criar um arquivo com os hosts UPs   #
		#################################################
		grep Up /root/Desktop/iscriptResult/NMAP/pingscan | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/uplist
		
		echo ""

		echo -ne "\n\e[1;31m${bold}NMAP SCAN - PORT SCANNER + BANNER\e[0m"
		#################################################
		# NMAP - Port Scanner                           #
		# 3 OUTPUTS + LOG                               #
		#################################################
		nmap -Pn -A -vv -iL /root/Desktop/iscriptResult/NMAP/uplist --stylesheet nmap.xsl -oA /root/Desktop/iscriptResult/NMAP/nmap_result | tee /root/Desktop/iscriptResult/LOG/nmap_result.log

		################################################
		# Grep para criar os arquivos "port80' e       #
		# "port443" a partir do NMAP - Arquivos serao  #
		# utilizados ao decorrer do script             #
		################################################
		grep 80/open /root/Desktop/iscriptResult/NMAP/nmap_result.gnmap | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port80
		grep 443/open /root/Desktop/iscriptResult/NMAP/nmap_result.gnmap | awk '{print $2}' > /root/Desktop/iscriptResult/NMAP/port443

		echo ""

		echo -ne "\n\e[1;31m${bold}SSLSCAN\e[0m\n"
		################################################
		# Comando para executar o SSLCAN               #
		################################################
		sslscan --no-failed --show-certificate --xml=/root/Desktop/iscriptResult/SSLSCAN/$2 --targets=/root/Desktop/iscriptResult/NMAP/port443 | tee /root/Desktop/iscriptResult/LOG/SSLSCAN.log

		echo ""

		echo -ne "\n\e[1;31m${bold}NIKTO SCAN\e[0m\n"
		################################################
		# NIKTO - Criamos os FORs para rodar o comando #
		# em todos os IPs que estao nos arquivos       #
		# "port80" e "port443"                         #
		################################################
		for ip in `cat /root/Desktop/iscriptResult/NMAP/port80`
			do 
				nikto -host $ip -port 80 -Format HTML -o /root/Desktop/iscriptResult/NIKTO/result_nikto.html | tee /root/Desktop/iscriptResult/LOG/nikto80.log
			done
		for ip in `cat /root/Desktop/iscriptResult/NMAP/port443`
			do 
				nikto -host $ip -port 443 -Format HTML -o /root/Desktop/iscriptResult/NIKTO/result_nikto.html | tee /root/Desktop/iscriptResult/LOG/nikto443.log
			done

		###############################################
		# Mover os arquivos da pasta NMAP para a      #
		# LOG                                         #
		###############################################
		mv /root/Desktop/iscriptResult/NMAP/uplist /root/Desktop/iscriptResult/LOG
		mv /root/Desktop/iscriptResult/NMAP/pingscan /root/Desktop/iscriptResult/LOG
		mv /root/Desktop/iscriptResult/NMAP/port80 /root/Desktop/iscriptResult/LOG
		mv /root/Desktop/iscriptResult/NMAP/port443 /root/Desktop/iscriptResult/LOG

	else

		help;

	fi

	;;

	--help)

		help;

	;;

	esac

else

	help;

fi

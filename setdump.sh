#!/bin/sh
#
#
# 
#This script is modified at @2024/02/06
#Support FreeBSD 12.3
#               by ZyaoZeng @2022/08/02
#


PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin
inilist=/var/tmp/ini.list
DIR=/home/www/htdocs

if [ -z "$1"  ];then
	echo "只轉設定，資料庫全轉請另外dump tbl"
        echo "./setdump ini ;backup ini"
        echo "./setdump sql ;dump sql data"
        echo "./setdump reg [-d|-c]"
        echo "               -d Backup licence key to req.txt"
        echo "               -c Delete licence key from sql"
        exit 0
elif [ $1 == "ini" ];then
	if [ -f $inilist ]; then
		rm -f $inilist
		touch $inilist
	fi
	echo "Dump ini ... "
	if [ -d /home/www/htdocs/snspam ];then
		PD="snspam"
		find $DIR/$PD -name "*.ini" |egrep -v 'snspam/virus|INI|logo.ini|filter_default.ini|ldap2/conf.ini|ldap2/defaults/conf.ini|pw.ini' >> $inilist
	        find $DIR/$PD/spam_group/tmp/* >> $inilist
		find $DIR/$PD/spam_threat/*.txt >> $inilist
	        find $DIR/$PD/spam_sys/tmp/* >> $inilist
	        find $DIR/$PD/spam_static2/emlfile/* >> $inilist
	        find $DIR/$PD/spam_filter/msgfile/Bccmail_* >> $inilist
	        find $DIR/$PD/spam_filter/msgfile/Autoreply_* >> $inilist
                echo "tar ini file..."
                tar zcf ini.tgz -T $inilist > /dev/null 2>&1
        elif [ -d /home/www/htdocs/snmsqr ];then
                PD="snmsqr"
                cat $DIR/$PD/shell/bkfiles.txt |egrep -v 'pw.ini|Version|debug|dspam.txt'  >>$inilist
 	        find $DIR/$PD/ -name "qosControlDoSFilter.ini" >> $inilist
		find $DIR/$PD/ -name "group_boss_user.ini" >> $inilist
                find $DIR/$PD/ -name "remind_audit_auditNotice.txt" >> $inilist
                find $DIR/$PD/ -name "remind_backupOK.txt" >> $inilist
		more /home/www/htdocs/snmsqr/shell/bksys.txt | grep opendkim >> $inilist
                echo "tar ini file..."
                tar zcf ini.tgz -T $inilist > /dev/null 2>&1

        fi
elif [ $1 == "sql" ];then
	if [ -d /home/www/htdocs/snspam ];then
		echo "SPAM SQR"
		echo "Dump MySQL..."
		PD="snspam"
		PW=`grep snee ~www/htdocs/snspam/pw.ini | awk -F '"' '{print $2}'`
		SPAMtable=`mysql -N -usnee -p$PW $PD -e "show tables;" | egrep -v 'Tables_in_snspam|maillog|tbl|mailstat|mbdlog|rpt_amd_|rpt_average|rpt_badhost|rpt_badhost_hitrate|rpt_coDefenseStat|rpt_dirinfo|rpt_grpstat|rpt_secuinfo|rpt_tmprule|rpt_InvalidAccount|rpt_ValidAccount|filterData|sys_|L2tables|msg_ftb20|lurk_user'`
		mysqldump -t -c -usnee -p$PW $PD $SPAMtable > db.txt
		echo $SPAMtable | tr ' ' '\n' > dumptable.txt
	elif [ -d /home/www/htdocs/snmsqr ];then
		echo "MSAE"
		echo "Dump MySQL...."
		PD="snmsqr"
                PW=`grep snee ~www/htdocs/snmsqr/pw.ini | awk -F '"' '{print $2}'`
                MSAEtable=`mysql -N -usnee -p$PW $PD -e 'show tables;' | egrep -v 'Tables_in_snmsqr|sys_tbl|msg_tbl|msg_maillog|msg_snSearch|msg_snSearch_index|msg_snSearch_|msg_tbl20|lurk_user|sys_tbl20|mymail_mbrstat|msg_log|msg_ftb20'`               mysqldump -t -c -usnee -p$PW $PD $MSAEtable > db.txt
		echo $MSAEtable | tr ' ' '\n' > dumptable.txt
	fi
elif [ $1 == "reg" ];then
	if [ -z $2 ];then
		echo "./setdump reg [-d|-c]"
        	echo "               -d Backup licence key to req.txt"
	        echo "               -c Delete licence key from sql"
	elif [ $2 == "-d" ];then
		echo "dump licence key to reg.txt"
		if [ -d /home/www/htdocs/snspam ];then
                	PD="snspam"
	                PW=`grep snee ~www/htdocs/snspam/pw.ini | awk -F '"' '{print $2}'`
	           	mysqldump -t -c -usnee -p$PW snspam variable -w "varname like '%regfun%' or varname like 'mac%';" > reg.txt
		elif [ -d /home/www/htdocs/snmsqr ];then
			PD="snmsqr"
	                PW=`grep snee ~www/htdocs/snmsqr/pw.ini | awk -F '"' '{print $2}'`
			mysqldump -t -c -usnee -p$PW snmsql sys_variable -w "varname like '%regfun%' or varname like 'mac%';"
		fi
	elif [ $2 == "-c" ];then\
		echo "delete licence from sql"
		if [ -d /home/www/htdocs/snspam ];then
                        PD="snspam"
                        PW=`grep snee ~www/htdocs/snspam/pw.ini | awk -F '"' '{print $2}'`
                        mysql  -usnee -p$PW snspam -e "delete from variable where varname like '%regfun%' or varname like 'mac%';" 
		elif [ -d /home/www/htdocs/snmsqr ];then
			PD="snmsqr"
                        PW=`grep snee ~www/htdocs/snmsqr/pw.ini | awk -F '"' '{print $2}'`
			mysql  -usnee -p$PW snmsqr -e "delete from sys_variable where varname like '%regfun%' or varname like 'mac%';"
		fi
	else
		echo "./setdump reg [-d|-c]"
                echo "               -d Backup licence key to req.txt"
                echo "               -c Delete licence key from sql"
	fi
else
        echo "./setdump ini ;backup ini"
	echo "./setdump sql ;dump sql data"
	echo "./setdump reg [-d|-c]"
	echo "               -d Backup licence key to req.txt"
	echo "               -c Delete licence key from sql"
fi

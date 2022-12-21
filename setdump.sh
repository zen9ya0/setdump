#!/bin/sh
#
#
# 
# write by ZyaoZeng @2022/08/02
# modified for support FreeBSD 12.3 @2022/08/25
#
#
PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin
inilist=/var/tmp/ini.list
DIR=/home/www/htdocs
if [ -z "$1"  ];then
	echo "只轉設定，資料庫全轉請另外dump tbl"
        echo "ini ;backup ini."
	echo "sql ;dump MySQL."
	echo "#sh setdump.sh ini or #sh setdump.sh sql"
        exit 0
elif [ $1 == "ini" ];then
	if [ -f $inilist ]; then
		rm -f $inilist
		touch $inilist
	fi
	echo "Dump ini ... "
	if [ -d /home/www/htdocs/snspam ];then
		PD="snspam"
		find $DIR/$PD -name "*.ini" |grep -v snspam/virus |grep -v INI|grep -v logo.ini|grep -v filter_default.ini|grep -v ldap2/conf.ini|grep -v ldap2/defaults/conf.ini|grep -v pw.ini >> $inilist
	        find $DIR/$PD/spam_group/tmp/* >> $inilist
	        find $DIR/$PD/spam_sys/tmp/* >> $inilist
	        find $DIR/$PD/spam_static2/emlfile/* >> $inilist
	        find $DIR/$PD/spam_filter/msgfile/Bccmail_* >> $inilist
	        find $DIR/$PD/spam_filter/msgfile/Autoreply_* >> $inilist
                echo "tar ini file..."
                tar zcf ini.tgz -T $inilist
        elif [ -d /home/www/htdocs/snmsqr ];then
                PD="snmsqr"
                cat $DIR/$PD/shell/bkfiles.txt |grep -v pw.ini|grep -v Version|grep -v debug|grep -v dspam.txt  >>$inilist
 	        find $DIR/$PD/ -name "qosControlDoSFilter.ini" >> $inilist
                find $DIR/$PD/ -name "remind_audit_auditNotice.txt" >> $inilist
                find $DIR/$PD/ -name "remind_backupOK.txt" >> $inilist
                find $DIR/$PD/ -name "group_boss_user.ini" >> $inilist
		more /home/www/htdocs/snmsqr/shell/bksys.txt | grep opendkim >> $inilist
                echo "tar ini file..."
                tar zcf ini.tgz -T $inilist

        fi
elif [ $1 == "sql" ];then
	if [ -d /home/www/htdocs/snspam ];then
		echo "SPAM SQR"
		echo "Dump MySQL..."
		PD="snspam"
		PW=`grep snee ~www/htdocs/snspam/pw.ini | awk -F '"' '{print $2}'`
#		table=`mysql -N -usnee -p$PW $PD -e "show tables;" | grep -v sys_|grep -v rpt_|grep -v maillog|grep -v tbl`
		table=`mysql -N -usnee -p$PW $PD -e "show tables;"|egrep -v 'Tables_in_snspam|maillog|tbl|mailstat|mbdlog|rpt_amd_|rpt_average|rpt_badhost|rpt_badhost_hitrate|rpt_coDefenseStat|rpt_dirinfo|rpt_grpstat|rpt_secuinfo|rpt_tmprule|rpt_InvalidAccount|rpt_ValidAccount|filterData|sys_|L2tables'`
		mysqldump -t -c -usnee -p$PW $PD $table > db.txt
		mysql -N -usnee -p$PW $PD -e "show tables;" | egrep -v 'Tables_in_snspam|maillog|tbl|mailstat|mbdlog|rpt_amd_|rpt_average|rpt_badhost|rpt_badhost_hitrate|rpt_coDefenseStat|rpt_dirinfo|rpt_grpstat|rpt_secuinfo|rpt_tmprule|rpt_InvalidAccount|rpt_ValidAccount|filterData|sys_|L2tables'  > tablelist.txt
	elif [ -d /home/www/htdocs/snmsqr ];then
		echo "MSAE"
		echo "Dump MySQL...."
		PD="snmsqr"
                PW=`grep snee ~www/htdocs/snmsqr/pw.ini | awk -F '"' '{print $2}'`
                #table=`more $DIR/$PD/snrpc/SETUP/frontend_sql.txt |awk '{print $6}'`
		table=`mysql -N -usnee -p$PW $PD -e 'show tables;' | grep -v sys_tbl | grep -v msg_tbl | grep -v msg_maillog | grep -v msg_snSearch | grep -v mymail_mbrstat | grep -v Tables_in_snmsqr | grep -v msg_log` 
                mysqldump -t -c -usnee -p$PW $PD $table > db.txt
		mysql -usnee -p$PW $PD -e 'show tables' | grep -v sys_tbl | grep -v msg_tbl | grep -v msg_maillog | grep -v msg_snSearch | grep -v mymail_mbrstat | grep -v Tables_in_snmsqr | grep -v msg_log > tablelist.txt 
	fi
else
        echo "ini ;backup ini."
	echo "sql ;dump MySQL"
	echo "#sh setdump.sh ini or #sh setdump.sh sql"
fi

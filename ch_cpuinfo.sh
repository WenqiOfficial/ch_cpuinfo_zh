#!/bin/sh
# Updated 2023.03.05 - By FOXBI
# htttps://github.com/foxbi/ch_cpuinfo
ver="4.2.1-r01"
# ==============================================================================
# Location Check
# ==============================================================================
if [ -f "LANG.txt" ]; then
	source ./LANG.txt
	if [ "$CUSTLANG" == "Y" ]; then
		LC_CHK="CUSTOMLANG"
	else
		LC_CHK=$(cat /etc/synoinfo.conf | grep timezone | awk -F= '{print $2}' | sed 's/"//g')
	fi
else
	LC_CHK=$(cat /etc/synoinfo.conf | grep timezone | awk -F= '{print $2}' | sed 's/"//g')
fi
# ==============================================================================
# Y or N Function
# ==============================================================================
READ_YN() { # $1:question $2:default
	read -n1 -p "$1" Y_N
	case "$Y_N" in
	y)
		Y_N="y"
		echo -e "\n"
		;;
	n)
		Y_N="n"
		echo -e "\n"
		;;
	q)
		echo -e "\n"
		exit 0
		;;
	*) echo -e "\n" ;;
	esac
}
# ==============================================================================
# Color Function
# ==============================================================================
cecho() {
	if [ -n "$3" ]; then
		case "$3" in
		black | bk) bgcolor="40" ;;
		red | r) bgcolor="41" ;;
		green | g) bgcolor="42" ;;
		yellow | y) bgcolor="43" ;;
		blue | b) bgcolor="44" ;;
		purple | p) bgcolor="45" ;;
		cyan | c) bgcolor="46" ;;
		gray | gr) bgcolor="47" ;;
		esac
	else
		bgcolor="0"
	fi
	code="\033["
	case "$1" in
	black | bk) color="${code}${bgcolor};30m" ;;
	red | r) color="${code}${bgcolor};31m" ;;
	green | g) color="${code}${bgcolor};32m" ;;
	yellow | y) color="${code}${bgcolor};33m" ;;
	blue | b) color="${code}${bgcolor};34m" ;;
	purple | p) color="${code}${bgcolor};35m" ;;
	cyan | c) color="${code}${bgcolor};36m" ;;
	gray | gr) color="${code}${bgcolor};37m" ;;
	esac

	text="$color$2${code}0m"
	echo -e "$text"
}
# ==============================================================================
# Process Function
# ==============================================================================
PREPARE_FN() {
	if [ -f "$WORK_DIR/admin_center.js" ] && [ -f "$MWORK_DIR/mobile.js" ]; then
		if [ "$direct_job" == "y" ]; then
			if [ "$LC_CHK" == "CUSTOMLANG" ]; then
				cecho r "$MSGECHO01\n"
			elif [ "$LC_CHK" == "Beijing" ]; then
				cecho r "注意！源文件将不会备份.\n"
			else
				cecho r "warning!! Work directly on the original file without backup.\n"
			fi
		else
			cd $WORK_DIR
			tar -cf $BKUP_DIR/$TIME/admin_center.tar admin_center.js*
			cd $MWORK_DIR
			tar -cf $BKUP_DIR/$TIME/mobile.tar mobile.js*
			if [ -f "$SWORK_DIR/System.js" ]; then
				cd $SWORK_DIR
				tar -cf $BKUP_DIR/$TIME/System.tar System.js*
				cp -Rf $SWORK_DIR/System.js $BKUP_DIR/
			fi
		fi
		if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -ge "2" ]; then
			mv $WORK_DIR/admin_center.js.gz $BKUP_DIR/
			mv $MWORK_DIR/mobile.js.gz $BKUP_DIR/
			if [ -f "$SWORK_DIR/System.js" ]; then
				cp -Rf $SWORK_DIR/System.js $BKUP_DIR/
			fi
			cd $BKUP_DIR/
			gzip -df $BKUP_DIR/admin_center.js.gz
			gzip -df $BKUP_DIR/mobile.js.gz
		else
			cp -Rf $WORK_DIR/admin_center.js $BKUP_DIR/
			cp -Rf $MWORK_DIR/mobile.js $BKUP_DIR/
			if [ -f "$SWORK_DIR/System.js" ]; then
				cp -Rf $SWORK_DIR/System.js $BKUP_DIR/
			fi
		fi
	else
		COMMENT08_FN
	fi
}

GATHER_FN() {
	cpu_vendor_chk=$(cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | grep AMD | wc -l)
	if [ "$cpu_vendor_chk" -gt "0" ]; then
		cpu_vendor="AMD"
	else
		cpu_vendor_chk=$(cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | grep Intel | wc -l)
		if [ "$cpu_vendor_chk" -gt "0" ]; then
			cpu_vendor="Intel"
		else
			cpu_vendor=$(cat /proc/cpuinfo | grep Hardware | sort -u | awk '{print $3}' | head -1)
			if [ -z "$cpu_vendor" ]; then
				cpu_vendor=$(cat /proc/cpuinfo grep model | grep name | sort -u | awk '{print $3}' | head -1)
			fi
		fi
	fi
	if [ "$cpu_vendor" == "AMD" ]; then
		pro_cnt=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | grep -wi "PRO" | wc -l)
		if [ "$pro_cnt" -gt 0 ]; then
			pro_chk="-wi PRO"
		else
			pro_chk="-v PRO"
		fi
		cpu_series=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk '{ for(i = NF; i > 1; i--) if ($i ~ /^[0-9]/) { for(j=i;j<=NF;j++)printf("%s ", $j);print("\n");break; }}' | sed "s/ *$//g")
		if [ -z "$cpu_series" ]; then
			cpu_series=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk '{ for(i = NF; i >= 1; i--) if ($i ~ ".*-.*") { print $i }}' | sed "s/ *$//g")
		fi
		cpu_family=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk -F"$cpu_series" '{print $1}' | sed "s/ *$//g")
	elif [ "$cpu_vendor" == "Intel" ]; then
		cpu_family=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk '{ for(i = 1; i < NF; i++) if ($i ~ /^Intel/) { for(j=i;j<=NF;j++)printf("%s ", $j);printf("\n") }}' | awk -F@ '{ print $1 }' | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/ CPU//g" | awk '{print $2}' | head -1 | sed "s/ *$//g")
		cpu_series=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk '{ for(i = 1; i < NF; i++) if ($i ~ /^Intel/) { for(j=i;j<=NF;j++)printf("%s ", $j);printf("\n") }}' | awk -F@ '{ print $1 }' | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/ CPU//g" | awk -F"$cpu_family " '{print $2}' | head -1 | sed "s/ *$//g")
		if [ -z "$cpu_series" ]; then
			cpu_series="Unknown"
		fi
		if [ "$cpu_family" == "Pentium" ]; then
			cpu_series_b="$cpu_series"
			cpu_series="$cpu_family $cpu_series"
		else
			m_chk=$(echo "$cpu_series" | grep -wi ".* M .*" | wc -l)
			if [ "$m_chk" -gt 0 ]; then
				cpu_series=$(echo "$cpu_series" | sed "s/ M /-/g" | awk '{print $0"M"}')
			fi
		fi
	else
		cpu_family=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*$cpu_vendor//g" | sed "s/^\s//g" | head -1)
		cpu_series=""
	fi

	if [ "$LC_CHK" == "Beijing" ]; then
		if [ "$cpu_vendor" == "Intel" ] && [ "$LC_CHK" == "Beijing" ]; then
			if [ "$cpu_series" == "ES" ] || [ "$cpu_series" == "Unkown" ]; then
				cpu_detail="| <a href='https:\/\/ark.intel.com\/content\/www\/cn\/zh\/ark.html' target=_blank>Find<\/a>"
			else
				cpu_search="https://ark.intel.com/content/www/cn/zh/ark/search.html?_charset_=UTF-8&q=$cpu_series"
				temp_file="/tmp/cpu_info_temp_url.txt"
				wget -q -O $temp_file "$cpu_search"
				url_cnt=$(cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | wc -l)
				if [ "$url_cnt" -gt 0 ]; then
					gen_url=$(cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | awk -F"value" '{print $2}' | awk -F\" '{print $2}')
				else
					gen_url=$(cat $temp_file | grep -wi "$cpu_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}')
					if [ "$cpu_family" == "Pentium" ]; then
						chg_series=$(echo $cpu_series | awk '{print "\\\-"$1"\\\-"$2"\\\-"}')
						gen_url=$(cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1)
						cpu_series="$cpu_series_b"
					fi
					if [ -z "$gen_url" ]; then
						chg_series=$(echo $cpu_series | awk '{print "\\\-"$1".*"$2"\\\-"}')
						gen_url=$(cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1)
					fi
				fi
				cpu_gen=$(curl --silent https://ark.intel.com$gen_url | grep "先前产品为" | awk -F"先前产品为 " '{print $2}' | sed "s/<\/a>//g")
				gen_url=$(echo $gen_url | sed "s/\//\\\\\//g")
				cpu_detail="($cpu_gen ) | <a href='https:\/\/ark.intel.com$gen_url' target=_blank>Detail<\/a>"
			fi
		elif [ "$cpu_vendor" == "AMD" ] && [ "$LC_CHK" == "Beijing" ]; then
			cpu_search=$(echo "$cpu_series" | awk '{print $1" "$2}')
			gen_url=$(
				curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
				https://www.amd.com/zh-hans/products/specifications/processors | grep -wi "$cpu_search" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
			)
			if [ -z "$gen_url" ]; then
				chg_series=$(echo $cpu_series | awk '{print $1}')
				gen_url=$(
					curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
					https://www.amd.com/zh-hans/products/specifications/processors | grep -wi "$chg_series" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
				)
			fi
			if [ -z "$gen_url" ]; then
				cpu_series=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk '{ for(i = NF; i >= 1; i--) if ($i ~ ".*-.*") { print $i }}' | sed "s/ *$//g")
				cpu_family=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk -F"$cpu_series" '{print $1}' | sed "s/ *$//g")
				chg_series=$(echo $cpu_series | awk '{print $1}')
				gen_url=$(
					curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
					https://www.amd.com/zh-hans/products/specifications/processors | grep -wi "$chg_series" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
				)
			fi
			cpu_gen=$(
				curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
				https://www.amd.com/zh-hans/product/$gen_url | egrep -A 2 -w ">产品代号<|>Architecture<" | grep "field__item" | sed "s/&quot;/\"/g" | awk -F\"\>\" '{print $2}' | awk -F\" '{print $1}' | tr "\n" "| " | awk -F\| '{if($2=="") {print $1} else {print $1" | " $2}}'
			)
			cpu_detail="($cpu_gen) | <a href='https:\/\/www.amd.com\/zh-hans\/product\/$gen_url' target=_blank>Detail<\/a>"
		else
			cpu_detail=""
		fi
	else
		if [ "$cpu_vendor" == "Intel" ]; then
			if [ "$cpu_series" == "ES" ] || [ "$cpu_series" == "Unkown" ]; then
				cpu_detail="| <a href='https:\/\/ark.intel.com\/content\/www\/us\/en\/ark.html' target=_blank>Find<\/a>"
			else
				cpu_search="https://ark.intel.com/content/www/us/en/ark/search.html?_charset_=UTF-8&q=$cpu_series"
				temp_file="/tmp/cpu_info_temp_url.txt"
				wget -q -O $temp_file "$cpu_search"
				url_cnt=$(cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | wc -l)
				if [ "$url_cnt" -gt 0 ]; then
					gen_url=$(cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | awk -F"value" '{print $2}' | awk -F\" '{print $2}')
				else
					gen_url=$(cat $temp_file | grep -wi "$cpu_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}')
					if [ "$cpu_family" == "Pentium" ]; then
						chg_series=$(echo $cpu_series | awk '{print "\\\-"$1"\\\-"$2"\\\-"}')
						gen_url=$(cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1)
						cpu_series="$cpu_series_b"
					fi
					if [ -z "$gen_url" ]; then
						chg_series=$(echo $cpu_series | awk '{print "\\\-"$1".*"$2"\\\-"}')
						gen_url=$(cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1)
					fi
				fi
				cpu_gen=$(curl --silent https://ark.intel.com$gen_url | grep "Products formerly" | awk -F"Products formerly " '{print $2}' | sed "s/<\/a>//g")
				gen_url=$(echo $gen_url | sed "s/\//\\\\\//g")
				cpu_detail="($cpu_gen) | <a href='https:\/\/ark.intel.com$gen_url' target=_blank>Detail<\/a>"
			fi
		elif [ "$cpu_vendor" == "AMD" ]; then
			cpu_search=$(echo "$cpu_series" | awk '{print $1" "$2}')
			gen_url=$(
				curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
				https://www.amd.com/en/products/specifications/processors | grep -wi "$cpu_search" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
			)
			if [ -z "$gen_url" ]; then
				chg_series=$(echo $cpu_series | awk '{print $1}')
				gen_url=$(
					curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
					https://www.amd.com/en/products/specifications/processors | grep -wi "$chg_series" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
				)
			fi
			if [ -z "$gen_url" ]; then
				cpu_series=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk '{ for(i = NF; i >= 1; i--) if ($i ~ ".*-.*") { print $i }}' | sed "s/ *$//g")
				cpu_family=$(cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk -F"$cpu_series" '{print $1}' | sed "s/ *$//g")
				chg_series=$(echo $cpu_series | awk '{print $1}')
				gen_url=$(
					curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
					https://www.amd.com/en/products/specifications/processors | grep -wi "$chg_series" | grep $pro_chk | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'
				)
			fi
			cpu_gen=$(
				curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
				https://www.amd.com/en/product/$gen_url | egrep -A 2 -w ">Former Codename<|>Architecture<" | grep "field__item" | sed "s/&quot;/\"/g" | awk -F\"\>\" '{print $2}' | awk -F\" '{print $1}' | tr "\n" "| " | awk -F\| '{if($2=="") {print $1} else {print $1" | " $2}}'
			)
			cpu_detail="($cpu_gen) | <a href='https:\/\/www.amd.com\/en\/product\/$gen_url' target=_blank>Detail<\/a>"
		else
			cpu_detail=""
		fi
	fi

	PICNT=$(cat /proc/cpuinfo | grep "^physical id" | sort -u | wc -l)
	CICNT=$(cat /proc/cpuinfo | grep "^core id" | sort -u | wc -l)
	CCCNT=$(cat /proc/cpuinfo | grep "^cpu cores" | sort -u | awk '{print $NF}')
	CSCNT=$(cat /proc/cpuinfo | grep "^siblings" | sort -u | awk '{print $NF}')
	THCNT=$(cat /proc/cpuinfo | grep "^processor" | wc -l)
	ODCNT=$(cat /proc/cpuinfo | grep "processor" | wc -l)
	if [ "$THCNT" -gt "0" ] && [ "$PICNT" == "0" ] && [ "$CICNT" == "0" ] && [ "$CCCNT" == "" ] && [ "$CSCNT" == "" ]; then
		PICNT="1"
		CICNT="$THCNT"
		CCCNT="$THCNT"
		CSCNT="$THCNT"
	fi
	if [ "$PICNT" -gt "1" ]; then
		TPCNT="$PICNT CPUs"
		TCCNT=$(expr $PICNT \* $CCCNT)
	else
		TPCNT="$PICNT CPU"
		TCCNT="$CCCNT"
	fi
	if [ "$TCCNT" -gt "1" ]; then
		TCCNT="$TCCNT Cores "
	else
		TCCNT="$TCCNT Core "
	fi
	if [ "$CCCNT" -gt "1" ]; then
		PCCNT="\/$CCCNT Cores "
	else
		PCCNT=" "
	fi
	if [ "$THCNT" -gt "1" ]; then
		TTCNT="$THCNT Threads"
	else
		TTCNT="$THCNT Thread"
	fi
	cpu_cores="$TCCNT($TPCNT$PCCNT| $TTCNT)"
}

PERFORM_FN() {
	if [ -f "$BKUP_DIR/admin_center.js" ] && [ -f "$BKUP_DIR/mobile.js" ]; then
		if [ "$MA_VER" -ge "6" ]; then
			if [ "$MA_VER" -ge "7" ]; then
				cpu_info=$(echo "${dt}.cpu_vendor=\"${cpu_vendor}\",${dt}.cpu_family=\"${cpu_family}\",${dt}.cpu_series=\"${cpu_series}\",${dt}.cpu_cores=\"${cpu_cores}\",${dt}.cpu_detail=\"${cpu_detail}\",")
				sed -i "s/Ext.isDefined(${dt}.cpu_vendor/${cpu_info}Ext.isDefined(${dt}.cpu_vendor/g" $BKUP_DIR/admin_center.js
				if [ -f "$BKUP_DIR/System.js" ]; then
					cpu_info_s=$(echo ${cpu_info} | sed "s/${dt}.cpu/${st}.cpu/g")
					sed -i "s/Ext.isDefined(${st}.cpu_vendor/${cpu_info_s}Ext.isDefined(${st}.cpu_vendor/g" $BKUP_DIR/System.js
				fi
			else
				cpu_info=$(echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family}\";${dt}.cpu_series=\"${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";${dt}.cpu_detail=\"${cpu_detail}\";")
				sed -i "s/if(Ext.isDefined(${dt}.cpu_vendor/${cpu_info}if(Ext.isDefined(${dt}.cpu_vendor/g" $BKUP_DIR/admin_center.js
			fi
			sed -i "s/${dt}.cpu_series)])/${dt}.cpu_series,${dt}.cpu_detail)])/g" $BKUP_DIR/admin_center.js
			sed -i "s/{2}\",${dt}.cpu_vendor/{2} {3}\",${dt}.cpu_vendor/g" $BKUP_DIR/admin_center.js
			if [ -f "$BKUP_DIR/System.js" ]; then
				sed -i "s/${st}.cpu_series)])/${st}.cpu_series,${st}.cpu_detail)])/g" $BKUP_DIR/System.js
				sed -i "s/{2}\",${st}.cpu_vendor/{2} {3}\",${st}.cpu_vendor/g" $BKUP_DIR/System.js
			fi
			cpu_info_m=$(echo "{name: \"cpu_series\",renderer: function(value){var cpu_vendor=\"${cpu_vendor}\";var cpu_family=\"${cpu_family}\";var cpu_series=\"${cpu_series}\";var cpu_cores=\"${cpu_cores}\";return Ext.String.format('{0} {1} {2} [ {3} ]', cpu_vendor, cpu_family, cpu_series, cpu_cores);},label: _T(\"status\", \"cpu_model_name\")},")
			sed -i "s/\"ds_model\")},/\"ds_model\")},${cpu_info_m}/g" $BKUP_DIR/mobile.js
		else
			if [ "$MI_VER" -gt "0" ]; then
				cpu_info=$(echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family}\";${dt}.cpu_series=\"${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";")
			else
				cpu_info=$(echo "${dt}.cpu_vendor=\"${cpu_vendor}\";${dt}.cpu_family=\"${cpu_family} ${cpu_series}\";${dt}.cpu_cores=\"${cpu_cores}\";")
			fi
			sed -i "s/if(Ext.isDefined(${dt}.cpu_vendor/${cpu_info}if(Ext.isDefined(${dt}.cpu_vendor/g" $BKUP_DIR/admin_center.js
		fi
	else
		COMMENT08_FN
	fi
}

APPLY_FN() {
	if [ -f "$BKUP_DIR/admin_center.js" ] && [ -f "$BKUP_DIR/mobile.js" ]; then
		cp -Rf $BKUP_DIR/admin_center.js $WORK_DIR/
		cp -Rf $BKUP_DIR/mobile.js $MWORK_DIR/
		if [ -f "$BKUP_DIR/System.js" ]; then
			cp -Rf $BKUP_DIR/System.js $SWORK_DIR/
			rm -rf $BKUP_DIR/System.js
		fi
		if [ "$MA_VER" -eq "6" ] && [ "$MI_VER" -lt "2" ]; then
			rm -rf $BKUP_DIR/admin_center.js
			rm -rf $BKUP_DIR/mobile.js
		else
			gzip -f $BKUP_DIR/admin_center.js
			gzip -f $BKUP_DIR/mobile.js
			mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
			mv $BKUP_DIR/mobile.js.gz $MWORK_DIR/
		fi
	else
		COMMENT08_FN
	fi
}

RECOVER_FN() {
	if [ -d "$BKUP_DIR/$TIME" ]; then
		cd $WORK_DIR
		tar -xf $BKUP_DIR/$TIME/admin_center.tar
		if [ -f "$BKUP_DIR/$TIME/mobile.tar" ]; then
			cd $MWORK_DIR
			tar -xf $BKUP_DIR/$TIME/mobile.tar
		fi
		if [ -f "$BKUP_DIR/$TIME/System.tar" ]; then
			cd $SWORK_DIR
			tar -xf $BKUP_DIR/$TIME/System.tar
		fi
		if [ "$re_check" == "y" ]; then
			if [ "$LC_CHK" == "CUSTOMLANG" ]; then
				echo -e "$MSGECHO02\n"
			elif [ "$LC_CHK" == "Beijing" ]; then
				echo -e "恢复源文件后继续.\n"
			else
				echo -e "Restore to Original Source and Continue.\n"
			fi
		else
			COMMENT09_FN
		fi
	else
		COMMENT08_FN
	fi
}

RERUN_FN() {
	if [ "$1" == "redo" ]; then
		ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | awk '{print "rm -rf '$BKUP_DIR'/"$9}' | sh
		GATHER_FN
		if [ -f "$WORK_DIR/admin_center.js" ] && [ -f "$MWORK_DIR/mobile.js" ]; then
			if [ "$MA_VER" -ge "7" ]; then
				info_cnt=$(cat $WORK_DIR/admin_center.js | egrep "${dt}.model\]\),Ext.isDefined\(${dt}.cpu_vendor" | wc -l)
				if [ -f "$BKUP_DIR/System.js" ]; then
					info_cnt_s=$(cat $WORK_DIR/admin_center.js | egrep "${st}.model\]\),Ext.isDefined\(${st}.cpu_vendor" | wc -l)
				fi
			else
				info_cnt=$(cat $WORK_DIR/admin_center.js | egrep ".model\]\);if\(Ext.isDefined|.model\]\)\}if\(Ext.isDefined" | wc -l)
			fi
			info_cnt_m=$(cat $MWORK_DIR/mobile.js | grep "ds_model\")},{name:\"ram_size" | wc -l)
			if [ "$info_cnt" -eq "0" ] && [ "$info_cnt_m" -eq "0" ]; then
				ODCNT_CHK=$(cat $WORK_DIR/admin_center.js | grep "cpu_cores=\"$ODCNT\"" | wc -l)
				if [ "$ODCNT_CHK" -gt "0" ]; then
					cpu_cores="$ODCNT"
				fi
				if [ "$MA_VER" -ge "6" ]; then
					if [ "$MA_VER" -ge "7" ]; then
						cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\",${dt}.cpu_family=\\\"${cpu_family}\\\",${dt}.cpu_series=\\\"${cpu_series}\\\",${dt}.cpu_cores=\\\"${cpu_cores}\\\",${dt}.cpu_detail=\\\"${cpu_detail}\\\","
						cpu_info_s="${st}.cpu_vendor=\\\"${cpu_vendor}\\\",${st}.cpu_family=\\\"${cpu_family}\\\",${st}.cpu_series=\\\"${cpu_series}\\\",${st}.cpu_cores=\\\"${cpu_cores}\\\",${st}.cpu_detail=\\\"${cpu_detail}\\\","
					else
						cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family}\\\";${dt}.cpu_series=\\\"${cpu_series}\\\";${dt}.cpu_cores=\\\"${cpu_cores}\\\";${dt}.cpu_detail=\\\"${cpu_detail}\\\";"
					fi
					sed -i "s/${cpu_info}//g" $WORK_DIR/admin_center.js
					sed -i "s/${dt}.cpu_detail)])/)])/g" $WORK_DIR/admin_center.js
					sed -i "s/{2} {3}\",${dt}.cpu_vendor/{2}\",${dt}.cpu_vendor/g" $WORK_DIR/admin_center.js

					ODCNT_CHK=$(cat $MWORK_DIR/mobile.js | grep "cpu_cores=\"$ODCNT\"" | wc -l)
					if [ "$ODCNT_CHK" -gt "0" ]; then
						cpu_cores="$ODCNT"
					fi

					cpu_info_m="{name: \\\"cpu_series\\\",renderer: function(value){var cpu_vendor=\\\"${cpu_vendor}\\\";var cpu_family=\\\"${cpu_family}\\\";var cpu_series=\\\"${cpu_series}\\\";var cpu_cores=\\\"${cpu_cores}\\\";return Ext.String.format('{0} {1} {2} [ {3} ]', cpu_vendor, cpu_family, cpu_series, cpu_cores);},label: _T(\\\"status\\\", \\\"cpu_model_name\\\")},"
					sed -i "s/${cpu_info_m}//g" $MWORK_DIR/mobile.js
					if [[ "$MA_VER" -eq "6" && "$MI_VER" -ge "2" ]] || [ "$MA_VER" -eq "7" ]; then
						cp -Rf $WORK_DIR/admin_center.js $WORK_DIR/admin_center.js.1
						cp -Rf $MWORK_DIR/mobile.js $MWORK_DIR/mobile.js.1
						gzip -f $WORK_DIR/admin_center.js
						gzip -f $MWORK_DIR/mobile.js
						mv $WORK_DIR/admin_center.js.1 $WORK_DIR/admin_center.js
						mv $MWORK_DIR/mobile.js.1 $MWORK_DIR/mobile.js
					fi
				else
					if [ "$MI_VER" -gt "0" ]; then
						cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family}\\\";${dt}.cpu_series=\\\"${cpu_series}\\\";${dt}.cpu_cores=\\\"${cpu_cores}\\\";"
					else
						cpu_info="${dt}.cpu_vendor=\\\"${cpu_vendor}\\\";${dt}.cpu_family=\\\"${cpu_family} ${cpu_series}\\\";${dt}.cpu_cores=\\\"${cpu_cores}\\\";"
					fi
					sed -i "s/${cpu_info}//g" $WORK_DIR/admin_center.js
				fi
			fi
		else
			COMMENT08_FN
		fi
	fi
}

BLCHECK_FN() {
	bl_check=n
	if [ -d "$BKUP_DIR" ]; then
		BK_CNT=$(ls -l $BKUP_DIR/ | grep ^d | wc -l)
		if [ "$BK_CNT" -gt "0" ]; then
			BK_CNT=$(ls -l $BKUP_DIR/ | grep ^d | grep "$BL_CHK" | wc -l)
			if [ "$BK_CNT" -gt "0" ]; then
				TIME=$(ls -l $BKUP_DIR/ | grep ^d | grep "$BL_CHK" | awk '{print $9}' | head -1)
				BK_CNT=$(ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | wc -l)
				if [ "$BK_CNT" -gt "0" ]; then
					BLSUB_FN "$1"
				else
					if [ "$re_check" == "n" ]; then
						if [ "$1" == "run" ]; then
							COMMENT03_FN
						fi
						COMMENT05_FN
					else
						STIME=$(ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1)
						BLSUB_FN "redo"
					fi
				fi
			else
				if [ "$1" == "restore" ]; then
					if [ "$LC_CHK" == "CUSTOMLANG" ]; then
						echo -e "$MSGECHO03\n"
					elif [ "$LC_CHK" == "Beijing" ]; then
						echo -e "删除旧版本备份路径.\n"
					else
						echo -e "Delete Previos Version Backup Location.\n"
					fi
					rm -rf $BKUP_DIR
					COMMENT07_FN
				else
					BK_CNT=$(ls -l $BKUP_DIR/ | grep ^d | grep -v "$BL_CHK" | wc -l)
					if [ "$BK_CNT" -gt "0" ]; then
						BL_COM=$(ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1 | awk -F_ '{print $2}')
						BL_CNT=$(ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1 | awk -F_ '{print $2}' | wc -l)
						if [ "$BL_COM" == "" ]; then
							if [ "$BL_CNT" -gt "0" ]; then
								BLSUB_FN "$1"
								bl_check=y
							else
								COMMENT06_FN
							fi
						else
							TIME=$(ls -l $BKUP_DIR/ | grep ^d | awk '{print $9}' | head -1)
							if [ "$BL_CHK" == "$BL_COM" ]; then
								if [ "$1" == "run" ]; then
									COMMENT03_FN
								else
									COMMENT05_FN
									bl_check=n
								fi
							else
								if [ "$BL_CHK" -gt "$BL_COM" ]; then
									BLSUB_FN "$1"
									bl_check=y
								else
									COMMENT06_FN
								fi
							fi
						fi
					else
						COMMENT06_FN
					fi
				fi
			fi
		else
			CASE_FN "$1"
		fi
	else
		CASE_FN "$1"
	fi
}

BLSUB_FN() {
	TIME=$(echo "$STIME")
	if [ "$1" == "run" ]; then
		RERUN_FN "redo"
	else
		RERUN_FN "$1"
	fi
	COMMENT05_FN
}

CASE_FN() {
	case "$1" in
	run) COMMENT05_FN ;;
	redo) COMMENT07_FN ;;
	restore) COMMENT07_FN ;;
	*) COMMENT06_FN ;;
	esac
}

EXEC_FN() {
	if [ -d $WORK_DIR ]; then
		if [ "$LC_CHK" == "CUSTOMLANG" ]; then
			READ_YN "$MSGECHO04 "
		elif [ "$LC_CHK" == "Beijing" ]; then
			READ_YN "自动执行 | 输入 n 手动执行. (取消: q) [y/n] : "
		else
			READ_YN "Auto Excute, If you select n, proceed interactively  (Cancel : q) [y/n] : "
		fi
		if [ "$Y_N" == "y" ]; then
			mkdir -p $BKUP_DIR/$TIME

			if [ "$re_check" == "y" ]; then
				if [ "$bl_check" == "y" ]; then
					COMMENT04_FN
				else
					RECOVER_FN
				fi
			fi

			PREPARE_FN

			GATHER_FN

			PERFORM_FN

			APPLY_FN

			COMMENT09_FN

		elif [ "$Y_N" == "n" ]; then
			if [ "$LC_CHK" == "CUSTOMLANG" ]; then
				READ_YN "$MSGECHO05 "
			elif [ "$LC_CHK" == "Beijing" ]; then
				READ_YN "源文件将在备份后处理 | 输入 n 取消备份过程. (取消: q) [y/n] : "
			else
				READ_YN "Proceed with original file backup and preparation.. If you select n, Work directly on the original file. (Cancel : q) [y/n] : "
			fi
			if [ "$Y_N" == "y" ]; then
				mkdir -p $BKUP_DIR/$TIME

				if [ "$re_check" == "y" ]; then
					if [ "$bl_check" == "y" ]; then
						COMMENT04_FN
					else
						RECOVER_FN
					fi
				fi

				PREPARE_FN

			elif [ "$Y_N" == "n" ]; then
				direct_job=y
				mkdir -p $BKUP_DIR
				PREPARE_FN
			else
				COMMENT10_FN
			fi
			if [ "$LC_CHK" == "CUSTOMLANG" ]; then
				READ_YN "$MSGECHO06 "
			elif [ "$LC_CHK" == "Beijing" ]; then
				READ_YN "显示CPU的真实信息 | 输入 n 恢复源文件. (取消: q) [y/n] : "
			else
				READ_YN "CPU name, Core count and reflects it. If you select n, Resote original file (Cancel : q) [y/n] : "
			fi
			if [ "$Y_N" == "y" ]; then
				GATHER_FN

				PERFORM_FN

				APPLY_FN

				COMMENT09_FN
			elif [ "$Y_N" == "n" ]; then
				if [ -d "$BKUP_DIR" ]; then
					gzip $BKUP_DIR/admin_center.js
					gzip $BKUP_DIR/mobile.js
					mv $BKUP_DIR/admin_center.js.gz $WORK_DIR/
					mv $BKUP_DIR/mobile.js.gz $MWORK_DIR/
					COMMENT09_FN
				else
					COMMENT07_FN
				fi
			else
				COMMENT10_FN
			fi
		else
			COMMENT10_FN
		fi
	else
		COMMENT08_FN
	fi
}

COMMENT03_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO07\n"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "检测到曾运行过该版本工具. 请重新运行并选择 2) redo .\n"
	else
		echo -e "There is a history of running the same version. Please run again select 2) redo .\n"
	fi
	exit 0
}

COMMENT04_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO08\n"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "当安装了更高版本时不会恢复源文件. 继续中...\n"
	else
		echo -e "Do not restore to source when installing a higher version. Contiue...\n"
	fi
}

COMMENT05_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO09\n"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "检测到旧版本安装. 继续中...\n"
	else
		echo -e "You have verified and installed the previous version. Contiue...\n"
	fi
}

COMMENT06_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO10"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "出现问题. 请检查后重试."
	else
		echo -e "Problem and exit. Please run again after checking."
	fi
	exit 0
}

COMMENT07_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO11"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "该版本工具无执行记录. 请选择 1) 首次运行."
	else
		echo -e "No execution history at this version. Please go back to the first run."
	fi
	exit 0
}

COMMENT08_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO12"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "目标文件(路径)不存在. 请在检查后重试."
	else
		echo -e "The target file(location) does not exist. Please run again after checking."
	fi
	exit 0
}

COMMENT09_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		if [ -f "$SWORK_DIR/System.js" ]; then
			echo -e "$MSGECHO13"
		fi
		echo -e "$MSGECHO13"
	elif [ "$LC_CHK" == "Beijing" ]; then
		if [ -f "$SWORK_DIR/System.js" ]; then
			echo -e "如果你使用了 Surveillance Studio, Surveillance Studio 中的信息也会改变."
		fi
		echo -e "操作完成!! 大约需要1-2分钟生效, \n(请使用 F5 刷新 DSM 页面或重新登录 DSM.)"
	else
		if [ -f "$SWORK_DIR/System.js" ]; then
			echo -e "If you use Surveillance Studio, it also applies to Surveillance Studio System Information."
		fi
		echo -e "The operation is complete!! It takes about 1-2 minutes to apply, \n(Please refresh the DSM page with F5 or after logout/login and check the information.)"
	fi
	exit 0
}

COMMENT10_FN() {
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO14"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "仅可输入 y / n / q."
	else
		echo -e "Only y / n / q can be input. Please proceed again."
	fi
	exit 0
}

# ==============================================================================
# Main Progress
# ==============================================================================
clear
WORK_DIR="/usr/syno/synoman/webman/modules/AdminCenter"
SWORK_DIR="/var/packages/SurveillanceStation/target/ui/modules/System"
MWORK_DIR="/usr/syno/synoman/mobile/ui"
BKUP_DIR="/root/Xpenology_backup"
VER_DIR="/etc.default"

if [ "$LC_CHK" == "CUSTOMLANG" ]; then
	cecho c "$MSGECHO15\033[0;31m"$ver"\033[00m - $MSGECHO16 FOXBI Wen_qi\n"
elif [ "$LC_CHK" == "Beijing" ]; then
	cecho c "DSM CPU 信息补丁 ver. \033[0;31m"$ver"\033[00m - made by FOXBI, edited by Wen_qi \n"
else
	cecho c "DSM CPU Information Change Tool ver. \033[0;31m"$ver"\033[00m - made by FOXBI, edited by Wen_qi \n"
fi

if [ -d "$VER_DIR" ]; then
	VER_FIL="$VER_DIR/VERSION"
else
	VER_FIL="/etc/VERSION"
fi

if [ -f "$VER_FIL" ]; then
	MA_VER=$(cat $VER_FIL | grep majorversion | awk -F \= '{print $2}' | sed 's/\"//g')
	MI_VER=$(cat $VER_FIL | grep minorversion | awk -F \= '{print $2}' | sed 's/\"//g')
	PD_VER=$(cat $VER_FIL | grep productversion | awk -F \= '{print $2}' | sed 's/\"//g')
	BL_NUM=$(cat $VER_FIL | grep buildnumber | awk -F \= '{print $2}' | sed 's/\"//g')
	BL_FIX=$(cat $VER_FIL | grep smallfixnumber | awk -F \= '{print $2}' | sed 's/\"//g')
	if [ "$BL_FIX" -gt "0" ]; then
		BL_UP="Update $BL_FIX"
	else
		BL_UP=""
	fi
else
	COMMENT08_FN
fi

BL_CHK=$BL_NUM$BL_FIX
TIME=$(date +%Y%m%d%H%M%S)"_"$BL_CHK
STIME="$TIME"

if [ "$MA_VER" -gt "4" ]; then
	if [ "$MA_VER" -eq "5" ]; then
		MWORK_DIR="/usr/syno/synoman/webman/mapp"
	fi
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		cecho g "$MSGECHO17 \033[0;36mDSM \033[0;31m"$PD_VER"-"$BL_NUM" $BL_UP \033[0;32m \033[00m\n"
	elif [ "$LC_CHK" == "Beijing" ]; then
		cecho g "DSM 版本: \033[0;36mDSM \033[0;31m"$PD_VER"-"$BL_NUM" $BL_UP\033[0;32m \033[00m\n"
	else
		cecho g "Your version of DSM is \033[0;36mDSM \033[0;31m"$PD_VER"-"$BL_NUM" $BL_UP \033[0;32m \033[00m\n"
	fi
else
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO19"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "暂不支持 DSM 5 以下版本. 操作取消."
	else
		echo -e "DSM version less than 5 is not supported. End the process."
	fi
	exit 0
fi

if [ "$MA_VER" -ge "6" ]; then
	if [ "$MA_VER" -ge "7" ]; then
		dt=t
		st=e
	else
		if [ "$BL_NUM" -ge "24922" ]; then
			if [ "$BL_NUM" -ge "25423" ]; then
				dt=g
			else
				dt=h
			fi
		else
			dt=f
		fi
	fi
else
	dt=b
fi

GATHER_FN

cpu_cores=$(echo ${cpu_cores}"-"${cpu_gen} | sed 's/\\\//g/')

if [ "$LC_CHK" == "CUSTOMLANG" ]; then
	cecho g "$MSGECHO26\033[00m\n"
	cesho g "\033[0;36m${cpu_vendor} ${cpu_family} ${cpu_series} \033[0;31m[\033[0;36m${cpu_cores}\033[0;31m] \033[0;32m$MSGECHO18...\033[00m\n"
elif [ "$LC_CHK" == "Beijing" ]; then
	cecho g "CPU信息将会被应用为: \033[00m\n"
	cecho g "\033[0;36m${cpu_vendor} ${cpu_family} ${cpu_series} \033[0;31m[\033[0;36m${cpu_cores}\033[0;31m] \033[0;32m继续...\033[00m\n"
else
	cecho g "The CPU information to be applied is as follows.\033[00m\n"
	cecho g "\033[0;36m${cpu_vendor} ${cpu_family} ${cpu_series} \033[0;31m[\033[0;36m${cpu_cores}\033[0;31m] \033[0;32mcontinue...\033[00m\n"
fi

if [ "$LC_CHK" == "CUSTOMLANG" ]; then
	read -n1 -p "$MSGECHO20 " run_select
elif [ "$LC_CHK" == "Beijing" ]; then
	read -n1 -p "1) 首次运行  2) 重新运行  3) 恢复  - 输入数字选择 : " run_select
else
	read -n1 -p "1) First run  2) Redo  3) Restore - Select Number : " run_select
fi
case "$run_select" in
1)
	run_check=run
	echo -e "\n "
	;;
2)
	run_check=redo
	echo -e "\n "
	;;
3)
	run_check=restore
	echo -e "\n "
	;;
*) echo -e "\n" ;;
esac

if [ "$run_check" == "redo" ]; then
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		READ_YN "$MSGECHO21"
	elif [ "$LC_CHK" == "Beijing" ]; then
		READ_YN "是否重新处理? 将会先恢复源文件.(取消: q) [y/n] : "
	else
		READ_YN "Do you want to proceed again? Restore to original file backup and proceed.(Cancel : q) [y/n] : "
	fi
	if [ "$Y_N" == "y" ]; then
		re_check=y
		BLCHECK_FN "$run_check"
		run_check=run
		EXEC_FN
	elif [ "$Y_N" == "n" ]; then
		if [ "$LC_CHK" == "CUSTOMLANG" ]; then
			echo -e "$MSGECHO22"
		elif [ "$LC_CHK" == "Beijing" ]; then
			echo -e "取消重新安装."
		else
			echo -e "Do not proceed with the redo."
		fi
	else
		COMMENT10_FN
	fi
elif [ "$run_check" == "restore" ]; then
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		READ_YN "$MSGECHO23 "
	elif [ "$LC_CHK" == "Beijing" ]; then
		READ_YN "是否恢复源文件? (取消: q) [y/n] : "
	else
		READ_YN "Do you want to restore using the original backup file? (Cancel : q) [y/n] : "
	fi
	if [ "$Y_N" == "y" ]; then
		re_check=n
		BLCHECK_FN "$run_check"
		RECOVER_FN
	elif [ "$Y_N" == "n" ]; then
		if [ "$LC_CHK" == "CUSTOMLANG" ]; then
			echo -e "$MSGECHO24"
		elif [ "$LC_CHK" == "Beijing" ]; then
			echo -e "未恢复."
		else
			echo -e "No restore was performed."
		fi
	else
		COMMENT10_FN
	fi
elif [ "$run_check" == "run" ]; then
	re_check=n
	BLCHECK_FN "$run_check"
	EXEC_FN
else
	if [ "$LC_CHK" == "CUSTOMLANG" ]; then
		echo -e "$MSGECHO25"
	elif [ "$LC_CHK" == "Beijing" ]; then
		echo -e "请输入正确的数字."
	else
		echo -e "Please select the correct number."
	fi
fi

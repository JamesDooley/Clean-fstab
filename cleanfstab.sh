#!/bin/bash
OIFS=$IFS
function fix_tabs {
        IFS=$'\n'
        fstab=$(cat /etc/fstab)
        if [[ -f "/etc/fstab.new" ]]; then
                rm -f /etc/fstab.new
        fi
        for line in $fstab; do
                if [[ $(echo "$line" | grep '^#') ]]; then
                        echo "$line" >> /etc/fstab.new
                else
                        IFS=$OIFS
                        output=
                        local comments
                        read -a cols <<< "$line"
                        for index in {0..3}; do
                                col=${cols[index]}
                                if [[ $USE_SPACES ]]; then
                                	output+=$(add_spaces "$col" ${max_tabs[index]})
                                else
                                	output+=$(add_tabs "$col" ${max_tabs[index]})
                                fi
                        done
                        if [[ $(echo "$line" | grep '#') ]]; then
                                comments=" #$(echo "$line" | cut -sd# -f2-)"
                        fi
                        echo -e "$output ${cols[4]} ${cols[5]}$comments" >> /etc/fstab.new
                fi
        done
}

function add_tabs {
        local characters=${#1}
        local tab_spaces=$(($characters / 8))
        local tab_needed=$(($2 - $tab_spaces))
        local output="$1"
        if [[ $tab_needed -gt 0 ]]; then
                for ((i=1;i<=tab_needed;i++)); do
                        output+="\t"
                done
        fi
        echo "$output"
}

function add_spaces {
        local characters=${#1}
        local spaces_needed=$(($2 - $characters))
        local output="$1"
        if [[ $spaces_needed -gt 0 ]]; then
                for ((i=1;i<=spaces_needed;i++)); do
                        output+=" "
                done
        fi
        echo "$output"
}

function calc_tabs {
        local max_characters=
        max_tabs=
        local char_count=
        local fstab=$(cat /etc/fstab| grep -v "^#")
        IFS=$'\n'
        for line in $fstab; do
                IFS=$OIFS
                read -a cols <<< "$line"
                for index in {0..3}; do
                        col=${cols[index]}
                        charcount=${#col}
                        if [[ ! $max_characters[index] > 0 ]]; then
                                max_characters[index]=0
                        fi
                        if ((10#$charcount > 10#${max_characters[index]})); then
                                max_characters[index]=${#col}
                                if [[ $USE_SPACES ]]; then
                                	max_tabs[index]=$((${max_characters[index]} + 2 ))
                                else
                                	max_tabs[index]=$(($charcount / 8 + 1))
                                fi
                        fi
                done
        done
}

function usage {
	cat << USAGE

$0 [--tabs] [--display[-only]] [--write]

Description: Fixes the /etc/fstab file to properly align each column using spaces or tabs.
	The default action is to adjust the fstab using spaces and save it as /etc/fstab.new.

	--tabs
		Use tabs instead of spaces when aligning the columns

	--display
		Display the contents of the adjusted fstab file.
		If write is not supplied save the temporary file as /etc/fstab.new
		
	--display-only
		Display the contents of the adjusted fstab file.
		If write is not supplied, delete the temporary file.

	--write
		Move the current /etc/fstab to /etc/fstab.old and save the adjusted fstab as /etc/fstab 
USAGE
}

USE_SPACES=1
until [[ -z $1 ]]; do
	case "$1" in
		--tabs)
			USE_SPACES=0
			shift
		;;
		--display)
			DISPLAY_OUTPUT=1
			shift
		;;
		--display-only)
			DISPLAY_OUTPUT=1
			DELETE_TEMP=1
			shift
		;;
		--write)
			WRITE_FSTAB=1
			shift
		;;
		*)
			usage
			exit 1
		;;
	esac
done

calc_tabs
fix_tabs

if [[ $DISPLAY_OUTPUT ]]; then
	cat /etc/fstab.new
fi

if [[ $WRITE_FSTAB ]]; then
	echo "Replacing current fstab, backup saved as fstab.old"
	mv /etc/fstab{,.old}
	mv /etc/fstab{.new,}
else
	if [[ $DELETE_TEMP ]]; then
		rm -f /etc/fstab.new
	else
		echo "Updated fstab saved as /etc/fstab.new"
	fi
fi
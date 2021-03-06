#!/bin/bash

SKILLS=(Overall Attack Defence Strength Hitpoints Ranged Prayer Magic Cooking Woodcutting Fletching Fishing Firemaking Crafting Smithing Mining Herblore Agility Thieving Slayer Farming Runecraft Hunter Construction)
URL='http://services.runescape.com/m=hiscore_oldschool/index_lite.ws'
URL_RUNETRACKER='http://runetracker.org/updateUser.php'
URL_CML='https://crystalmathlabs.com/tracker/update.php'

DIR="$(cd "$(dirname "$0")" && pwd -P)"
cd "$DIR"
LIST="$DIR/userlist"
STATSDIR="$DIR/stats/"
mkdir -p "$STATSDIR"

usage(){
	echo "Usage: scapetrack [OPTION]"; echo
	echo " 	-U, --updateall"
	echo " 	-u, --update [username]"
	echo " 	-s, --show [username]"
	echo
}

update(){
	stats="$(curl -s --data-urlencode "player=$1" "$URL" | sed 's/,/ /g' | tr '/\n/' '/ /')"
	curl -s --data-urlencode "player=$1" "$URL_CML" -G &>/dev/null
	curl -s --data-urlencode "user=$1" "$URL_RUNETRACKER" -G &>/dev/null
	if [ -n "$stats" ]; then
		echo $STATSDIR"$1"
		echo "$(date +%s) $stats" >> $STATSDIR"$1"
		printf "%-32s%s\n" "$1" ":)"
	else
		printf "%-32s%s\n" "$1" ":("
	fi
}

updateall(){
	if [ -f "$LIST" ]; then
		echo "Fetching stats for users..."
		while read -r user; do
			update "$user"
		done < "$LIST"
	fi
}

show(){
	if [ -f "$STATSDIR$1" ]; then
		cur_stats="$(tail -n1 "$STATSDIR$1")"

		printf "\033[1m%-16s%16s%16s%16s\033[m\n" "Skill" "Level" "Exp" "Rank"
		for i in {0..23}
		do
			let lvl_index=$i*3+3
			let exp_index=$i*3+4
			let rank_index=$i*3+2
			echo "$cur_stats" | awk '{printf "%-16s%16s%16s%16s\n","'"${SKILLS[$i]}"'", \
				$"'"$lvl_index"'",$"'"$exp_index"'",$"'"$rank_index"'"}'
		done

		timestamp=$(echo $cur_stats | awk '{print $1}')
		printf "%-20s%44s\n" "Last updated:" "$(date -d"@$timestamp")"
	else
		echo "No stats found for $1."
	fi
}


case $1 in
	-U|--updateall)
		updateall
		;;
	-u|--update)
		update "${2,,}" //transform username to lowercase
		;;
	-s|--show)
		show "${2,,}"   //transform username to lowercase

		;;
	*)
		usage
		;;
esac

#!/usr/bin/zsh
# 
# 
# Convenience functions and initial login with session token setting to enable 
# shell login into bitwarden and subsequent functions (searching for items) without
# any login. 
#

# ENVS
echo "EMAIL: $BW_EMAIL"

#######################################
# Unlocks bitwarden and exports the BW_SESSION variable either by unlocking
# or by login depending on the `bw status`.
#
# Arguments:
#   None
# Returns:
#   None
#######################################
bw_unlock(){
    local login_cmd_result=
    local BW_STATUS=$(bw status | jq -r '.status')
    
    echo "status: $BW_STATUS"
    if [ "$BW_STATUS" = "locked" ]; then  # unlock
        until login_cmd_result=$(bw unlock); do; done
    elif [ "$BW_STATUS" = "unauthenticated" ]; then  # login
        until login_cmd_result=$(bw login ${BW_EMAIL}); do; done
    else
        echo "Already logged in or unknown status ($BW_STATUS)"
        return 0
    fi

    local session_token=$(echo "$login_cmd_result" | grep -Po 'export BW_SESSION="\K.*(?=")')
    export BW_SESSION=$session_token
}

#######################################
# Find an item in bitwarden with the list command and search flag.
# From the first matched result the password is copied to the clipboard.
#
# Arguments:
#   itemid to find
# Returns:
#   None
#######################################
bw_list() {
    local SEARCH_RESULT=$(bw list items --search $1)
    local NUM_RESULTS=$(jq -r length <<< $SEARCH_RESULT)
    local ITEM_IDX=0
    if [[ $NUM_RESULTS -eq 0 ]]; then
        echo "Nothing found."
        return 1
    elif [[ $NUM_RESULTS -gt 1 ]]; then
        local extracted=$(jq -r '.[] | {name, "ok": .login["username"]} | join(";")' <<< $SEARCH_RESULT)
        declare -a options=($(echo $extracted | tr "\n" " "))
        PS3="Choose account: "
        select account in "${options[@]}"
        do
            ITEM_IDX=$(($REPLY-1))
            break
        done
    fi

    echo "Using item index: ${ITEM_IDX}"
    local ITEMNAME=$(jq -r ".[$ITEM_IDX].name" <<< $SEARCH_RESULT)
    local ITEMUSER=$(jq -r ".[$ITEM_IDX].login.username" <<< $SEARCH_RESULT)
    echo $SEARCH_RESULT | jq -r ".[$ITEM_IDX].login.password" | xclip -se c
    echo "Used item: $ITEMNAME"
    echo -e "\tUsername: $ITEMUSER"
    echo -e "\tPassword copied!"
}

bw_unlock

alias bwg='f() {echo "$(bw get password $1)" | xclip -se c}; f'
alias bws="bw_list"


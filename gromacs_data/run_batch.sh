#!/bin/bash
set -euo pipefail

ROOT_DIR=$(pwd)
LOG_DIR="$ROOT_DIR/logs"
SUMMARY_LOG="$LOG_DIR/batch_summary.log"

mkdir -p "$LOG_DIR"

echo "========================================" >> "$SUMMARY_LOG"
echo "Batch started at $(date)" >> "$SUMMARY_LOG"
echo "========================================" >> "$SUMMARY_LOG"

for project in project*/; do

    PROJECT_NAME=$(basename "$project")
    PROJECT_PATH="$ROOT_DIR/$PROJECT_NAME"
    PROJECT_LOG="$LOG_DIR/${PROJECT_NAME}_output.log"

    echo ""
    echo "Starting $PROJECT_NAME at $(date)" | tee -a "$SUMMARY_LOG"

    cd "$PROJECT_PATH" || {
        echo "Cannot enter $PROJECT_NAME" | tee -a "$SUMMARY_LOG"
        continue
    }

    # Check if md.tpr exists
    if [ ! -f "md.tpr" ]; then
        echo "md.tpr missing in $PROJECT_NAME — SKIPPING" | tee -a "$SUMMARY_LOG"
        cd "$ROOT_DIR"
        continue
    fi

    # Resume if checkpoint exists
    if [ -f "md.cpt" ]; then
        echo "Checkpoint found. Resuming $PROJECT_NAME" | tee -a "$SUMMARY_LOG"

        gmx mdrun \
            -deffnm md \
            -ntomp 22 \
            -nb gpu \
            -pme gpu \
            -bonded gpu \
            -gpu_id 0 \
            -cpi md.cpt \
            -append \
            -cpt 60 \
            -v \
            > "$PROJECT_LOG" 2>&1

    else
        echo "No checkpoint found. Starting fresh run." | tee -a "$SUMMARY_LOG"

        gmx mdrun \
            -deffnm md \
            -ntomp 22 \
            -nb gpu \
            -pme gpu \
            -bonded gpu \
            -gpu_id 0 \
            -cpt 60 \
            -v \
            > "$PROJECT_LOG" 2>&1
    fi

    EXIT_STATUS=$?

    if [ $EXIT_STATUS -eq 0 ]; then
        echo "$PROJECT_NAME COMPLETED at $(date)" | tee -a "$SUMMARY_LOG"
    else
        echo "$PROJECT_NAME FAILED at $(date)" | tee -a "$SUMMARY_LOG"
    fi

    echo "----------------------------------------" >> "$SUMMARY_LOG"

    cd "$ROOT_DIR"

done

echo "Batch finished at $(date)" >> "$SUMMARY_LOG"
echo "========================================" >> "$SUMMARY_LOG"

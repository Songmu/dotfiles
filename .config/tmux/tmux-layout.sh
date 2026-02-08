#!/bin/bash
# tmux-layout.sh - Create initial layouts similar to .screenrc.layout
#
# Usage:
#   tmux-layout.sh [layout_name]
#
# Layouts:
#   full       - Single pane (default)
#   threepain  - Left large pane, right top/bottom panes (65%/35%)
#   vertical   - Two vertical panes (50%/50%)
#
# If no argument is given, creates a new session with all layouts as windows

set -e

SESSION_NAME="${TMUX_SESSION:-main}"

create_layout_full() {
    # Layout 0: full - single pane
    tmux new-window -t "$SESSION_NAME" -n "full" 2>/dev/null || true
}

create_layout_threepain() {
    # Layout 1: threepain - left large, right top/bottom
    # Similar to .screenrc.layout layout1
    local win_name="threepain"

    if tmux list-windows -t "$SESSION_NAME" -F "#W" | grep -q "^${win_name}$"; then
        tmux select-window -t "$SESSION_NAME:$win_name"
    else
        tmux new-window -t "$SESSION_NAME" -n "$win_name"
    fi

    # Split vertically (left/right)
    tmux split-window -h -t "$SESSION_NAME:$win_name" -p 35

    # Split right pane horizontally (top/bottom)
    tmux split-window -v -t "$SESSION_NAME:$win_name.1"

    # Focus on left pane
    tmux select-pane -t "$SESSION_NAME:$win_name.0"
}

create_layout_vertical() {
    # Layout 2: vertical - two vertical panes
    # Similar to .screenrc.layout layout2
    local win_name="vertical"

    if tmux list-windows -t "$SESSION_NAME" -F "#W" | grep -q "^${win_name}$"; then
        tmux select-window -t "$SESSION_NAME:$win_name"
    else
        tmux new-window -t "$SESSION_NAME" -n "$win_name"
    fi

    # Split vertically (left/right)
    tmux split-window -h -t "$SESSION_NAME:$win_name"

    # Focus on left pane
    tmux select-pane -t "$SESSION_NAME:$win_name.0"
}

create_all_layouts() {
    # Check if session exists
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        # Create new session with first window
        tmux new-session -d -s "$SESSION_NAME" -n "full"
    fi

    create_layout_threepain
    create_layout_vertical

    # Select first window (full)
    tmux select-window -t "$SESSION_NAME:0"

    echo "Created layouts in session '$SESSION_NAME':"
    echo "  Window 0: full (single pane)"
    echo "  Window 1: threepain (left large, right top/bottom)"
    echo "  Window 2: vertical (left/right split)"
    echo ""
    echo "Attach with: tmux attach -t $SESSION_NAME"
}

# Main
case "${1:-all}" in
    full)
        create_layout_full
        ;;
    threepain)
        create_layout_threepain
        ;;
    vertical)
        create_layout_vertical
        ;;
    all)
        create_all_layouts
        ;;
    *)
        echo "Usage: $0 [full|threepain|vertical|all]"
        exit 1
        ;;
esac

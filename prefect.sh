#!/bin/bash
tmux has-session -t prefect-server 2>/dev/null
if [ $? != 0 ]; then
    tmux new -d -s prefect-server
fi
tmux send-keys -t prefect-server 'prefect server start' ENTER
tmux has-session -t prefect-agent 2>/dev/null
if [ $? != 0 ]; then
    tmux new -d -s prefect-agent
fi
tmux send-keys -t prefect-agent 'prefect agent start -q default' ENTER
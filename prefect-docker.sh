#!/bin/bash
tmux has-session -t prefect-server 2>/dev/null
if [ $? != 0 ]; then
    tmux new -d -s prefect-server
fi
tmux send-keys -t prefect-server 'docker-compose --profile server up' ENTER
tmux has-session -t prefect-agent 2>/dev/null
if [ $? != 0 ]; then
    tmux new -d -s prefect-agent
fi
tmux send-keys -t prefect-agent 'docker-compose --profile agent up' ENTER
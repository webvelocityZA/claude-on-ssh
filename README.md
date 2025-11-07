# Start Claude
claude-cli

# Inside container - Interactive mode
claude

# Inside container - Quick mode  
ANTHROPIC_API_KEY="sk-key" claude --print "question"

# Continue conversation
claude --print --continue "follow-up"

# Exit
exit

# Cleanup stuck containers
claude-cleanup

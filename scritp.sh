#!/bin/bash

# Set max number of retries
MAX_RETRIES=5
RETRY_COUNT=0
SUCCESS=false

echo "Starting git push with auto-retry..."

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    # Increment retry counter
    RETRY_COUNT=$((RETRY_COUNT + 1))
    
    echo "Attempt $RETRY_COUNT of $MAX_RETRIES"
    
    # Try to push
    git push
    
    # Check if push was successful
    if [ $? -eq 0 ]; then
        echo "Git push successful!"
        SUCCESS=true
    else
        echo "Git push failed. Retrying in 3 seconds..."
        sleep 3
    fi
done

if [ "$SUCCESS" = true ]; then
    echo "Push completed successfully."
else
    echo "Failed to push after $MAX_RETRIES attempts."
    exit 1
fi
#!/usr/bin/env python3
"""
Simple Patch Tracker - Works with Jira MCP
Accepts JSON data from agent and sends Teams notifications
"""

import json
import os
import sys
from datetime import datetime

def send_teams_notification(data):
    """
    Send Teams notification using webhook
    """
    webhook_url = os.getenv('TEAMS_WEBHOOK_URL')
    
    if not webhook_url:
        print("❌ TEAMS_WEBHOOK_URL not configured")
        return False
    
    # Parse data if it's a string
    if isinstance(data, str):
        try:
            data = json.loads(data)
        except json.JSONDecodeError:
            print(f"❌ Invalid JSON data: {data}")
            return False
    
    # Build Teams message
    total = len(data.get('ready_to_start', [])) + len(data.get('blocked', [])) + len(data.get('in_progress', [])) + len(data.get('needs_review', []))
    
    message = {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "themeColor": "0078D4",
        "summary": f"Patch Analysis - {data.get('timestamp', 'N/A')}",
        "sections": [{
            "activityTitle": "🎯 Archibus Patch Tracker Status",
            "activitySubtitle": f"Analysis at {data.get('timestamp', 'N/A')}",
            "facts": [
                {"name": "Total Patches", "value": str(total)},
                {"name": "Ready to Start", "value": str(len(data.get('ready_to_start', [])))},
                {"name": "Blocked", "value": str(len(data.get('blocked', [])))},
                {"name": "In Progress", "value": str(len(data.get('in_progress', [])))},
                {"name": "Needs Review", "value": str(len(data.get('needs_review', [])))},
            ]
        }]
    }
    
    # Add details if there are tickets in each category
    if data.get('ready_to_start'):
        message['sections'].append({
            "activityTitle": "✅ Ready to Start",
            "facts": [{"name": item.get('key'), "value": item.get('summary', 'N/A')} for item in data.get('ready_to_start', [])[:5]]
        })
    
    if data.get('blocked'):
        message['sections'].append({
            "activityTitle": "⛔ Blocked",
            "facts": [{"name": item.get('key'), "value": item.get('blocker', 'N/A')} for item in data.get('blocked', [])[:5]]
        })
    
    try:
        import requests
        response = requests.post(webhook_url, json=message, timeout=30)
        if response.status_code == 200:
            print(f"✅ Teams notification sent successfully (total: {total} patches)")
            return True
        else:
            print(f"❌ Teams notification failed with status {response.status_code}: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error sending Teams notification: {str(e)}")
        return False

if __name__ == "__main__":
    # Check for --data argument containing JSON
    data = None
    
    for i, arg in enumerate(sys.argv[1:]):
        if arg == "--data" and i + 1 < len(sys.argv) - 1:
            try:
                data = json.loads(sys.argv[i + 2])
            except (json.JSONDecodeError, IndexError) as e:
                print(f"❌ Failed to parse --data argument: {e}")
                sys.exit(1)
    
    # If no data provided, create empty structure
    if not data:
        data = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
            "ready_to_start": [],
            "blocked": [],
            "in_progress": [],
            "needs_review": []
        }
    
    # Send Teams notification
    if "--notify" in sys.argv:
        success = send_teams_notification(data)
        sys.exit(0 if success else 1)
    else:
        print(f"✅ Patch analysis data: {json.dumps(data, indent=2)}")

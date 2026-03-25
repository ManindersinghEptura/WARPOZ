#!/usr/bin/env python3
"""
Simple Patch Tracker - Works with Jira MCP without complex skill framework
This script uses the same pattern as the working archibus-triage
"""

import json
import os
import sys
from datetime import datetime

def analyze_patches():
    """
    Simple patch analysis using Jira MCP calls directly
    """
    print("🎯 **PATCH TICKET ANALYSIS**")
    print("=" * 50)
    
    # This will use the Jira MCP that's available in the environment
    # The actual Jira queries will be handled by the agent using MCP tools
    
    analysis_summary = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
        "ready_to_start": [],
        "blocked": [],
        "in_progress": [],
        "needs_review": []
    }
    
    print(f"Analysis completed at {analysis_summary['timestamp']}")
    print("\nTo use this script:")
    print("1. The agent will use Jira MCP to fetch patch tickets")
    print("2. Agent will analyze dependencies")
    print("3. Agent will categorize tickets")
    print("4. Agent will format results and send Teams notification")
    
    return analysis_summary

def send_teams_notification(data):
    """
    Send Teams notification using webhook
    """
    webhook_url = os.getenv('TEAMS_WEBHOOK_URL')
    
    if not webhook_url:
        print("❌ TEAMS_WEBHOOK_URL not found in environment")
        return False
    
    # Simple Teams message format
    message = {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "themeColor": "0078D4", 
        "summary": f"Patch Analysis - {data['timestamp']}",
        "sections": [{
            "activityTitle": "🎯 Archibus Patch Tracker",
            "activitySubtitle": f"Analysis at {data['timestamp']}",
            "facts": [
                {"name": "Ready to Start", "value": str(len(data.get('ready_to_start', [])))},
                {"name": "Blocked", "value": str(len(data.get('blocked', [])))},
                {"name": "In Progress", "value": str(len(data.get('in_progress', [])))},
                {"name": "Needs Review", "value": str(len(data.get('needs_review', [])))},
            ]
        }]
    }
    
    try:
        import requests
        response = requests.post(webhook_url, json=message, timeout=30)
        if response.status_code == 200:
            print("✅ Teams notification sent successfully")
            return True
        else:
            print(f"❌ Teams notification failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error sending Teams notification: {e}")
        return False

if __name__ == "__main__":
    # Run analysis
    results = analyze_patches()
    
    # Send notification if requested
    if len(sys.argv) > 1 and sys.argv[1] == "--notify":
        send_teams_notification(results)
    
    print("\n✅ Patch tracker script completed")
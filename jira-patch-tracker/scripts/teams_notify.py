#!/usr/bin/env python3
"""
Teams Notification Script for Patch Tracker

Sends formatted patch analysis results to Microsoft Teams via webhook.
"""

import os
import sys
import json
import requests
from datetime import datetime
from typing import Dict, List, Any

def format_teams_message(analysis_data: Dict[str, Any]) -> Dict[str, Any]:
    """Format patch analysis data for Teams adaptive card"""
    
    # Get current timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    
    # Extract summary counts
    ready_count = len(analysis_data.get('ready_to_start', []))
    blocked_count = len(analysis_data.get('blocked', []))
    in_progress_count = len(analysis_data.get('in_progress', []))
    needs_review_count = len(analysis_data.get('needs_review', []))
    total_count = ready_count + blocked_count + in_progress_count + needs_review_count
    
    # Create Teams message
    message = {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "themeColor": "0078D4",
        "summary": f"Patch Tracker Analysis - {total_count} tickets",
        "sections": [
            {
                "activityTitle": "🎯 **Archibus Patch Tracker Report**",
                "activitySubtitle": f"Analysis completed at {timestamp}",
                "activityImage": "https://img.icons8.com/color/96/000000/jira.png",
                "facts": [
                    {"name": "Total Tickets", "value": str(total_count)},
                    {"name": "✅ Ready to Start", "value": str(ready_count)},
                    {"name": "⏳ Blocked", "value": str(blocked_count)},
                    {"name": "🔄 In Progress", "value": str(in_progress_count)},
                    {"name": "⚠️ Needs Review", "value": str(needs_review_count)}
                ],
                "markdown": True
            }
        ]
    }
    
    # Add detailed sections for each category
    if ready_count > 0:
        ready_text = "\\n".join([
            f"• **{ticket['key']}** ({ticket['priority']}) - {ticket['summary'][:60]}..."
            for ticket in analysis_data.get('ready_to_start', [])[:5]  # Limit to 5
        ])
        if ready_count > 5:
            ready_text += f"\\n• *...and {ready_count - 5} more*"
        
        message["sections"].append({
            "activityTitle": "✅ **Ready to Start**",
            "text": ready_text,
            "markdown": True
        })
    
    if blocked_count > 0:
        blocked_text = "\\n".join([
            f"• **{ticket['key']}** ({ticket['priority']}) - Blocked by {ticket.get('blocker', 'N/A')}"
            for ticket in analysis_data.get('blocked', [])[:5]  # Limit to 5
        ])
        if blocked_count > 5:
            blocked_text += f"\\n• *...and {blocked_count - 5} more*"
        
        message["sections"].append({
            "activityTitle": "⏳ **Blocked by Dependencies**",
            "text": blocked_text,
            "markdown": True
        })
    
    # Add action buttons
    message["potentialAction"] = [
        {
            "@type": "OpenUri",
            "name": "View in Jira",
            "targets": [
                {
                    "os": "default",
                    "uri": f"https://eptura.atlassian.net/issues/?jql=summary%20~%20%22patch%22%20and%20project%20%3D%20%22Change%20Management%22%20and%20status%20NOT%20IN%20(Closed%2CCancelled%2CDone%2CRejected)%20ORDER%20BY%20priority%20DESC%2C%20created%20ASC"
                }
            ]
        }
    ]
    
    return message

def send_teams_notification(webhook_url: str, analysis_data: Dict[str, Any]) -> bool:
    """Send notification to Teams channel"""
    
    try:
        message = format_teams_message(analysis_data)
        
        response = requests.post(
            webhook_url,
            headers={'Content-Type': 'application/json'},
            data=json.dumps(message),
            timeout=30
        )
        
        if response.status_code == 200:
            print("✅ Teams notification sent successfully")
            return True
        else:
            print(f"❌ Failed to send Teams notification: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error sending Teams notification: {str(e)}")
        return False

def main():
    """Main function to send Teams notification"""
    
    # Get webhook URL from environment variable
    webhook_url = os.getenv('TEAMS_WEBHOOK_URL')
    if not webhook_url:
        print("❌ TEAMS_WEBHOOK_URL environment variable not set")
        sys.exit(1)
    
    # Get analysis data from stdin or command line argument
    if len(sys.argv) > 1:
        # Data provided as command line argument
        try:
            analysis_data = json.loads(sys.argv[1])
        except json.JSONDecodeError:
            print("❌ Invalid JSON data provided")
            sys.exit(1)
    else:
        # Data provided via stdin
        try:
            analysis_data = json.load(sys.stdin)
        except json.JSONDecodeError:
            print("❌ Invalid JSON data from stdin")
            sys.exit(1)
    
    # Send notification
    success = send_teams_notification(webhook_url, analysis_data)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
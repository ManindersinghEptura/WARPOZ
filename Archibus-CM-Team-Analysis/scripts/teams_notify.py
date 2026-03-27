#!/usr/bin/env python3
"""
Teams notification script for Archibus team lead analysis.
Sends formatted team analysis reports to Microsoft Teams channels.
"""

import json
import sys
import os
import requests
from datetime import datetime

def create_teams_card(analysis_data):
    """Create a Teams adaptive card from analysis data."""
    
    # Extract key metrics from analysis data
    total_tickets = analysis_data.get('total_tickets', 0)
    team_members = analysis_data.get('team_members', [])
    status_breakdown = analysis_data.get('status_breakdown', {})
    critical_items = analysis_data.get('critical_items', [])
    priority_summary = analysis_data.get('priority_summary', {})
    
    # Build the adaptive card
    card = {
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "content": {
                    "type": "AdaptiveCard",
                    "version": "1.4",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": f"🎯 Archibus Team Analysis Report",
                            "weight": "Bolder",
                            "size": "Large",
                            "color": "Accent"
                        },
                        {
                            "type": "TextBlock",
                            "text": f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M UTC')}",
                            "size": "Small",
                            "color": "Default",
                            "spacing": "None"
                        },
                        {
                            "type": "FactSet",
                            "facts": [
                                {
                                    "title": "Total Active Tickets:",
                                    "value": str(total_tickets)
                                },
                                {
                                    "title": "Team Members:",
                                    "value": str(len(team_members))
                                },
                                {
                                    "title": "Critical Items:",
                                    "value": str(len(critical_items))
                                }
                            ],
                            "spacing": "Medium"
                        }
                    ]
                }
            }
        ]
    }
    
    # Add status breakdown
    if status_breakdown:
        status_facts = []
        for status, count in status_breakdown.items():
            percentage = round((count / total_tickets * 100), 1) if total_tickets > 0 else 0
            status_facts.append({
                "title": f"{status}:",
                "value": f"{count} ({percentage}%)"
            })
        
        card["attachments"][0]["content"]["body"].append({
            "type": "TextBlock",
            "text": "📊 Status Distribution",
            "weight": "Bolder",
            "size": "Medium",
            "spacing": "Large"
        })
        
        card["attachments"][0]["content"]["body"].append({
            "type": "FactSet",
            "facts": status_facts
        })
    
    # Add critical items section
    if critical_items:
        card["attachments"][0]["content"]["body"].append({
            "type": "TextBlock",
            "text": "🚨 Critical Items Requiring Attention",
            "weight": "Bolder",
            "size": "Medium",
            "spacing": "Large",
            "color": "Attention"
        })
        
        for item in critical_items[:5]:  # Limit to top 5
            card["attachments"][0]["content"]["body"].append({
                "type": "TextBlock",
                "text": f"• **{item.get('ticket', 'Unknown')}**: {item.get('issue', 'No description')}",
                "wrap": True,
                "spacing": "Small"
            })
    
    # Add team workload summary
    if team_members:
        workload_facts = []
        for member in team_members[:8]:  # Limit to prevent card overflow
            name = member.get('name', 'Unknown')
            count = member.get('ticket_count', 0)
            status = member.get('workload_status', '🔹')
            workload_facts.append({
                "title": f"{status} {name}:",
                "value": f"{count} tickets"
            })
        
        card["attachments"][0]["content"]["body"].append({
            "type": "TextBlock",
            "text": "👥 Team Workload",
            "weight": "Bolder",
            "size": "Medium",
            "spacing": "Large"
        })
        
        card["attachments"][0]["content"]["body"].append({
            "type": "FactSet",
            "facts": workload_facts
        })
    
    # Add action button
    card["attachments"][0]["content"]["body"].append({
        "type": "ActionSet",
        "actions": [
            {
                "type": "Action.OpenUrl",
                "title": "View in Jira",
                "url": "https://eptura.atlassian.net/issues/?jql=project%20%3D%20%22Change%20Management%22%20and%20%22Category%20and%20Sub-category%5BSelect%20List%20(cascading)%5D%22%20%3D%20Archibus%20and%20status%20NOT%20IN%20(Cancelled%2CDone)"
            }
        ],
        "spacing": "Medium"
    })
    
    return card

def send_teams_notification(webhook_url, analysis_data):
    """Send Teams notification with analysis results."""
    
    try:
        # Create the Teams card
        card = create_teams_card(analysis_data)
        
        # Send to Teams
        headers = {'Content-Type': 'application/json'}
        response = requests.post(webhook_url, json=card, headers=headers)
        response.raise_for_status()
        
        print(f"✅ Teams notification sent successfully")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to send Teams notification: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def main():
    """Main function to process analysis data and send Teams notification."""
    
    # Get webhook URL from environment variable or Oz secret
    webhook_url = os.getenv('TEAMS_WEBHOOK_URL') or os.getenv('TEAMS_LEADERSHIP_WEBHOOK')
    
    if not webhook_url:
        print("❌ Error: TEAMS_WEBHOOK_URL or TEAMS_LEADERSHIP_WEBHOOK environment variable not set")
        sys.exit(1)
    
    # Read analysis data from stdin or file argument
    if len(sys.argv) > 1:
        # Read from file
        try:
            with open(sys.argv[1], 'r') as f:
                analysis_data = json.load(f)
        except Exception as e:
            print(f"❌ Error reading analysis file: {e}")
            sys.exit(1)
    else:
        # Read from stdin
        try:
            analysis_data = json.load(sys.stdin)
        except Exception as e:
            print(f"❌ Error reading analysis data from stdin: {e}")
            sys.exit(1)
    
    # Send the notification
    success = send_teams_notification(webhook_url, analysis_data)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
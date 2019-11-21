# Slack Secret Message

This is a Slack app to easily generate [Sharelock.io](https://sharelock.io) links from within Slack.

This allows you to share secrets without leaving Slack by using a `/secret-message` command.

## Installation

Install the app to your Slack workspace by following the link below.

[![add to slack](https://platform.slack-edge.com/img/add_to_slack.png)](https://slack-secret-message.robbytaylor.io/install)

Or create your own Slack app for your own workspace with the included code.

## Privacy

This app does not store any user data.
I have not interest in keeping your secrets.

When a user uses the app to send a message to another user the recipients email address is retreived via the Slack API.
The recipients email address is submitted to Sharelock.io, alongisde the message, to authenicate the recipient so that only they can view the message.

## Support

For support [open an issue](https://github.com/robbytaylor/slack-secret-message/issues) or email slack-secret-message@robbytaylor.co.uk.
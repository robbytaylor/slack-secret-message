const { App } = require('@slack/bolt');

const app = new App({
  signingSecret: process.env.SLACK_SIGNING_SECRET,
  token: process.env.SLACK_BOT_TOKEN,
});

app.command('/encrypted-message', ({ ack, payload, context }) => {
  ack();

  console.log(payload, context);

  // Figure out who we're sending the message to.
  // In a direct message this will be the person being messaged.
  // For a channel get the users in the channel and show a dropdown to select a user.

  app.client.views.open({
    token: context.botToken,
    trigger_id: payload.trigger_id,
    view: {
      type: 'modal',
      callback_id: 'send_message',
      title: {
        type: 'plain_text',
        text: 'Send an encrypted message'
      },
      blocks: [
        {
          type: 'input',
          block_id: 'mesage',
          element: {
            type: 'plain_text_input',
            action_id: 'message_input',
            multiline: true,

          }
        }
      ],
      submit: {
        type: 'plain_text',
        text: 'Send'
      }
    }
  });
});

app.action('send_message', ({ ack, payload, context, say }) => {
  ack();

  console.log(payload, context);

  // Query the Slack API to get an email address for the target user.
  // Send to sharelock to get a URL for the share.
  // For now, just send the message.

  // Send a message to the target user telling them that <usernmae> wants to send them an encrypted message
  say({
    channel: '', // Target user ID
    blocks: [{
      "type": "section",
      "text": {
        "type": "plain_text",
        "text": `${payload.user} has sent you an encrypted message`
      },
      "accessory": {
        "type": "button",
        "text": {
          "type": "plain_text",
          "text": "View message"
        },
        "action_id": "view_message"
      }
    }]
  });
});

app.action('view_message', ({ ack, payload, context }) => {
  ack();

  app.client.views.open({
    token: context.botToken,
    trigger_id: payload.trigger_id,
    view: {
    }
  });
});

(async () => {
  await app.start(process.env.PORT || 3000);
})();
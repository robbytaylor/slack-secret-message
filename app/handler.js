'use strict';

const { App, ExpressReceiver } = require('@slack/bolt');
const axios = require('axios');

const expressReceiver = new ExpressReceiver({
  signingSecret: process.env.SLACK_SIGNING_SECRET
});

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  receiver: expressReceiver
});

const command = process.env.COMMAND || 'secret-message';
const sharelock_base_path = process.env.SHARELOCK_BASE_PATH || 'https://sharelock.io'
const send_message_callback = 'send_message';
const url_visit_callback = 'url_visit';

app.command(`/${command}`, ({ ack, payload, context }) => {
  app.client.views
    .open({
      token: context.botToken,
      trigger_id: payload.trigger_id,
      view: {
        type: 'modal',
        callback_id: send_message_callback,
        title: {
          type: 'plain_text',
          text: 'Send a secret message'
        },
        blocks: [
          {
            type: 'input',
            block_id: 'users',
            label: {
              type: 'plain_text',
              text: 'Pick a recipient from the list'
            },
            element: {
              action_id: 'user_select',
              type: 'users_select',
              placeholder: {
                type: 'plain_text',
                text: 'Select user'
              }
            }
          },
          {
            type: 'input',
            block_id: 'message',
            label: {
              type: 'plain_text',
              text: 'Enter your message'
            },
            element: {
              type: 'plain_text_input',
              action_id: 'message_input',
              multiline: true
            }
          }
        ],
        submit: {
          type: 'plain_text',
          text: 'Send message'
        }
      }
    })
    .then(() => ack());
});

app.view(send_message_callback, ({ ack, body, view, context }) => {
  const userId = view.state.values.users.user_select.selected_user;
  const message = view.state.values.message.message_input.value;

  app.client.token = process.env.SLACK_OAUTH_TOKEN;

  app.client.users.profile.get({user: userId})
    .then(result => {
      axios
        .post(`${sharelock_base_path}/create`, {
          a: result.profile.email,
          d: message
        })
        .then(response => {
          const url = sharelock_base_path + response.data;

          app.client.chat
            .postMessage({
              channel: userId,
              token: context.botToken,
              blocks: [
                {
                  type: 'section',
                  text: {
                    type: 'plain_text',
                    text: `<@${body.user.name}> has sent you a secret message`
                  },
                  accessory: {
                    type: 'button',
                    action_id: url_visit_callback,
                    text: {
                      type: 'plain_text',
                      text: 'View message'
                    },
                    url: url
                  }
              }
              ]
            })
            .then(() => ack());
        });
  });
});

app.event(url_visit_callback, ({ ack }) => {
  ack();
});

module.exports.app = require('serverless-http')(expressReceiver.app);

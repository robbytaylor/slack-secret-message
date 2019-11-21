'use strict';

const axios = require('axios');

module.exports = app => {
  const command = process.env.COMMAND || 'secret-message';
  const sharelock_base_path = process.env.SHARELOCK_BASE_PATH || 'https://sharelock.io'
  const send_message_callback = 'send_message';
  const url_visit_callback = 'url_visit';

  app.command(`/${command}`, ({ ack, payload, context }) => {
    app.client.views
      .open({
        token: context.botToken,
        trigger_id: payload.trigger_id,
        view: view_source()
      })
      .then(() => ack());
  });

  app.view(send_message_callback, ({ ack, body, view, context }) => {
    const userId = view.state.values.users.user_select.selected_user;
    const message = view.state.values.message.message_input.value;

    app.client.token = context.userToken;

    app.client.users.profile.get({ user: userId })
      .then(result => {
        const profile = result.profile;

        if (profile.bot_id) {
          return view_error(ack, "I can't send a secret message to a bot. Please select another user.");
        }

        if (!profile.email) {
          // This should never happen, but just in case we can't get an email address for this user for any other reason
          return view_error(ack, "I couldn't find the email address for that person");
        }

        axios
          .post(`${sharelock_base_path}/create`, {
            a: profile.email,
            d: message
          })
          .then(response => {
            const url = sharelock_base_path + response.data;

            app.client.chat
              .postMessage({
                channel: userId,
                token: context.botToken,
                username: "Secret Message",
                blocks: [
                  {
                    type: 'section',
                    text: {
                      type: 'plain_text',
                      text: `<@${body.user.name}> has sent you a secret message.`
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
          })
          .catch(error => {
            console.error(error);

            view_error(ack, 'Sorry, there was an error when I tried to encrypt your message.');
          });
      });
  });

  app.event(url_visit_callback, ({ ack }) => {
    ack();
  });

  const view_error = (ack, error) => {
    return ack({
      response_action: 'update',
      view: view_source(error)
    });
  }

  const view_source = (error = "") => {
    const blocks = [
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
    ];

    if (error !== "") {
      blocks.unshift({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*${error}*`
        }
      });
    }

    return {
      type: 'modal',
      callback_id: send_message_callback,
      title: {
        type: 'plain_text',
        text: 'Send a secret message'
      },
      blocks: blocks,
      submit: {
        type: 'plain_text',
        text: 'Send message'
      }
    };
  }
}
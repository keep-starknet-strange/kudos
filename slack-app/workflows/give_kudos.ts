import { DefineWorkflow, Schema } from "deno-slack-sdk/mod.ts";
import { SendToSN } from "../functions/send_to_sn.ts";

const GiveKudosWorkflow = DefineWorkflow({
  callback_id: "give_kudos_workflow",
  title: "Give Kudos",
  description: "Acknowledge the impact someone had on you",
  input_parameters: {
    properties: {
      interactivity: {
        type: Schema.slack.types.interactivity,
      },
    },
    required: ["interactivity"],
  },
});

const kudo = GiveKudosWorkflow.addStep(
  Schema.slack.functions.OpenForm,
  {
    title: "StarkWare teammate KUDOS",
    interactivity: GiveKudosWorkflow.inputs.interactivity,
    submit_label: "Share",
    description: "share kudos ON-CHAIN",
    fields: {
      elements: [{
        name: "receiver",
        title: "Teammate",
        description: "teammate to give kudos",
        type: Schema.slack.types.user_id,
      }, {
        name: "amount",
        title: "How many $KUDOS to give",
        type: Schema.types.number,
      }, {
        name: "description",
        title: "Reason for the kudos",
        type: Schema.types.string,
        long: true,
      }
      ],
      required: ["receiver", "amount", "description"],
    },
  },
);
/**
 * A custom function can be added as a workflow step to modify input data,
 * collect additional data for the response, and return information for use in
 * later steps.
 * Learn more: https://api.slack.com/automation/functions/custom
 */
const give = GiveKudosWorkflow.addStep(SendToSN, {
  receiver: kudo.outputs.receiver,
  amount: kudo.outputs.amount,
  description: kudo.outputs.description,
});

/**
 * Messages can be sent into a channel with the built-in SendMessage function.
 * Learn more: https://api.slack.com/automation/functions#catalog
 */
// GiveKudosWorkflow.addStep(Schema.slack.functions.SendMessage, {
//   channel_id: kudo.outputs.fields.kudo_channel,
//   message:
//     `*Hey <@${kudo.outputs.fields.doer_of_good_deeds}>!* Someone wanted to share some kind words with you :otter:\n` +
//     `> ${kudo.outputs.fields.kudo_message}\n` +
//     `<${gif.outputs.URL}>`,
// });

export { GiveKudosWorkflow };

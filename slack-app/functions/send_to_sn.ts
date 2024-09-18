import { DefineFunction, Schema, SlackFunction } from "deno-slack-sdk/mod.ts";

/**
 * Functions are reusable building blocks of automation that accept inputs,
 * perform calculations, and provide outputs. Functions can be used as steps in
 * a workflow or independently.
 * Learn more: https://api.slack.com/automation/functions/custom
 */
export const SendToSN = DefineFunction({
  callback_id: "send_to_sn",
  title: "Give Kudos Starknet",
  description: "Give Kudos via the deployed contracts",
  source_file: "functions/send_to_sn.ts", // The file with the exported function handler
  input_parameters: {
    properties: {
      receiver: {
        type: Schema.slack.types.user_id,
        description: "User to send Kudos",
      },
      amount: {
        type: Schema.types.number,
        description: "Amount of Kudos",
      },
      description: {
        type: Schema.types.string,
        description: "Message for Kudos",
      },
    },
    required: [],
  },
  output_parameters: {
    properties: {
      transaction_hash: {
        type: Schema.types.string,
        description: "Transaction Hash",
      },
    },
    required: ["transaction_hash"],
  },
});

/**
 * The default export for a custom function accepts a function definition
 * and a function handler that contains the custom logic for the function.
 */
export default SlackFunction(SendToSN, ({ inputs }) => {
  const { receiver, amount, description } = inputs;
  console.log("RECEIVER: ", receiver);
  console.log("AMOUNT: ", amount);
  console.log("Description: ", description);
  
  return { outputs: "0x1" };
});

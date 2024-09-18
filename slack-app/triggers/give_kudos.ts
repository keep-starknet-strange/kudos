import { Trigger } from "deno-slack-sdk/types.ts";
import { TriggerContextData, TriggerTypes } from "deno-slack-api/mod.ts";
import { GiveKudosWorkflow } from "../workflows/give_kudos.ts";

const trigger: Trigger<typeof GiveKudosWorkflow.definition> = {
  type: TriggerTypes.Shortcut,
  name: "Give some kudos",
  description: "Broadcast your appreciation with kind words and a GIF",
  workflow: `#/workflows/${GiveKudosWorkflow.definition.callback_id}`,
  inputs: {
    interactivity: {
      value: TriggerContextData.Shortcut.interactivity,
    },
  },
};

export default trigger;

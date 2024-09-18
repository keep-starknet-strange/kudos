import { Manifest } from "deno-slack-sdk/mod.ts";
import { SendToSN } from "./functions/send_to_sn.ts";
import { GiveKudosWorkflow } from "./workflows/give_kudos.ts";

/**
 * The app manifest contains the app's configuration. This file defines
 * attributes like app name, description, available workflows, and more.
 * Learn more: https://api.slack.com/automation/manifest
 */
export default Manifest({
  name: "SW Kudos",
  description: "Let another SW employee know you appreciate them ON-CHAIN!",
  icon: "assets/icon.png",
  functions: [SendToSN],
  workflows: [GiveKudosWorkflow],
  outgoingDomains: [],
  botScopes: ["commands", "chat:write", "chat:write.public"],
});

import { getFullnodeUrl } from "@iota/iota-sdk/client";
import { createNetworkConfig } from "@iota/dapp-kit";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
  createNetworkConfig({
    devnet: {
      url: getFullnodeUrl("devnet"),
    },
    testnet: {
      url: getFullnodeUrl("testnet"),
      variables: {
        packageId:
          "<YOUR_PACKAGE_ID>",
        total_seats_object:
          "<YOUR_TOTAL_SEAT_OBJECT>",
        creator_object:
          "<YOUR_CREATOR_OBJECT>",
        AvailableTickets_to_buy_object:
          "<YOUR_AVAILABLE_TICKETS_OBJECT>",
      },
    },
    mainnet: {
      url: getFullnodeUrl("mainnet"),
    },
  });

export { useNetworkVariable, useNetworkVariables, networkConfig };

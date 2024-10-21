export const config = {
  streamUrl: "https://sepolia.starknet.a5a.ch",
  startingBlock: 0,
  network: "starknet",
  finality: "DATA_STATUS_PENDING",
  filter: {
    events: [
      {
        // KudosGiven
        fromAddress: "0x049db95ecf5245921f420dfe01536c8f1266198d4d46cc28f592f51afed0159e",
        keys: [
          "0x17504808446143b4c4e13d39e8d9fe08cced73e9ce36ea1a603f2f594de49df"
        ],
        includeReverted: false,
        includeTransaction: false,
        includeReceipt: false
      }
    ]
  },
  sinkType: "webhook",
  sinkOptions: {
    targetUrl: "http://localhost:8080/api/indexer"
  }
};

export default function transform(block) {
  return block;
}
import { useState } from "react";
import {
  useAccounts,
  useSignAndExecuteTransaction,
  useIotaClient,
} from "@iota/dapp-kit"; 

import { formDataType } from "../type";
import { useNetworkVariable } from "../networkConfig";

export const useCreateForm = () => {
  const packageId = useNetworkVariable("packageId");
  const [address] = useAccounts();
  const { mutate: signAndExecuteTransaction } = useSignAndExecuteTransaction();
  const client = useIotaClient();

  const [formData, setFormData] = useState<formDataType>({
    coin: "",
    eventId: "",
    eventdate: "",
    royaltyPercentage: "",
    packageCreator: "",
    totalSeat: "",
    price: "",
    nft: "",
    recipient: "",
    initiatedResale: "",
  });

  const updateFormData = (key: keyof formDataType, value: string) => {
    setFormData((prev) => ({
      ...prev,
      [key]: value,
    }));
  };

  const resetFormData = () => {
    setFormData({
      coin: "",
      eventId: "",
      eventdate: "",
      royaltyPercentage: "",
      packageCreator: "",
      totalSeat: "",
      price: "",
      nft: "",
      recipient: "",
      initiatedResale: "",
    });
  };

  return {
    packageId,
    address,
    signAndExecuteTransaction,
    client,
    formData,
    updateFormData,
    resetFormData,
  };
};

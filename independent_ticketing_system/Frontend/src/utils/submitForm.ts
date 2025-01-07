import { IotaClient } from "@iota/iota-sdk/client";
import { formDataType, OpenFormState } from "../type";
import { burn_Ticket } from "./Burn";
import { buyResaleTicket } from "./BuyResale";
import { mint_Ticket } from "./Mint";
import { resale_Ticket } from "./Resale";
import { tranfer_Ticket } from "./Transfer";

export default (
  e: any,
  openForm: OpenFormState["openForm"],
  formData: formDataType,
  resetFormData: () => void,
  packageId: any,
  address: string,
  signAndExecuteTransaction: any,
  client: IotaClient,
) => {
  e.preventDefault();
  switch (openForm) {
    case "Mint":
      mint_Ticket(
        formData,
        resetFormData,
        packageId,
        address,
        signAndExecuteTransaction,
        client,
      );
      break;
    case "Burn":
      burn_Ticket(
        formData,
        resetFormData,
        packageId,
        signAndExecuteTransaction,
        client,
      );
      break;
    case "BuyResale":
      buyResaleTicket(
        formData,
        resetFormData,
        packageId,
        signAndExecuteTransaction,
        client,
      );
      break;
    case "Resale":
      resale_Ticket(
        formData,
        resetFormData,
        packageId,
        signAndExecuteTransaction,
        client,
      );
      break;
    case "Transfer":
      tranfer_Ticket(
        formData,
        resetFormData,
        packageId,
        signAndExecuteTransaction,
        client,
      );
      break;
    default:
      break;
  }
};

import { ToggleFormProp } from "../type";
import Button from "./Button";

export default function Transfer({setOpenForm}:ToggleFormProp) {
  return (
    <Button
      title="Transfer Ticket"
      onClick={() => {
        setOpenForm("Transfer");
      }}
    />
  );
}

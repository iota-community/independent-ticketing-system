import { ToggleFormProp } from "../type";
import Button from "./Button";

export default function Burn({setOpenForm}:ToggleFormProp) {
  return (
    <Button
      title="Burn Ticket"
      onClick={() => {
        setOpenForm("Burn")
      }}
    />
  );
}

import { ToggleFormProp } from "../type";
import Button from "./Button";

export default function Resale({setOpenForm}:ToggleFormProp) {
  return (
    <Button
      title="Resale Ticket"
      onClick={() => {
        setOpenForm("Resale");
      }}
    />
  );
}

import { ToggleFormProp } from "../type";
import Button from "./Button";

export default function Mint({setOpenForm}:ToggleFormProp) {
  return (
    <div>
      <Button
        title="Mint Ticket"
        onClick={() => {
          setOpenForm("Mint");
        }}
      />
    </div>
  );
}

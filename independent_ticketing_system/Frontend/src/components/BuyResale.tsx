import { ToggleFormProp } from "../type";
import Button from "./Button";

export default function BuyResale({setOpenForm}:ToggleFormProp) {
  return (
    <Button
      title="Buy Resale ticket"
      onClick={() => {
        setOpenForm("BuyResale")
      }}
    />
  );
}

import { Button } from "@radix-ui/themes";
import { ButtonProps } from "../../type";
import Loading from "./Loading";
export default function myButton({ title, onClick, disabled }: ButtonProps) {
  return (
    <>
      <Button
        disabled={disabled}
        onClick={onClick}
        size={"3"}
        radius="none"
        style={{ cursor: "pointer", minWidth: "15vh", background: "#0101ff" }}
      >
        {disabled && <Loading />}
        {title}
      </Button>
    </>
  );
}

import { Button } from "@radix-ui/themes";
import { ButtonProps } from "../type";
export default function myButton({ title, onClick }: ButtonProps) {
  return (
    <>
      <Button onClick={onClick} size={"3"} style={{cursor:"pointer",minWidth:'18vh'}}>{title}</Button>
    </>
  );
}

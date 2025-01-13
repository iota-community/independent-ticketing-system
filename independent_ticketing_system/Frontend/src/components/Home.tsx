import { Flex, Heading } from "@radix-ui/themes";
import { useState } from "react";
import { OpenFormState } from "../type";
import { operations } from "../constants";
import Button from "./molecules/Button";
import Form from "./Form";
import { useNetworkVariable } from "../networkConfig";
import { useCreateForm } from "../hooks/useCreateForm";
import OwnedObjects from "./OwnedTickets";

export default function Home() {
  const [openForm, setOpenForm] = useState<OpenFormState["openForm"]>("");
  const creator_object = useNetworkVariable("creator_object");
  const { address } = useCreateForm();
  return (
    <Flex direction={"column"} m={"6"} align={"center"}>
      {address ? (
        <>
          <Flex direction={"row"} align={"center"} wrap={"wrap"} gap={"4"}>
            {operations.map(
              (value, index) =>
                ((value.name === "EnableTicketToBuy" &&
                  address &&
                  creator_object == address.address) ||
                  value.name !== "EnableTicketToBuy") && (
                  <Button
                    key={index}
                    title={value.description}
                    onClick={() => {
                      setOpenForm(value.name);
                    }}
                    disabled={false}
                  />
                ),
            )}
          </Flex>
          <OwnedObjects />
        </>
      ) : (
        <Flex justify={"center"} mt={"5"}>
          <Heading align={"center"}>Please connect your wallet first</Heading>
        </Flex>
      )}
      {openForm !== "" && <Form openForm={openForm} />}
    </Flex>
  );
}

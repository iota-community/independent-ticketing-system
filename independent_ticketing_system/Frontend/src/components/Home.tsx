import { Flex, Heading } from "@radix-ui/themes";
import { useEffect, useState } from "react";
import { OpenFormState } from "../type";
import { operations } from "../constants";
import Button from "./molecules/Button";
import Form from "./Form";
import { useCreateForm } from "../hooks/useCreateForm";
import OwnedObjects from "./OwnedTickets";
import { useNetworkVariable } from "../networkConfig";

export default function Home() {
  const [openForm, setOpenForm] = useState<OpenFormState["openForm"]>("");
  const { address } = useCreateForm();
  const creatorCap = useNetworkVariable("creatorCap" as never);
  const [isCreator, setIsCreator] = useState<boolean>(false);
  useEffect(() => {
    const body = {
      jsonrpc: "2.0",
      id: 1,
      method: "iota_getObject",
      params: [creatorCap, { showContent: true }],
    };
    fetch("https://indexer.testnet.iota.cafe/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })
      .then((res) => res.json())
      .then((res) => {
        setIsCreator(address.address == res.result.data.content.fields.address);
      });
  }, [address]);
  return (
    <Flex direction={"column"} m={"6"} align={"center"}>
      {address ? (
        <>
          <Flex direction={"row"} align={"center"} wrap={"wrap"} gap={"4"}>
            {operations.map(
              (value, index) =>
                ((value.name === "EnableTicketToBuy" &&
                  address &&
                  isCreator) ||
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

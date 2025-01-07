import { ConnectButton } from "@iota/dapp-kit";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import Mint from "./components/Mint";
import Transfer from "./components/Transfer";
import Resale from "./components/Resale";
import Burn from "./components/Burn";
import { useState } from "react";
import Form from "./components/Form";
import { OpenFormState } from "./type";
import BuyResale from "./components/BuyResale";

function App() {
  const [openForm, setOpenForm] = useState<OpenFormState["openForm"]>("");
  return (
    <Box>
      <Flex
        position="sticky"
        px="4"
        py="2"
        justify="between"
        align={"center"}
        style={{
          borderBottom: "1px solid var(--gray-a2)",
          background: "#1e2531",
        }}
      >
        <Box>
          <Heading>Independent Ticketing System</Heading>
        </Box>

        <Flex align={"center"}>
          <ConnectButton />
        </Flex>
      </Flex>
      <Flex style={{ marginLeft: "459px" }} align={"center"} m={"6"}>
        <Flex direction={"column"} align={"start"} wrap={"wrap"} gap={"4"}>
          <Mint setOpenForm={setOpenForm} />
          <Transfer setOpenForm={setOpenForm} />
          <Resale setOpenForm={setOpenForm} />
          <Burn setOpenForm={setOpenForm} />
          <BuyResale setOpenForm={setOpenForm} />
        </Flex>
        <Container>{openForm !== "" && <Form openForm={openForm} />}</Container>
      </Flex>
    </Box>
  );
}

export default App;

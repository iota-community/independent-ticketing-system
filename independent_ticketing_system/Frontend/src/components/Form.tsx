import * as Form from "@radix-ui/react-form";
import styles from "../style";
import Button from "./molecules/Button";
import { OpenFormState } from "../type";
import { Box, TextField } from "@radix-ui/themes";
import { useCreateForm } from "../hooks/useCreateForm";
import submitForm from "../utils/submitForm";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

const InputForm = ({ openForm }: { openForm: OpenFormState["openForm"] }) => {
  const {
    packageId,
    eventObject,
    creatorCap,
    signAndExecuteTransaction,
    client,
    formData,
    updateFormData,
    resetFormData,
  } = useCreateForm();
  const [loading,setLoading] = useState<boolean>(false);
  const navigate = useNavigate();
  return (
    <div style={styles.formContainer}>
      <h1 style={{ textAlign: "center" }}>{openForm}</h1>
      <Form.Root style={styles.formRoot}>
        {(openForm === "BuyResell" || openForm === "BuyTicket") && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>IOTA Coin ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                size="2"
                placeholder="0X2::coin::IOTA"
                value={formData.coin}
                onChange={(e) => updateFormData("coin", e.target.value)}
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>Event ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData?.eventId}
                onChange={(e) => updateFormData("eventId", e.target.value)}
                size="2"
                placeholder="event Id"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>Event Date</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.eventdate}
                onChange={(e) => updateFormData("eventdate", e.target.value)}
                size="2"
                placeholder="E.g. 15/01/2025 => 10012025"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>Royalty Percentage</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.royaltyPercentage}
                onChange={(e) =>
                  updateFormData("royaltyPercentage", e.target.value)
                }
                size="2"
                placeholder="E.g. 2 => 2%"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>Price</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.price}
                onChange={(e) => updateFormData("price", e.target.value)}
                size="2"
                placeholder="Price"
              />
            </Form.Control>
          </Form.Field>
        )}

        {(openForm === "Transfer" ||
          openForm === "Resell" ||
          openForm === "Burn" || openForm === "EnableTicketToBuy" || openForm === "WhiteListBuyer") && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>NFT ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.nft}
                onChange={(e) => updateFormData("nft", e.target.value)}
                size="2"
                placeholder="NFT Id"
              />
            </Form.Control>
          </Form.Field>
        )}

        {(openForm === "Transfer" || openForm === "Resell" || openForm === "WhiteListBuyer") && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>Recipient</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.recipient}
                onChange={(e) => updateFormData("recipient", e.target.value)}
                size="2"
                placeholder="Recipient address"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "BuyResell" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>
              Initiated Resell ID
            </Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.initiatedResell}
                onChange={(e) =>
                  updateFormData("initiatedResell", e.target.value)
                }
                size="2"
                placeholder="Initialed Resell"
              />
            </Form.Control>
          </Form.Field>
        )}
        {openForm === "BuyTicket" && (
          <Form.Field name="" style={styles.formField}>
            <Form.Label style={styles.formLabel}>
              Seat Number
            </Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.seatNumber}
                onChange={(e) =>
                  updateFormData("seatNumber", e.target.value)
                }
                size="2"
                placeholder="Seat Number"
              />
            </Form.Control>
          </Form.Field>
        )}
        <Box style={{ display: "flex", justifyContent: "center" }}>
          <Button
            disabled={loading}
            onClick={(e) => {
              setLoading(true);
              submitForm(
                e,
                openForm,
                formData,
                resetFormData,
                packageId,
                eventObject,
                creatorCap,
                signAndExecuteTransaction,
                client,
                navigate,
                setLoading
              )
            }}
            title={"Submit"}
          />
        </Box>
      </Form.Root>
    </div>
  );
};

export default InputForm;

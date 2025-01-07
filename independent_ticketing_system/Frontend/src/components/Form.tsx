import * as Form from "@radix-ui/react-form";
import styles from "../style";
import Button from "./Button";
import { OpenFormState } from "../type";
import { TextField } from "@radix-ui/themes";
import { useCreateForm } from "../hooks/useCreateForm";
import submitForm from "../utils/submitForm";

const InputForm = ({ openForm }: { openForm: OpenFormState["openForm"] }) => {
  const {packageId,
    address,
    signAndExecuteTransaction,
    client,
    formData,
    updateFormData,
    resetFormData} = useCreateForm();
  return (
    <div style={styles.formContainer}>
      <h1 style={{ textAlign: "center" }}>{openForm}</h1>
      <Form.Root style={styles.formRoot}>
        {(openForm === "Mint" || openForm === "BuyResale") && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>IOTA Coin ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                size="2"
                placeholder="0X2::coin::IOTA"
                value={formData.coin}
                onChange={e => updateFormData("coin",e.target.value)}
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Event ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData?.eventId}
                onChange={e => updateFormData("eventId",e.target.value)}
                size="2"
                placeholder="event Id"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Event Date</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.eventdate}
                onChange={e => updateFormData("eventdate",e.target.value)}
                size="2"
                placeholder="Event Date"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Royalty Percentage</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.royaltyPercentage}
                onChange={e => updateFormData("royaltyPercentage",e.target.value)}
                size="2"
                placeholder="E.g. 2"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Package Creator</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.packageCreator}
                onChange={e => updateFormData("packageCreator",e.target.value)}
                size="2"
                placeholder="Package Creator"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>
              Total Seat Object Id
            </Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.totalSeat}
                onChange={e => updateFormData("totalSeat",e.target.value)}
                size="2"
                placeholder="Total Seat"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "Mint" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Price</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.price}
                onChange={e => updateFormData("price",e.target.value)}
                size="2"
                placeholder="Price"
              />
            </Form.Control>
          </Form.Field>
        )}

        {(openForm === "Transfer" ||
          openForm === "Resale" ||
          openForm === "Burn") && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>NFT ID</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.nft}
                onChange={e => updateFormData("nft",e.target.value)}
                size="2"
                placeholder="NFT Id"
              />
            </Form.Control>
          </Form.Field>
        )}

        {(openForm === "Transfer" || openForm === "Resale") && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>Recipient</Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.recipient}
                onChange={e => updateFormData("recipient",e.target.value)}
                size="2"
                placeholder="Recipient address"
              />
            </Form.Control>
          </Form.Field>
        )}

        {openForm === "BuyResale" && (
          <Form.Field style={styles.formField}>
            <Form.Label style={styles.formLabel}>
              Initiated Resale ID
            </Form.Label>
            <Form.Control asChild>
              <TextField.Root
                value={formData.initiatedResale}
                onChange={e => updateFormData("initiatedResale",e.target.value)}
                size="2"
                placeholder="Initialed Resale"
              />
            </Form.Control>
          </Form.Field>
        )}
        <Button onClick={(e) => submitForm(e,openForm,formData,resetFormData,packageId,address.address,signAndExecuteTransaction,client)} title={"Submit"} />
      </Form.Root>
    </div>
  );
};

export default InputForm;

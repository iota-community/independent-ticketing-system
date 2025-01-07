export interface ButtonProps {
    title:string,
    onClick: () => void
}

export interface ToggleFormProp {
    setOpenForm: React.Dispatch<React.SetStateAction<OpenFormState["openForm"]>>
}

export interface OpenFormState {
    openForm: "Mint" | "Burn" | "Transfer" | "Resale" | "BuyResale" | "";
}

export interface formDataType {
    coin?:string,
    eventId?:string,
    eventdate?:string,
    royaltyPercentage?:string,
    packageCreator?:string,
    totalSeat?:string,
    price?:string,
    nft?:string,
    recipient?:string,
    initiatedResale?:string
}
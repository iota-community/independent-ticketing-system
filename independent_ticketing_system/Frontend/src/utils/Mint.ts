import { Transaction } from "@iota/iota-sdk/transactions";
import { formDataType } from "../type";
import { IotaClient } from "@iota/iota-sdk/client";

export const mint_Ticket =  (
    formData:formDataType,
    setFormData:React.Dispatch<React.SetStateAction<formDataType>>,
    packageId:any,
    accountAddress:string,
    signAndExecuteTransaction: any,
    client: IotaClient,

) => {
    const tx = () => {
        const tx = new Transaction();
        tx.setGasBudget(50000000)
        tx.moveCall({
            target: `${packageId}::independent_ticketing_system_nft::mint_ticket`,
            arguments: [
                tx.object(formData.coin as string), 
                tx.pure.address(accountAddress), 
                tx.pure.string(formData.eventId as string),
                tx.pure.u64(formData.eventdate as string),
                tx.pure.u64(formData.royaltyPercentage as string),
                tx.object(formData.packageCreator as string),
                tx.object(formData.totalSeat as string),
                tx.pure.u64(formData.price as string)
            ],
        });
        return tx;
    }
    signAndExecuteTransaction(
        {
            transaction: tx(),
        },
        {
            onSuccess: ({ digest }:{digest:any}) => {
                client.waitForTransaction({ digest, options: { showEffects: true } }).then(() => {
                    setFormData({
                        coin:'',
                        eventId:'',
                        eventdate:'',
                        royaltyPercentage:'',
                        packageCreator:'',
                        totalSeat:'',
                        price:'',
                        nft:'',
                        recipient:'',
                        initiatedResale:''
                    })
                    alert("Transaction successfull!")
                });
            },
            onError: (error: any) => {
                console.error('Failed to execute transaction', tx, error);
            },
        },
    )
}
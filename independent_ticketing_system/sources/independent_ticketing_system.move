module independent_ticketing_system::independent_ticketing_system_nft {
    use std::string;
    use iota::coin::{Coin};
    use iota::iota::IOTA; 

    public struct TicketNFT has key, store {
        id: UID,
        name: string::String,
        creator: address,
        owner: address,
        event_id: string::String,
        seat_number: u64,
        event_date: u64,
        royalty_percentage: u64,
        price: u64,
        whitelisted_addresses: vector<address>
    }

    public struct Creator has key, store{
        id:UID,
        address: address
    }

    public struct TotalSeat has key, store{
        id: UID,
        value: u64
    }

    public struct InitiateResale has key, store {
        id: UID,
        nft:TicketNFT,
        seller:address,
        buyer:address,
        price:u64,
    }

    public struct AvailableTicketsToBuy has key {
        id: UID,
        nfts: vector<TicketNFT>
    }

    // Error codes
    #[error]
    const NOT_ENOUGH_FUNDS: vector<u8> = b"Insufficient funds for gas and NFT transfer";
    #[error]
    const INVALID_ROYALTY: vector<u8> = b"Royalty percentage must be between 0 and 100";
    #[error]
    const NOT_CREATOR: vector<u8> = b"Only owner can mint new tickets";
    #[error]
    const NOT_OWNER: vector<u8> = b"Sender is not owner";
    #[error]
    const ALL_TICKETS_SOLD: vector<u8> = b"All tickets has been sold out";
    #[error]
    const NOT_BUYER: vector<u8> = b"Sender is not buyer";
    #[error]
    const NOT_AUTHORISED_TO_BUY: vector<u8> = b"Recipient is not whitelisted";
    #[error]
    const NOT_AVAILABLE_TO_BUY: vector<u8> = b"TICKET is not available to buy";

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Creator{
            id: object::new(ctx),
            address:tx_context::sender(ctx)
        });
        transfer::share_object(TotalSeat {
            id: object::new(ctx),
            value: 300
        });

        transfer::share_object(AvailableTicketsToBuy {
            id: object::new(ctx),
            nfts : vector::empty<TicketNFT>()
        });
    }

    public entry fun mint_ticket(
        coin: &mut Coin<IOTA>,
        event_id: string::String,
        event_date: u64,
        royalty_percentage: u64,
        package_creator: &mut Creator,
        total_seat: &mut TotalSeat,
        available_tickets: &mut AvailableTicketsToBuy,
        price: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        assert!(sender==package_creator.address,NOT_CREATOR);
        assert!(total_seat.value>0,ALL_TICKETS_SOLD);
        assert!(royalty_percentage >= 0 && royalty_percentage <= 100, INVALID_ROYALTY);

        let bal_value = coin.value();
        assert!(bal_value >= 1, NOT_ENOUGH_FUNDS);

        let name: string::String = string::utf8(b"Event Ticket NFT");

        let nft_count = total_seat.value;

        let nft = TicketNFT {
            id: object::new(ctx),
            name,
            creator: sender,
            owner: sender,
            event_id,
            seat_number:total_seat.value,
            event_date,
            royalty_percentage,
            price,
            whitelisted_addresses: vector::empty<address>()
        };

        set_total_seat(nft_count-1,total_seat);

        vector::push_back(&mut available_tickets.nfts, nft);
    }

    public entry fun transfer_ticket(
        mut nft: TicketNFT,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(sender == nft.owner, NOT_OWNER);

        nft.owner = recipient;
        transfer::public_transfer(nft, recipient);
    }

    #[allow(unused_variable)]
    public entry fun resale(
        nft: TicketNFT,
        recipient:address,
        ctx: &mut TxContext
        ) {

        let sender = tx_context::sender(ctx);
        assert!(sender == nft.owner, NOT_OWNER);
        assert!(vector::contains(&nft.whitelisted_addresses, &recipient),NOT_AUTHORISED_TO_BUY);

        let initiate_resale = InitiateResale {
            id: object::new(ctx),
            seller:sender,
            buyer:recipient,
            price:nft.price,
            nft
        };
        transfer::public_transfer(initiate_resale,recipient);
    }

    #[allow(lint(self_transfer))]
    public fun buy_ticket(coin: &mut Coin<IOTA>, 
    nft_id: &mut UID,
    buyable_tickets: &mut AvailableTicketsToBuy,
    creator: &mut Creator, 
    ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let nfts = &buyable_tickets.nfts;
        let length = vector::length(nfts);
        let mut i = 0;
        while (i < length) {
            let nft = &nfts[i];
            if (&nft.id == nft_id) {
                let deleted_nft = vector::remove(&mut buyable_tickets.nfts, i);
                let TicketNFT { id,
                    name,
                    creator,
                    owner,
                    event_id,
                    seat_number,
                    event_date,
                    royalty_percentage,
                    price,
                    whitelisted_addresses } = deleted_nft;
                assert!(vector::contains(&whitelisted_addresses, &sender),NOT_AUTHORISED_TO_BUY);

                let new_coins = coin.split(nft.price,ctx);

                transfer::public_transfer(new_coins,nft.creator);

                transfer::public_transfer(TicketNFT {
                    id,
                    name,
                    creator,
                    owner,
                    event_id,
                    seat_number,
                    event_date,
                    royalty_percentage,
                    price,
                    whitelisted_addresses
                },sender);
                break
            };
            i = i + 1;
        };
    }

    #[allow(lint(self_transfer))]
    public entry fun buy_resale(coin: &mut Coin<IOTA>, initiated_resale: InitiateResale,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let InitiateResale {id: id1,seller: seller1,buyer: buyer1,price: price1,nft: mut nft1} = initiated_resale;
        
        assert!(sender==buyer1,NOT_BUYER);

        let royalty_fee = (nft1.royalty_percentage/nft1.price)*100;
        assert!(coin.balance().value()>royalty_fee,NOT_ENOUGH_FUNDS);

        let new_coin = coin.split(royalty_fee, ctx);
        transfer::public_transfer(new_coin,nft1.creator);
        
        nft1.owner = sender;
        transfer::public_transfer(nft1,sender);

        let new_coin = coin.split(price1,ctx);

        transfer::public_transfer(new_coin,seller1);
        object::delete(id1);
    }

    #[allow(unused_variable)]
    public entry fun burn(nft: TicketNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender == nft.owner, NOT_OWNER);

        let TicketNFT { id,
            name,
            creator,
            owner,
            event_id,
            seat_number,
            event_date,
            royalty_percentage,
            price,
            whitelisted_addresses } = nft;
        object::delete(id);
    }

    fun set_total_seat(value:u64,total_seat: &mut TotalSeat) {
        total_seat.value = value;
    }

    #[allow(unused_variable)]
    public entry fun whitelist_buyer(user:address,nft: &mut TicketNFT) {
        vector::push_back(&mut nft.whitelisted_addresses,user);
    }

    // Just for testing purpose
    public fun create_TicketNFT(
        name: string::String,
        creator: address,
        owner: address, 
        event_id: string::String,
        seat_number: u64,
        event_date: u64,
        royalty_percentage: u64,
        price:u64,
        whitelisted_addresses: vector<address>,
        ctx: &mut TxContext
        ) : TicketNFT {
        let nft : TicketNFT = TicketNFT {
            id:object::new(ctx),
            name,
            creator,
            owner,
            event_id,
            seat_number,
            event_date,
            royalty_percentage,
            price,
            whitelisted_addresses
        };
        nft
    }

    #[allow(unused_let_mut)]
    public fun create_TotalSeat(value:u64,ctx: &mut TxContext) : TotalSeat {
        let mut total_seat = TotalSeat {
            id:object::new(ctx),
            value
        };
        total_seat
    }
}
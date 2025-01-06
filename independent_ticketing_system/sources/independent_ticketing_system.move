module independent_ticketing_system::independent_ticketing_system_nft {
    use std::string;
    use iota::event;
    use iota::coin::{Coin};
    use iota::iota::IOTA; 

    /// A struct representing a ticket NFT with detailed metadata
    public struct TicketNFT has key, store {
        id: UID,                       // Unique ID for the ticket NFT
        name: string::String,          // Name of the ticket NFT
        creator: address,              // Address of the ticket creator
        owner: address,                // Address of the current ticket owner
        event_id: string::String,      // Unique identifier for the event
        seat_number: u64,   // Seat number assigned to the ticket
        event_date: u64,               // Event date in Unix timestamp format
        royalty_percentage: u64,      // Optional royalty percentage for the creator (0-100)
        price: u64,
        whitelisted_addresses: vector<address>
    }

    // A struct representing the creator of package
    public struct Creator has key, store{
        id:UID,
        address: address
    }

    // A struct representing the total number of seats
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

    // ===== Events =====

    /// Event emitted when a new ticket NFT is minted
    public struct NFTMinted has copy, drop {
        object_id: ID,                // The Object ID of the NFT
        creator: address,             // Address of the creator
        owner: address,               // Address of the owner
        name: string::String,         // Name of the NFT
        event_id: string::String,     // Event ID for the ticket
        seat_number: u64,             // Seat number for the ticket
        event_date: u64,              // Event date like 31122024 i.e 31/12/2024
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
    const INVALID_NFT: vector<u8> = b"NFT has not any initiated resale";
    #[error]
    const NOT_BUYER: vector<u8> = b"Sender is not buyer";
    #[error]
    const USER_NOT_WHITELISTED: vector<u8> = b"Recipient is not whitelisted";

    // ==== Initializer function ====

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Creator{
            id: object::new(ctx),
            address:tx_context::sender(ctx)
        });
        transfer::share_object(TotalSeat {
            id: object::new(ctx),
            value: 300
        });
    }

    // ===== Public view functions =====

    // ===== Entrypoints =====

   /// Mint a new ticket NFT with metadata, requiring 1 gas token for the creator
    public fun mint_ticket(
        coin: &mut Coin<IOTA>,
        owner: address,
        event_id: string::String,
        event_date: u64,
        royalty_percentage: u64,
        package_creator: address,
        total_seat: &mut TotalSeat,
        price: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        assert!(sender==package_creator,NOT_CREATOR);

        assert!(total_seat.value>0,ALL_TICKETS_SOLD);

        // Royalty percentage validation
        assert!(royalty_percentage >= 0 && royalty_percentage <= 100, INVALID_ROYALTY);

        // Check that the coin balance is sufficient (>= 1 IOTA)
        // let coin_balance = coin::balance(coin);
        let bal_value = coin.value();
        assert!(bal_value >= 1, NOT_ENOUGH_FUNDS);

        let name: string::String = string::utf8(b"Event Ticket NFT");

        let nft_count = total_seat.value;

        let nft = TicketNFT {
            id: object::new(ctx),
            name,
            creator: sender,
            owner,
            event_id,
            seat_number:total_seat.value,
            event_date,
            royalty_percentage,
            price,
            whitelisted_addresses: vector::empty<address>()
        };

        set_total_seat(nft_count-1,total_seat);

        // Extract the object ID before moving the `nft`
        let nft_id = object::id(&nft);

        // Split the coin into two parts
        let new_coin = coin.split(1, ctx);
        // Transfer 1 IOTA to the creator
        transfer::public_transfer(new_coin, package_creator);

        // Transfer NFT to owner
        transfer::public_transfer(nft, owner);
        // Emit event using the extracted ID
        event::emit(NFTMinted {
            object_id: nft_id,
            creator: sender,
            owner,
            name,
            event_id,
            seat_number:nft_count,
            event_date,
        });
    }

    /// Transfer `nft` to `recipient`
    public fun transfer_ticket(
        nft: TicketNFT,
        recipient: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(sender == nft.owner, NOT_OWNER);

        // Check if the ticket has already been transferred (prevent double transfers)
        // You'll need a way to track this, e.g., a boolean field in TicketNFT or a separate data structure.
        // Example (using a hypothetical `is_transferred` field):
        // assert!(!nft.is_transferred, INVALID_STATE);

        transfer::public_transfer(nft, recipient);

        // Update the ticket's state to indicate it has been transferred
        // (If you add the `is_transferred` field)
        // nft.is_transferred = true;
    }

    public fun resale(
        coin: &mut Coin<IOTA>,
        nft: TicketNFT,
        recipient:address,
        ctx: &mut TxContext
        ) {

        let sender = tx_context::sender(ctx);
        let creator = nft.creator;
        assert!(sender == nft.owner, NOT_OWNER);
        assert!(vector::contains(nft.whitelisted_addresses, recipient),USER_NOT_WHITELISTED);
        let new_coin = coin.split(royalty_fee, ctx);
        transfer::public_transfer(new_coin,creator);

        let initiate_resale = InitiateResale {
            id: object::new(ctx),
            seller:sender,
            buyer:recipient,
            price:nft.price,
            nft,
        };
        transfer::public_transfer(initiate_resale,recipient);
    }

    #[allow(lint(self_transfer))]
    public fun buy(coin: &mut Coin<IOTA>,nft:TicketNFT, initiated_resale: &mut InitiateResale,ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(nft.owner==initiated_resale.seller,INVALID_NFT);
        assert!(sender==initiated_resale.buyer,NOT_BUYER);
        assert!(coin.balance().value()>initiated_resale.price);

        initiated_resale.nft.owner = sender;
        transfer::public_transfer(nft,sender);

        let new_coin = coin.split(initiated_resale.price,ctx);

        transfer::public_transfer(new_coin,initiated_resale.seller);
    }

    #[allow(unused_variable)]
    /// Permanently delete `nft`
    public fun burn(nft: TicketNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender == nft.owner, NOT_OWNER); // Only owner can burn

        let TicketNFT { id,
            name,
            creator,
            owner,
            event_id,
            seat_number,
            event_date,
            royalty_percentage,
            price } = nft;
        object::delete(id);
    }

    // ==== Private functions ====

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
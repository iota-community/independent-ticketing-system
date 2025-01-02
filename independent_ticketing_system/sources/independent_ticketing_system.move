module independent_ticketing_system::independent_ticketing_system_nft {
    use std::string;
    use iota::event;
    use iota::coin::{Self, Coin};
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
        royalty_percentage: u8,      // Optional royalty percentage for the creator (0-100)
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

    /// Event emitted when a ticket is resold
    public struct TicketResold has copy, drop {
        nft_id: ID,                  // The Object ID of the resold NFT
        old_owner: address,           // Address of the previous owner
        new_owner: address,           // Address of the new owner
        price: u64,                   // Resale price of the ticket
    }

    // Error codes
    #[error]
     const NOT_ENOUGH_FUNDS: vector<u8> = b"Insufficient funds for gas and NFT transfer";
    #[error]
    const INVALID_ROYALTY: vector<u8> = b"Royalty percentage must be between 0 and 100";
    #[error]
    const INVALID_STATE: vector<u8> = b"Ticket already transferred";
    #[error]
     const NOT_CREATOR: vector<u8> = b"Only owner can mint new tickets";
    #[error]
     const NOT_OWNER: vector<u8> = b"Sender is not owner";

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

    /// Get the ticket NFT's `name`
    public fun name(nft: &TicketNFT): &string::String {
        &nft.name
    }

    // ===== Entrypoints =====

   /// Mint a new ticket NFT with metadata, requiring 1 gas token for the creator
    public fun mint_ticket(
        coin: &mut Coin<IOTA>,
        owner: address,
        event_id: string::String,
        seat_number: u64,
        event_date: u64,
        royalty_percentage: u8,
        package_creator: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        // Royalty percentage validation
        assert!(royalty_percentage <= 100, INVALID_ROYALTY);

        // Check that the coin balance is sufficient (>= 1 IOTA)
        let coin_balance = coin::balance(coin);
        let bal_value = coin_balance.value();
        assert!(bal_value >= 1, NOT_ENOUGH_FUNDS);

        let name: string::String = string::utf8(b"Event Ticket NFT");

        let nft = TicketNFT {
            id: object::new(ctx),
            name,
            creator: sender,
            owner,
            event_id,
            seat_number,
            event_date,
            royalty_percentage,
        };

        // Extract the object ID before moving the `nft`
        let nft_id = object::id(&nft);

        // Split the coin into two parts
        let new_coin = coin::split(coin, 1, ctx);
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
            seat_number,
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
        royalty_fee:u64,
        coin: &mut Coin<IOTA>,
        nft: TicketNFT,
        recipient:address,
        ctx: &mut TxContext
        ) {

        let sender = tx_context::sender(ctx);
        let creator = nft.creator;
        assert!(sender == nft.owner, NOT_OWNER);
        transfer::public_transfer(nft, recipient);

        if(royalty_fee>0) {
            let new_coin = coin::split(coin, royalty_fee, ctx);
            transfer::public_transfer(new_coin,creator);
        }
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
            royalty_percentage } = nft;
        object::delete(id);
    }

    // ==== Private functions ====

    fun set_total_seat(value:u64,total_seat: &mut TotalSeat) {
        total_seat.value = value;
    }
}
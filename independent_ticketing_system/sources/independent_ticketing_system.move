module independent_ticketing_system::independent_ticketing_system_nft {
    use iota::object::{UID, ID};
    use iota::tx_context::{Self, TxContext};
    use iota::object;
    use std::string;
    use iota::event;
    use iota::transfer;
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
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);

    // Royalty percentage validation
    assert!(royalty_percentage <= 100, INVALID_ROYALTY);

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

    // Split the coin into two parts
    let new_coin = coin::split(coin, 1, ctx);
    // Transfer 1 SUI to the creator
    iota::transfer::public_transfer(new_coin, CREATOR);

    // Transfer NFT to owner
    transfer::public_transfer(nft, owner);

    event::emit(NFTMinted {
        object_id: object::id(&nft),
        creator: sender,
        owner,
        name: nft.name,
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

    // ===== Constants =====

    /// The address of the package creator (receives gas fees)
    const CREATOR: address = @0x9381dc2d654d2d1bf401be954a8ffa20d794acaa13bb00d6eb4f2851d3239e43;
}
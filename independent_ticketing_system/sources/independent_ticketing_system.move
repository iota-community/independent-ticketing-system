module independent_ticketing_system::independent_ticketing_system_nft {
    use iota::object::{UID, ID};
    use iota::tx_context::{Self, TxContext};
    use iota::object;
    use std::string;
    use iota::event;
    use iota::transfer;

    /// A struct representing a ticket NFT with detailed metadata
    public struct TicketNFT has key, store {
        id: UID,                       // Unique ID for the ticket NFT
        name: string::String,          // Name of the ticket NFT
        creator: address,              // Address of the ticket creator
        owner: address,                // Address of the current ticket owner
        event_id: string::String,      // Unique identifier for the event
        seat_number: u64,   // Seat number assigned to the ticket
        event_date: u64,               // Event date in Unix timestamp format
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

    // error codes
    #[error]
     const NOT_CREATOR: vector<u8> = b"Only owner can mint new tickets";
    #[error]
     const NOT_OWNER: vector<u8> = b"Sender is not owner";

    // ===== Constants =====
   
    /// The address of the package creator (only creator can mint tickets)
    const CREATOR: address = @0x9381dc2d654d2d1bf401be954a8ffa20d794acaa13bb00d6eb4f2851d3239e43;

    // ===== Public view functions =====

    /// Get the ticket NFT's `name`
    public fun name(nft: &TicketNFT): &string::String {
        &nft.name
    }

    // ===== Entrypoints =====

    /// Mint a new ticket NFT with metadata
    public fun mint_ticket(
        owner: address,
        event_id: string::String,
        seat_number: u64,
        event_date: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // Ensure only the CREATOR can mint tickets
        assert!(sender == CREATOR, NOT_CREATOR); 

        let name: string::String = string::utf8(b"Event Ticket NFT");

        let nft = TicketNFT {
            id: object::new(ctx),
            name,
            creator: sender,
            owner,
            event_id,
            seat_number,
            event_date,
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            owner,
            name: nft.name,
            event_id,
            seat_number,
            event_date,
        });

        transfer::public_transfer(nft, owner);
    }

    // Transfer `nft` to `recipient`
    public fun transfer_ticket(
        nft: TicketNFT,
        recipient: address,
        ctx: &mut TxContext

    ) {
        let sender = tx_context::sender(ctx);
         assert!(sender == nft.owner, NOT_OWNER);
        transfer::public_transfer(nft, recipient);
    }

    #[allow(unused_variable)]       
    /// Permanently delete `nft`
    public fun burn(nft: TicketNFT, _: &mut TxContext) {
        let TicketNFT { id,
            name,
            creator,
            owner,
            event_id,
            seat_number,
            event_date, } = nft;
        object::delete(id);
    }

}

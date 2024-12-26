/// Module: independent_ticketing_system
module independent_ticketing_system::independent_ticketing_system_nft {
    use iota::object::{UID, ID};
    use iota::tx_context::{Self, TxContext};
    use iota::object;
    use std::string;
    use iota::event;
    use iota::transfer;

    /// An example NFT that can be minted by anybody
    public struct TicketNFT has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        creator: address,
        owner :address,
    }

    // ===== Events =====

    public struct NFTMinted has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The creator of the NFT
        owner :address,
        // The name of the NFT
        name: string::String,
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &TicketNFT): &string::String {
        &nft.name
    }

    // ===== Entrypoints =====

    #[allow(lint(self_transfer))]
	/// Anyone can mint a new NFT on this one
    public fun mint_ticket(
        name: vector<u8>,
        owner: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let nft = TicketNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            creator:sender,
            owner:owner
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
            owner:owner
        });

        transfer::public_transfer(nft, owner);
    }

    // Transfer `nft` to `recipient`
    public fun transfer_ticket(
        nft: TicketNFT,
        recipient: address
    ) {
        transfer::public_transfer(nft, recipient);
    }

}



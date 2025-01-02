#[test_only]
module independent_ticketing_system::independent_ticketing_system_nft_test {
    use std::string;
    use iota :: {
        kiosk_test_utils,
        test_scenario::{Self as ts}
    };
    use independent_ticketing_system :: independent_ticketing_system_nft :: {
        mint_ticket,
        resale,
        create_TicketNFT,
        burn,
        transfer_ticket,
        create_TotalSeat
    };
    const CREATOR: address = @0xCCCC;
    const BUYER: address = @0xBBBB;

    #[test]
    fun test_mint_ticket() {
        let mut ts = ts::begin(CREATOR);
        let payment = kiosk_test_utils::get_iota(1, ts.ctx());
        let total_seat = create_TotalSeat(1,ts.ctx());
        mint_ticket(payment,CREATOR,string::utf8(b"testing@123"),3012025,5,CREATOR,total_seat,ts.ctx());
        ts.end();
    }
    #[test]
    fun test_resale() {
        let mut ts = ts::begin(CREATOR);
        let payment = kiosk_test_utils::get_iota(1, ts.ctx());
        let nft = create_TicketNFT(
            string::utf8(b"MyNFT"),
            CREATOR,
            CREATOR,
            string::utf8(b"testing@123"),
            5,
            3012025,
            5,
            ts.ctx()
        );
        resale(1,payment,nft,BUYER,ts.ctx());
        ts.end();
    }
    #[test]
    fun test_burn() {
        let mut ts = ts::begin(CREATOR);
        let nft = create_TicketNFT(
            string::utf8(b"MyNFT"),
            CREATOR,
            CREATOR,
            string::utf8(b"testing@123"),
            5,
            3012025,
            5,
            ts.ctx()
        );
        burn(nft,ts.ctx());
        ts.end();
    }

    #[test]
    fun test_transfer_ticket() {
        let mut ts = ts::begin(CREATOR);
        let nft = create_TicketNFT(
            string::utf8(b"MyNFT"),
            CREATOR,
            CREATOR,
            string::utf8(b"testing@123"),
            5,
            3012025,
            5,
            ts.ctx()
        );
        transfer_ticket(nft,BUYER,ts.ctx());
        ts.end();
    }
}
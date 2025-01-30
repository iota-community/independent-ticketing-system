#[test_only]
module independent_ticketing_system::independent_ticketing_system_nft_test {
    use std::string;
    use iota::coin;
    use iota::iota::IOTA;
    use iota::test_scenario::{Self, Scenario};
    use independent_ticketing_system :: independent_ticketing_system_nft :: {
        Creator,
        TotalSeat,
        AvailableTicketsToBuy,
        TicketNFT,
        InitiateResale,
        mint_ticket,
        resale,
        burn,
        transfer_ticket,
        test_init,
        whitelist_buyer,
        enable_ticket_to_buy,
        buy_ticket,
        buy_resale
    };

    const CREATOR: address = @0xCCCC;
    const BUYER1: address = @0xBBBB;
    const BUYER2:address = @0xAAAA;

    #[test]
    fun test_mint_ticket() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);

        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);

        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);
        
        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());

        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::end(scenario);
    }
    #[test]
    fun test_resale() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);

        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);

        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);

        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());
        
        test_scenario::next_tx(test,CREATOR);
        let ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,CREATOR);
        transfer_ticket(ticket,BUYER1,test_scenario::ctx(test));
        
        test_scenario::next_tx(test,BUYER1);
        let mut ticket2 = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,BUYER1);
        whitelist_buyer(BUYER2,&mut ticket2);
        
        test_scenario::next_tx(test,BUYER1);
        resale(ticket2,500,BUYER2,test_scenario::ctx(test));
        
        test_scenario::next_tx(test,BUYER2);
        let initiated_resale = test_scenario::take_from_sender<InitiateResale>(test);
        
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,initiated_resale);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = iota::test_scenario::EEmptyInventory)]
    fun test_burn() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);
        
        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);
        
        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);
        
        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());
        
        test_scenario::next_tx(test,CREATOR);
        let ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,CREATOR);
        burn(ticket,test_scenario::ctx(test));
        
        test_scenario::next_tx(test,CREATOR);
        let ticket2 = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,ticket2);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_ticket() {  
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);
        
        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);
        
        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);
        
        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());
        
        test_scenario::next_tx(test,CREATOR);
        let ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,CREATOR);
        transfer_ticket(ticket,BUYER1,test_scenario::ctx(test));
        
        test_scenario::next_tx(test,BUYER1);
        let ticket2 = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,ticket2);
        test_scenario::end(scenario);
        
    }

    #[test]
    #[expected_failure(abort_code = iota::test_scenario::EEmptyInventory)]
    fun test_enable_ticket_to_buy() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);
        
        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);
        
        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);
        
        test_scenario::next_tx(test,CREATOR);
        let mut available_tickets = test_scenario::take_shared<AvailableTicketsToBuy>(test);
        
        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());
        
        test_scenario::next_tx(test,CREATOR);
        let ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,CREATOR);
        enable_ticket_to_buy(ticket,&mut creator,&mut available_tickets,test_scenario::ctx(test));
        
        test_scenario::next_tx(test,BUYER1);
        let ticket2 = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<AvailableTicketsToBuy>(available_tickets);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,ticket2);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_buy_ticket() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);

        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);

        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);

        test_scenario::next_tx(test,CREATOR);
        let mut available_tickets = test_scenario::take_shared<AvailableTicketsToBuy>(test);

        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());

        test_scenario::next_tx(test,CREATOR);
        let mut ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        whitelist_buyer(BUYER1, &mut ticket);
        test_scenario::next_tx(test,CREATOR);

        enable_ticket_to_buy(ticket,&mut creator,&mut available_tickets,test_scenario::ctx(test));
        test_scenario::next_tx(test,BUYER1);
        
        let mut new_coin = coin::mint_for_testing<IOTA>(500,test_scenario::ctx(test));
        test_scenario::next_tx(test,BUYER1);
        buy_ticket(&mut new_coin,300,&mut available_tickets,test_scenario::ctx(test));
        test_scenario::next_tx(test,BUYER1);
        let ticket2 = test_scenario::take_from_sender<TicketNFT>(test);

        new_coin.burn_for_testing();
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<AvailableTicketsToBuy>(available_tickets);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,ticket2);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_buy_resale() { //fdsdfads
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);

        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);

        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);

        test_scenario::next_tx(test,CREATOR);
        let available_tickets = test_scenario::take_shared<AvailableTicketsToBuy>(test);

        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());

        test_scenario::next_tx(test,CREATOR);
        let ticket = test_scenario::take_from_sender<TicketNFT>(test);

        test_scenario::next_tx(test,CREATOR);
        transfer_ticket(ticket,BUYER1,test_scenario::ctx(test));

        test_scenario::next_tx(test,BUYER1);
        let mut ticket2 = test_scenario::take_from_sender<TicketNFT>(test);
        
        test_scenario::next_tx(test,BUYER1);
        whitelist_buyer(BUYER2, &mut ticket2);

        test_scenario::next_tx(test,BUYER1);
        resale(ticket2,500,BUYER2,test_scenario::ctx(test));

        test_scenario::next_tx(test,BUYER2);
        let initiated_resale = test_scenario::take_from_sender<InitiateResale>(test);

        let mut new_coin = coin::mint_for_testing<IOTA>(500,test_scenario::ctx(test));

        test_scenario::next_tx(test,BUYER2);
        buy_resale(&mut new_coin,initiated_resale, test_scenario::ctx(test));

        new_coin.burn_for_testing();
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<AvailableTicketsToBuy>(available_tickets);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_whitelist_buyer() {
        let mut scenario = test_scenario::begin(CREATOR);
        let test = &mut scenario;
        initialize(test, CREATOR);

        test_scenario::next_tx(test,CREATOR);
        let mut creator = test_scenario::take_shared<Creator>(test);
        
        test_scenario::next_tx(test,CREATOR);
        let mut total_seat = test_scenario::take_shared<TotalSeat>(test);
        
        test_scenario::next_tx(test,CREATOR);
        mint_ticket(string::utf8(b"testing@123"),3012025,5,&mut creator,&mut total_seat,200,test.ctx());
        
        test_scenario::next_tx(test,CREATOR);
        let mut ticket = test_scenario::take_from_sender<TicketNFT>(test);
        
        whitelist_buyer(BUYER1,&mut ticket);
        test_scenario::return_shared<Creator>(creator);
        test_scenario::return_shared<TotalSeat>(total_seat);
        test_scenario::return_to_sender(test,ticket);

        test_scenario::end(scenario);
    }

    fun initialize(scenario: &mut Scenario, admin: address) {
        test_scenario::next_tx(scenario, admin);
        {
            test_init(test_scenario::ctx(scenario));
        };
    }
}
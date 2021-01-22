var barTemplate = Handlebars.getTemplate('bar-template');
var footerTemplate = Handlebars.getTemplate('footer-template');
var personTemplate = Handlebars.getTemplate('person-template');

function Person (address, ether, beertokens, pendingBeertokens) {
    this.address = address;
    this.ether = ether;
    this.beertokens = beertokens;
    this.pendingBeertokens = pendingBeertokens;
    this.addressShort = this.address.substring(0, 7);
}

var beerAddress;
var fizzBuzzContractInstance;
var beerTokenContractInstance;

var showError = function(error, result){
    if(!error) {
        $.notify('Transaction sent: ' + JSON.stringify(result));
    }
    else {
        $.notify({message: '<strong>Error:</strong> ' + error},{type: 'danger'});
    }
};

function getPerson(person_address) {
    var ether = web3.fromWei(web3.eth.getBalance(person_address), "ether");

    var beertokens;
    if (beerTokenContractInstance != null) {
        beertokens = beerTokenContractInstance.balanceOf(person_address);
    }
    var pendingBeertokens = fizzBuzzContractInstance.pendingBeer(person_address);
    var person = new Person(person_address, ether, beertokens, pendingBeertokens);
    return person;
}

function persons() {
    var p = $.urlParam('invite');
    if (!p) {
        return [];
    }
    return p.split(',');
}

function addPersonTemplate(role, person_address) {
    $("#" + role).parent().find(" .empty ").remove();

    var context = {
        role: role,
        person: getPerson(person_address),
    };

    var html = personTemplate(context);
    $("#" + role).append(html);
}

function removePersonTemplate(role, person_address) {
    $('.' + role + '_card[data-address=\'' + person_address + '\']').remove();
}

$(
    function() {
        var Web3 = require("web3");
        var web3 = window['web3'] = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

        if (!web3.isConnected()) {
            alert("not connected!");
            return;
        }

        var fizzBuzzContract = web3.eth.contract(fizzBuzzABI);
        var beerTokenContract = web3.eth.contract(beerTokenABI);

        var contractAddress = $.urlParam('contract');
        if (contractAddress != null) {
            loadBarContract(contractAddress);

            persons().forEach(function (person_address) {
                addPerson(person_address);
            });
        }

        function loadBarContract(address) {
            var barTemplate = renderBarTemplate(address);
            $('#bar').data('address', address);
            $('#bar').html(barTemplate);

            var footerTemplate = renderFooterTemplate();
            $('#footer').html(footerTemplate);
        }

        function renderBarTemplate(address) {
            fizzBuzzContractInstance = fizzBuzzContract.at(address);
            beerAddress = fizzBuzzContractInstance.beerTokenContractAddress();

            console.log("beerAddress: " + beerAddress);


            var beerPrice = web3.fromWei(fizzBuzzContractInstance.beerPrice(), "ether");
            var barIsOpen = fizzBuzzContractInstance.barIsOpen();
            // var votingStatus = fizzBuzzContractInstance.getVotingStatus();
            var ether = web3.fromWei(web3.eth.getBalance(address), "ether");
            var beerAmount;
            var beerTotalSupply;
            var beerName;
            var beerSymbol;
            if (beerAddress != 0x0) {
                beerTokenContractInstance = beerTokenContract.at(beerAddress);
                beerAmount = beerTokenContractInstance.balanceOf(address);
                beerTotalSupply = beerTokenContractInstance.totalSupply();
                beerName = beerTokenContractInstance.name();
                beerSymbol = beerTokenContractInstance.symbol();
            }

            var context = {
                beerPrice: beerPrice,
                address: address,
                ether: ether,
                barIsOpen: barIsOpen,
                // votingStatus: votingStatus,
                beerAddress: beerAddress,
                beerAmount: beerAmount,
                beerTotalSupply: beerTotalSupply,
                beerName: beerName,
                beerSymbol: beerSymbol
            };

            var html = barTemplate(context);
            return html;
        }

        function renderFooterTemplate() {
            var context = {
                block: web3.eth.blockNumber
            };

            var html = footerTemplate(context);
            return html;
        }


        function addPerson(person_address) {
            addPersonTemplate('person', person_address);

            if (fizzBuzzContractInstance.hasRole(person_address, fizzBuzzContractInstance.ROLE_BARKEEPER())) {
                addPersonTemplate('barkeeper', person_address);
            }
            if (fizzBuzzContractInstance.hasRole(person_address, fizzBuzzContractInstance.ROLE_ADMIN())) {
                addPersonTemplate('owner', person_address);
            }
            if (fizzBuzzContractInstance.hasRole(person_address, fizzBuzzContractInstance.ROLE_JURY())) {
                addPersonTemplate('jury', person_address);
            }
        }


        $("#loadBarSubmit").click(function () {
            var address = $("#address").val();
            window.location.href = updateUrlParameter(window.location.href, 'contract', address);
        });

        $(document).on("click", ".invite_submit", function () {
            var bar = $(this).closest("#bar");

            var invite_address = bar.find('.invite_address').val();
            console.log("invite_address: " + invite_address);

            var p = persons();
            if (p.indexOf(invite_address) < 0) {
                p.push(invite_address);
            }
            window.location.href = updateUrlParameter(window.location.href, 'invite', p.join());
        });
    }
);

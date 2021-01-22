var personDetailTemplate = Handlebars.getTemplate('detail/person-template');

var gameRequestEvent = null;
var nextTurnEvent = null;
var endGameEvent = null;
var abortEvent = null;
var donationEvent = null;
var p_context = null;
var p_address = null;

$(
    function() {

        // $(document).ready(function () {
        //
        //
        //     setInterval(function () {
        //         console.log("CLIKC");
        //
        //         console.log(p_address);
        //
        //         if ($(".person_card").closest(".card").data('address') == p_address) {
        //             console.log("CLASK");
        //             $(".person_card").click();
        //         }
        //     }, 7500);
        // });

        $(document).on("click", ".person_card", function () {

            var address = $(this).data('address');
            p_address = address;

            var person = getPerson(address);

            var game = {
                gameTurn: fizzBuzzContractInstance.getTurn({from: address}),
                gameMyTurn: fizzBuzzContractInstance.getMyTurn({from: address}),
                gameOther: fizzBuzzContractInstance.getOtherPlayer({from: address}),
                gameCommitment: fizzBuzzContractInstance.getCommitment({from: address}),
                gameNumber1: fizzBuzzContractInstance.getNumber1({from: address}),
                gameNumber2: fizzBuzzContractInstance.getNumber2({from: address}),
                gameHaveIPayed: fizzBuzzContractInstance.getHaveIPayed({from: address}),
                gameHasOtherPayed: fizzBuzzContractInstance.getHasOtherPayed({from: address})
            };

            if (gameRequestEvent == null) {
                gameRequestEvent = fizzBuzzContractInstance.GameRequestEvent({from: game.gameOther, to: address});
                gameRequestEvent.watch(function(error, result){
                    if(!error) {
                        $.notify({message: 'Game Request!'},{type: 'danger'});
                        $("#reload-game").click();
                    }
                    else {
                        $.notify({message: '<strong>Error:</strong> ' + error},{type: 'danger'});
                    }
                });
            }

            if (nextTurnEvent == null) {
                nextTurnEvent = fizzBuzzContractInstance.NextTurnEvent({from: address, to: game.gameOther});
                nextTurnEvent.watch(function(error, result){
                    if(!error) {
                        $.notify({message: 'Next Turn!'},{type: 'danger'});
                        $("#reload-game").click();
                    }
                    else {
                        $.notify({message: '<strong>Error:</strong> ' + error},{type: 'danger'});
                    }
                });
            }

            if (endGameEvent = null) {
                endGameEvent = fizzBuzzContractInstance.EndGameEvent({});
                endGameEvent.watch(function (error, result) {
                    if (!error) {
                        $.notify({message: 'End Game!'},{type: 'danger'});
                        $("#reload-game").click();
                    }
                    else {
                        $.notify({message: '<strong>Error:</strong> ' + error}, {type: 'danger'});
                    }
                });
            }

            if (abortEvent = null) {
                abortEvent = fizzBuzzContractInstance.AbortEvent({player1: address, player2: game.gameOther});
                abortEvent.watch(function (error, result) {
                    if (!error) {
                        $.notify({message: 'Game Abort!'},{type: 'danger'});
                        $("#reload-game").click();
                    }
                    else {
                        $.notify({message: '<strong>Error:</strong> ' + error}, {type: 'danger'});
                    }
                });
            }

            if (donationEvent == null) {
                donationEvent = fizzBuzzContractInstance.DonationEvent({from: address});
                donationEvent.watch(function (error, result) {
                    if (!error) {
                        $.notify({message: 'Donation!'}, {type: 'danger'});
                        $("#reload-game").click();
                    }
                    else {
                        $.notify({message: '<strong>Error:</strong> ' + error}, {type: 'danger'});
                    }
                });
            }


            var context = {
                role: 'person',
                person: person,
                game: game
            };
            p_context = context;

            var html = personDetailTemplate(context);

            $( '#person_detail' ).html(html);
        });




        $(document).on("click", "#buy-beer-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var bar_address = $(this).closest("#bar").data('address');
            var amount = $(this).closest(".card").find("#buy-beer-quantity").val();

            if (confirm('Send ' + amount + ' Beertokens from ' + sender_address + ' to ' + bar_address + '?')) {
                beerTokenContractInstance.transfer['address,uint256'].estimateGas(bar_address, parseInt(amount), {from: sender_address}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        beerTokenContractInstance.transfer['address,uint256'](bar_address, parseInt(amount), {from: sender_address}, showError);
                    }
                });

            }
        });

        $(document).on("click", "#cancel-beer-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var amount = $(this).closest(".card").find("#cancel-beer-quantity").val();

            fizzBuzzContractInstance.cancelOrder.estimateGas(parseInt(amount), {from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    fizzBuzzContractInstance.cancelOrder(parseInt(amount), {from: sender_address}, showError);
                }
            });

        });


        $(document).on("click", "#buy-beertoken-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var bar_address = $(this).closest("#bar").data('address');
            var amount = $(this).closest(".card").find("#buy-beertoken-quantity").val();

            if (confirm('Send ' + amount + ' ETH from ' + sender_address + ' to ' + bar_address + '?')) {
                fizzBuzzContractInstance.buyToken.estimateGas({from: sender_address, value: web3.toWei(parseInt(amount), 'ether')}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        fizzBuzzContractInstance.buyToken({from: sender_address, value: web3.toWei(parseInt(amount), 'ether')}, showError);
                    }
                });

            }
        });


        $(document).on("click", "#donate-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var bar_address = $(this).closest("#bar").data('address');
            var amount = $(this).closest(".card").find("#donate-game-amount").val();

            if (confirm('Send ' + amount + ' ETH from ' + sender_address + ' to ' + bar_address + '?')) {
                fizzBuzzContractInstance.donate.estimateGas({from: sender_address, value: web3.toWei(parseInt(amount), 'ether')}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        fizzBuzzContractInstance.donate({from: sender_address, value: web3.toWei(parseInt(amount), 'ether')}, showError);
                    }
                });

            }
        });

        $(document).on("click", "#new-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var other_address = $(this).closest(".card").find("#new-game-other").val();
            var commitment = fizzBuzzContractInstance.getCommitment().s;
            var number1 = $(this).closest(".card").find("#new-game-number1").val();


            fizzBuzzContractInstance.newGame.estimateGas(other_address, commitment, number1, {from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    fizzBuzzContractInstance.newGame(other_address, commitment, number1, {from: sender_address, gas: result + 25000}, showError);
                }
            });
        });

        $(document).on("click", "#pay-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var bar_address = $(this).closest("#bar").data('address');
            var commitment = fizzBuzzContractInstance.getCommitment().s;

            if (confirm('Send ' + commitment + ' Beertokens from ' + sender_address + ' to ' + bar_address + '?')) {
                beerTokenContractInstance.transfer['address,uint256,bytes'].estimateGas(bar_address, parseInt(commitment), web3.toHex('game'), {from: sender_address}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        beerTokenContractInstance.transfer['address,uint256,bytes'](bar_address, parseInt(commitment), web3.toHex('game'), {from: sender_address, gas: result + 250000}, showError);
                    }
                });
            }
        });

        $(document).on("click", "#accept-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var number2 = $(this).closest(".card").find("#accept-game-number2").val();

            fizzBuzzContractInstance.acceptGame.estimateGas(number2, {from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    fizzBuzzContractInstance.acceptGame(number2, {from: sender_address, gas: result + 250000}, showError);
                }
            });
        });

        $(document).on("click", "#reject-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');

            if (confirm('Do you really want to reject this game?')) {

                fizzBuzzContractInstance.rejectGame.estimateGas({from: sender_address}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        fizzBuzzContractInstance.rejectGame({from: sender_address, gas: result + 250000}, showError);
                    }
                });
            }
        });

        $(document).on("click", "#move-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var text = $(this).closest(".card").find("#move-game-text").val();
            text = text.toUpperCase();

            if (text != "FIZZ" && text != "BUZZ" && text != "FIZZBUZZ") {
                let num = "";
                for (let i = 0; i < 32; i++) {
                    if (text[i] != null) {
                        num = num + "3" + text[i];
                    } else {
                        num = num + "00";
                    }
                }
                text = "0x" + num;
            } else {
                text = text.toUpperCase();
            }


            fizzBuzzContractInstance.makeMove.estimateGas(text, {from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    fizzBuzzContractInstance.makeMove(text, {from: sender_address, gas: result + 250000}, showError);
                }
            });
        });


        $(document).on("click", "#reload-game", function () {
            var address = p_address;

            p_context.game = {
                gameTurn: fizzBuzzContractInstance.getTurn({from: address}),
                gameMyTurn: fizzBuzzContractInstance.getMyTurn({from: address}),
                gameOther: fizzBuzzContractInstance.getOtherPlayer({from: address}),
                gameCommitment: fizzBuzzContractInstance.getCommitment({from: address}),
                gameNumber1: fizzBuzzContractInstance.getNumber1({from: address}),
                gameNumber2: fizzBuzzContractInstance.getNumber2({from: address}),
                gameHaveIPayed: fizzBuzzContractInstance.getHaveIPayed({from: address}),
                gameHasOtherPayed: fizzBuzzContractInstance.getHasOtherPayed({from: address})
            };

            var html = personDetailTemplate(p_context);

            $( '#person_detail' ).html(html);
        });





    }
);
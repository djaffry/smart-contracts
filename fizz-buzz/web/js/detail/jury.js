var juryDetailTemplate = Handlebars.getTemplate('detail/jury-template');

$(
    function() {

        $(document).on("click", ".jury_card", function () {
            var address = $(this).data('address');

            var person = getPerson(address);
            var context = {
                role: 'jury',
                person: person,
                persons: persons()
            };
            var html = juryDetailTemplate(context);

            $( '#person_detail' ).html(html);
        });

        $(document).on("click", "#refund-game-submit", function () {
            var sender_address = $(this).closest(".card").data('address');
            var other_address = $(this).closest(".card").find("#refund-player").val();

            if (confirm('Do you really want to refund this game?')) {
                fizzBuzzContractInstance.refund.estimateGas(other_address, {from: sender_address}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        fizzBuzzContractInstance.refund(other_address, {from: sender_address, gas: result + 250000}, showError);
                    }
                });
            }
        });
    }
);
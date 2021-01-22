var djDetailTemplate = Handlebars.getTemplate('detail/dj-template');

$(
    function() {

        $(document).on("click", ".dj_card", function () {
            var address = $(this).data('address');

            var person = getPerson(address);
            var context = {
                role: 'dj',
                person: person,
                persons: persons()
            };
            var html = djDetailTemplate(context);

            $( '#person_detail' ).html(html);
        });

        $(document).on("click", "#votings-status-submit", function () {
            let status = songVotingContractInstance.getVotingStatus();
            $.notify({message: '<strong>Current Voting Status is: </strong> ' + status},{});

        });

        $(document).on("click", "#choose-song-submit", function () {
            let song = songVotingContractInstance.chooseSong();
            if (song === "0x") {
                $.notify({message: '<strong>There are no votes yet!</strong> '},{type: 'danger'});
            } else {
                $.notify({message: '<strong>Current voted song is: </strong> ' + song},{});
            }
        });

        $(document).on("click", "#play-song-submit", function () {
            let sender_address = $(this).closest(".card").data('address');
            let bar_address = $(this).closest("#bar").data('address');
            let title = $(this).closest(".card").find("#song-title").val();
            title = title.substring(0, 31);

            if (confirm('Play Song ' + title + " and delete all votes of this song at bar " + bar_address + '?')) {
                songVotingContractInstance.playSong.estimateGas(title, {from: sender_address}, function(error, result) {
                    if (error) {
                        $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                    } else {
                        songVotingContractInstance.playSong(title, {from: sender_address, gas: result + 25000}, showError);
                    }
                });
            }
        });


        $(document).on("click", "#close-votings-submit", function () {
            var sender_address = $(this).closest(".card").data('address');

            songVotingContractInstance.closeVoting.estimateGas({from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    songVotingContractInstance.closeVoting({from: sender_address}, showError);
                }
            });

        });

        $(document).on("click", "#open-votings-submit", function () {
            var sender_address = $(this).closest(".card").data('address');

            songVotingContractInstance.openVoting.estimateGas({from: sender_address}, function(error, result) {
                if (error) {
                    $.notify({message: '<strong>Gas estimation failed:</strong> ' + error},{type: 'danger'});
                } else {
                    songVotingContractInstance.openVoting({from: sender_address}, showError);
                }
            });

        });
    }
);
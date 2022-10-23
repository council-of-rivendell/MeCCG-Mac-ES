#
# Metw Deck Statistics Script by Malakh Harbonah
#

def CommandSitestats
{

push(cursites);
push(totalcards);
push(curdeck);
totalcards=length(decks{deck.name}{"deck"});
curdeck=decks{deck.name}{"deck"};
cursites=decks{deck.name}{"sites"};

Msg("Sites=" + CountSites(cursites));

Msg("Items vs. Playables:");
Msg("Greater Items=" + CountResGreaterItems(curdeck)
 + " Greater Item Playable Sites=" + CountPlayableGreater(cursites));

curdeck=pop();
totalcards=pop();
cursites=pop();
}

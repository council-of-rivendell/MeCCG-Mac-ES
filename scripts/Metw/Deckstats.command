#
# Metw Deck Statistics Script by Malakh Harbonah
#

stats.object=(obj=obj+1);

#
# CommandDeckstats - /deckstats  - Returns a Listbox report of Statistics for the current deck.
#

def CommandDeckstats
{

push(totalcards);
push(curdeck);
push(curpool);
totalcards=length(decks{deck.name}{"deck"});
totalpool=length(decks{deck.name}{"pool"});
curdeck=decks{deck.name}{"deck"};
curpool=decks{deck.name}{"pool"};


if(deck.name!=NULL) {
  del_object(stats.object);
  stats.box=create_listbox(290,140,stats.object,"{orange}Metw Deck Statistics",100,("Type","# of","%ofDeck"),(150,60,80),34,(1,1,1));





  listbox_set_entry
    (
      stats.box,0,
      (
        "Hazards",
        format("%2.0f",CountHazards(curdeck)),
        format("%2.0f",(CountHazards(curdeck)/totalcards)*100) + "%"
      )
  );
    listbox_set_entry
    (
      stats.box,1,
      (
        "Hero Resources",
        format("%2.0f",CountHeroResources(curdeck)),
        format("%2.0f",(CountHeroResources(curdeck)/totalcards)*100) + "%"
      )
  );
    listbox_set_entry
    (
      stats.box,2,
      (
        "Minion Resources",
        format("%2.0f",CountMinionRes(curdeck)),
        format("%2.0f",(CountMinionRes(curdeck)/totalcards)*100) + "%"
      )
  );
    listbox_set_entry
    (
      stats.box,3,
      (
        "Hero Characters",
        format("%2.0f",CountHeros(curdeck)),
        format("%2.0f",(CountHeros(curdeck)/totalcards)*100) + "%"
      )
  );
    listbox_set_entry
    (
      stats.box,4,
      (
        "Minion Characters",
        format("%2.0f",CountMinionChars(curdeck)),
        format("%2.0f",(CountMinionChars(curdeck)/totalcards)*100) + "%"
      )
  );
    listbox_set_entry
    (
      stats.box,5,
      (
        "{blue}Pool Statistics{black}",
        "{blue}# of",
        "{blue}%ofPool"
      )
  );
      listbox_set_entry
    (
      stats.box,6,
      (
        "Hazards",
        format("%2.0f",CountHazards(curpool)),
        format("%2.0f",(CountHazards(curpool)/totalpool)*100) + "%"
      )
  );
      listbox_set_entry
    (
      stats.box,7,
      (
        "Hero Resources",
        format("%3.0f", CountHeroResources(curpool) ),
        format("%3.0f", (CountHeroResources(curpool)/totalpool)*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,8,
      (
        "Minion Resources",
        format("%3.0f", CountMinionRes(curpool) ),
        format("%3.0f", (CountMinionRes(curpool)/totalpool)*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,9,
      (
        "Hero Characters",
        format("%3.0f", CountHeros(curpool) ),
        format("%3.0f", (CountHeros(curpool)/totalpool)*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,10,
      (
        "Minion Characters",
        format("%3.0f", CountMinionChars(curpool) ),
        format("%3.0f", (CountMinionChars(curpool)/totalpool)*100) + "%"
     )
  );

      listbox_set_entry
    (
      stats.box,11,
      (
        "{green}Hazard Statistics",
        "{green}# of",
        "{green}%ofHaz"
     )
  );
      listbox_set_entry
    (
      stats.box,12,
      (

        "Creatures",
        format("%2.0f",CountHazCreatures(curdeck)),
        format("%2.0f",(CountHazCreatures(curdeck)/CountHazards(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,13,
      (

        "Short-Events",
        format("%2.0f",CountHazShort(curdeck)),
        format("%2.0f",(CountHazShort(curdeck)/CountHazards(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,14,
      (

        "Long-Events",
        format("%2.0f",CountHazLong(curdeck)),
        format("%2.0f",(CountHazLong(curdeck)/CountHazards(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,15,
      (

        "Permanent-Events",
        format("%2.0f",CountHazPerm(curdeck)),
        format("%2.0f",(CountHazPerm(curdeck)/CountHazards(curdeck))*100) + "%"
     )
  );

      listbox_set_entry
    (
      stats.box,16,
      (
        "{gold}Resource Statistics",
        "{gold}# of",
        "{gold}%ofRes"
     )
  );
      listbox_set_entry
    (
      stats.box,17,
      (

        "Short-Events",
        format("%2.0f",CountResShort(curdeck)),
        format("%2.0f",(CountResShort(curdeck)/CountResources(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,18,
      (

        "Long-Events",
        format("%2.0f",CountResLong(curdeck)),
        format("%2.0f",(CountResLong(curdeck)/CountResources(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,19,
      (

        "Permanent-Events",
        format("%2.0f",CountResPerm(curdeck)),
        format("%2.0f",(CountResPerm(curdeck)/CountResources(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,20,
      (

        "Factions",
        format("%2.0f",CountResFactions(curdeck)),
        format("%2.0f",(CountResFactions(curdeck)/CountResources(curdeck))*100) + "%"
     )
  );
      listbox_set_entry
    (
      stats.box,21,
      (

        "Allies",
        format("%2.0f",CountResAllies(curdeck)),
        format("%2.0f",(CountResAllies(curdeck)/CountResources(curdeck))*100) + "%"
     )
  );

      listbox_set_entry
    (
      stats.box,22,
      (
        "{yellow}Item Statistics",
        "{yellow}# of",
        "{yellow}%ofItems"
     )
  );
        listbox_set_entry
    (
      stats.box,23,
      (

        "Greater Items",
        format("%2.0f",CountResGreaterItems(curdeck)),
        format("%2.0f",(CountResGreaterItems(curdeck)/CountResItems(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,24,
      (

        "Major Items",
        format("%2.0f",CountResMajorItems(curdeck)),
        format("%2.0f",(CountResMajorItems(curdeck)/CountResItems(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,25,
      (

        "Minor Items",
        format("%2.0f",CountResMinorItems(curdeck)),
        format("%2.0f",(CountResMinorItems(curdeck)/CountResItems(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,26,
      (

        "Special Items",
        format("%2.0f",CountResSpecialItems(curdeck)),
        format("%2.0f",(CountResSpecialItems(curdeck)/CountResItems(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,27,
      (

        "Ring Items",
        format("%2.0f",CountResRingItems(curdeck)),
        format("%2.0f",(CountResRingItems(curdeck)/CountResItems(curdeck))*100) + "%"
     )
  );
        listbox_set_entry
    (
      stats.box,29,
      (

        "{red}CharMP",
        "{red}ResMP",
	"{red}TotalMP"
     )
  );
        listbox_set_entry
    (
      stats.box,30,
      (

        format("%3.0f",(CountCharMp(curdeck)+CountCharMp(curpool))),
        format("%3.0f",CountResMp(curdeck)+CountResMp(curpool)),
	format("%3.0f",CountMp(curdeck)+CountMp(curpool))
     )
  );




  set_attr(stats.box,"visible",1);
  raise(stats.box);
}

  curpool=pop();
  curdeck=pop();
  totalcards=pop();
}

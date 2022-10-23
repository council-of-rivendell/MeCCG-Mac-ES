#
# CommandTextstats - /textstats  - Returns a Text report of Statistics for the current deck.
#

def CommandTextstats
{

push(totalcards);
push(curdeck);
push(curpool);
totalcards=length(decks{deck.name}{"deck"});
curdeck=decks{deck.name}{"deck"};
curpool=decks{deck.name}{"pool"};

if(deck.name!=NULL) {
Msg("{orange} *** Metw Deck Statistics *** ");

Msg("{gray}Hazards{green}: {white}" + format("%2.0f",CountHazards(curdeck))
 + " {green}({white}"  + format("%2.0f",(CountHazards(curdeck)/totalcards)*100)  + "%{green})"
 + " {gold}Hero Resources{green}: {white}" + format("%2.0f",CountResources(curdeck))
 + " {green}({white}" + format("%2.0f",(CountResources(curdeck)/totalcards)*100) + "%{green})"
 + " {cyan}Minion Resources{green}: {white}" + format("%2.0f",CountMinionRes(curdeck))
 + " {green}({white}" + format("%2.0f",(CountMinionRes(curdeck)/totalcards)*100) + "%{green})"
 + " {blue}Hero Characters{green}: {white}" + format("%2.0f",CountHeros(curdeck))
 + " {green}({white}" + format("%2.0f",(CountHeros(curdeck)/totalcards)*100) + "%{green})"
 + " {magenta}Minion Characters{green}: {white}" + format("%2.0f",CountMinionChars(curdeck))
 + " {green}({white}" + format("%2.0f",(CountMinionChars(curdeck)/totalcards)*100) + "%{green})"
);

Msg("{blue}Pool Statistics{green}: {white}" + format("%2.0f",CountHazards(curdeck))
 + " {green}({white}"  + format("%2.0f",(CountHazards(curdeck)/totalcards)*100)  + "%{green})"
 + " {gold}Hero Resources{green}: {white}" + format("%2.0f",CountResources(curdeck))
 + " {green}({white}" + format("%2.0f",(CountResources(curdeck)/totalcards)*100) + "%{green})"
 + " {cyan}Minion Resources{green}: {white}" + format("%2.0f",CountMinionRes(curdeck))
 + " {green}({white}" + format("%2.0f",(CountMinionRes(curdeck)/totalcards)*100) + "%{green})"
 + " {blue}Hero Characters{green}: {white}" + format("%2.0f",CountHeros(curdeck))
 + " {green}({white}" + format("%2.0f",(CountHeros(curdeck)/totalcards)*100) + "%{green})"
 + " {magenta}Minion Characters{green}: {white}" + format("%2.0f",CountMinionChars(curdeck))
 + " {green}({white}" + format("%2.0f",(CountMinionChars(curdeck)/totalcards)*100) + "%{green})"
);

Msg("{gray}Hazard Statistics{green}: {yellow}Creatures{green}={white}"+format("%2.0f",CountHazCreatures(curdeck))
 + "{green}({blue}"+format("%2.0f",(CountHazCreatures(curdeck)/CountHazards(curdeck))*100)+"%{green})"
 + " {yellow}Short-Events{green}={white}"+format("%2.0f",CountHazShort(curdeck))
 + "{green}({blue}"+format("%2.0f",(CountHazShort(curdeck)/CountHazards(curdeck))*100)+"%{green})"
 + " {yellow}Long-Events{green}={white}"+format("%2.0f",CountHazLong(curdeck))
 + "{green}({blue}"+format("%2.0f",(CountHazLong(curdeck)/CountHazards(curdeck))*100)+"%{green})"
 + " {yellow}Permanent-Events{green}={white}"+format("%2.0f",CountHazPerm(curdeck))
 + "{green}({blue}"+format("%2.0f",(CountHazPerm(curdeck)/CountHazards(curdeck))*100)+"%{green})"
);

Msg("{gold}Resource Statistics{green}: {yellow}Short-Events={white}"+format("%2.0f",CountResShort(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResShort(curdeck)/CountResources(curdeck))*100)+"%{green})"
 + " {yellow}Long-Events={white}"+format("%2.0f",CountResLong(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResLong(curdeck)/CountResources(curdeck))*100)+"%{green})"
 + " {yellow}Permanent-Events={white}"+format("%2.0f",CountResPerm(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResPerm(curdeck)/CountResources(curdeck))*100)+"%{green})"
 + " {yellow}Factions={white}"+format("%2.0f",CountResFactions(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResFactions(curdeck)/CountResources(curdeck))*100)+"%{green})"
 + " {yellow}Allies={white}"+format("%2.0f",CountResAllies(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResAllies(curdeck)/CountResources(curdeck))*100)+"%{green})"
);

Msg("{yellow}Items={white}"+format("%2.0f",CountResItems(curdeck))
 + "{green}({gold}"+format("%2.0f",(CountResItems(curdeck)/CountResources(curdeck))*100)+"%{green})"
 + "{orange}[{yellow}Greater={white}"+format("%2.0f",CountResGreaterItems(curdeck))
 + "{green}/{yellow}Major={white}"+format("%2.0f",CountResMajorItems(curdeck))
 + "{green}/{yellow}Minor={white}"+format("%2.0f",CountResMinorItems(curdeck))
 + "{green}/{yellow}Special={white}"+format("%2.0f",CountResSpecialItems(curdeck))
 + "{green}/{yellow}Rings={white}"+format("%2.0f",CountResRingItems(curdeck))
 + "{orange}]"
);

Msg("{red}Marshalling Points{green}: {cyan}Characters{green}={white}"
 + format("%3.0f",(CountCharMp(curdeck)+CountCharMp(curpool)))
 + " {gold}Resources{green}={white}"
 + format("%3.0f",CountResMp(curdeck)+CountResMp(curpool))
 + " {red}Total{green}={white}" + format("%3.0f",CountMp(curdeck)+CountMp(curpool))
);


}

  curpool=pop();
  curdeck=pop();
  totalcards=pop();
}

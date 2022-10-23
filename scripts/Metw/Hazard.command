#
# SOLITAIRE
# =========

# VARIABLES:
#
# solitaire.deck - deck for solitaire opponent
# solitaire.deck_name - name of the selected hazard or NULL if none.
#

solitaire.deck=(("deck",(,)),);
solitaire.deck_name=NULL;

#
# SolitaireHazards() - Return a list of solitaire hazards.
#
def SolitaireHazards
{
  return(forall('left(#,length(#)-7)',select('right(#,7)==".hazard"',scripts())));
}

#
# LoadSolitaireHazard(name) - Import a hazard file and return it's
#   content as normal deck structure.
#
def LoadSolitaireHazard
{
  push(f);
  f=read_file(DATADIR+"/scripts/Metw/"+ARG+".hazard");
  if(f==NULL)
    return("File "+DATADIR+"/scripts/Metw/"+ARG+".hazard not found.");
  else
    return(ImportDeckFormat("NetMECCG",f));
  f=pop();
}

#
# SetSolitaireDeck(hazard name, quiet) - Load and setup solitaire deck structure.
#   If quiet=1, disable messages.
#
def SetSolitaireDeck
{
  if(ARG[0]=="random")
  {
    if(ARG[1]!=1)
      Msg("Generating random hazard...");
    push(c);
    push(h);

    h=select('Attr("type",#)=="Hazard"',cards());
    c=select('Attr("class",#)=="Creature"',h);

    solitaire.deck_name="random";
    solitaire.deck=(,);
    solitaire.deck{"deck"}=shuffle(left(shuffle(c),12)+left(shuffle(h),16)+images("Doors of Night"));

    h=pop();
    c=pop();
    if(ARG[1]!=1)
      Msg("Hazard generated with "+length(solitaire.deck{"deck"})+" cards.");
  }
  else
  {  
    push(d);

    if(ARG[1]!=1)
      Msg("Loading hazard "+ARG[0]+"...");

    if(!isfunction("ImportNetMECCGDeck"))
      execute("NetMECCG.format");
    d=LoadSolitaireHazard(ARG[0]);
    if(typeof(d)=="string")
    {
      if(ARG[1]!=1)
        Msg("{red}Failed: "+d);
    }
    else
    {
      solitaire.deck_name=ARG[0];
      solitaire.deck=d;
      solitaire.deck{"deck"}=shuffle(solitaire.deck{"deck"});
      if(ARG[1]!=1)
        Msg("Hazard "+ARG[0]+" loaded with "+length(solitaire.deck{"deck"})+" cards.");
    }
    d=pop();
  }
}

#
# PlayCommandHazard(hazard name) - Load a named hazard or random hazard with argumet "random".
#   Without arguments, list all hazard options.
#
def PlayCommandHazard
{
  if(length(ARG)==0)
  {
    Msg("Hazards available: "+join(sort(SolitaireHazards()),", ")+" and random.");
  }
  else
  {
    SetSolitaireDeck(join(ARG," "),0);
  }
}

#
# SolitairePlayNext() - Take the first card from the solitaire deck and put aside.
#
def SolitairePlayNext
{
  if(solitaire.deck_name==NULL)
  {
    Msg("No hazard deck selected.");
    PlayCommandHazard(random(SolitaireHazards()),);
  }

  push(c);
  c=first(solitaire.deck{"deck"});
  if(c==NULL)
  {
    Msg("Exhausted...shuffling...");
    SetSolitaireDeck(solitaire.deck_name,1);
    c=first(solitaire.deck{"deck"});
    Msg("Done");
  }

  solitaire.deck{"deck"}=tail(solitaire.deck{"deck"});
  Send("Transfer",(1,("out.of.play",c),("active",0)));
  c=pop();
}

#
# PlayKeyControlKeyTab() - Set a next card in solitare deck aside.
#
def PlayKeyControlKeyTab
{
  SolitairePlayNext();
}


 
                        ..::|| PASCALice v1.5 ||::..
                       ******************************
                               by Kim Sullivan
                       ******************************


What is it?
***********

PASCALice is a free AIML interpreter (chat-bot) written in Delphi. If you
don't know what AIML is, it stands for "Artificial Intelligence Markup 
Language", for more information, have a look at http://www.alicebot.org

Configuration & Setup
*********************

Most of the things are currently hardcoded (I'm ashamed :-), but at
least PASCALice partially supports "Program D"-style startup.xml (release
4.1.4) You can use the 'full' format and structure, or just a stripped down 
version (see example startup.xml), it's parsed rather loosely. It is a good 
idea to place input substitutions & sentence splitters before the bots
definitions.

Load all the aiml files in a directory, place the startup.xml file in the dir
with the executable, and point the <learn> to that directory. When you start
the program, all bot properties, input substitutions and sentence splitters
will be loaded (more or less as expected).

PASCALice does support multiple bots (though only one at a time) through
startup.xml, just make sure they have a different bot-id so that the variables
don't get mixed up, and that only one of them is enabled (the rest will be
ignored and a message provided).

Features & Bugs
***************

* Tag nesting is supported, even the weird ones like <condition> and <random>.
* Multiple stars in all 3 parts of the path
* Custom <forget> tag to clear all user variables
* Some differences from the official specification
* Unlike the spec, you can use empty strings in conditions (but no wildcards)
* Pattern (and condition) matching is case insensitive, instead of requiring
  all patterns to be upper case
* Patterns can contain any character (even a few XML entities). This IMHO opens
  up some new possibilities for the botmaster (see protected.aiml)
* PASCAlice supports most of the AIML tags and features (almost all that really 
  matter), with the exception of:

Wildcard matching in <condition>. Instead, you can use empty strings, which 
normally isn't supported.                                                                   

<person>, <person2>, <gender>
Substitutions in templates are not yet supported, these tags work as if there
was an empty substitution list.

<system>, <javascript>
Both support an experimental 'alt' attribute which should provide compensation
for the missing functionality. <javascript> is always skipped, including 
contents, <system> contents are skipped only if the 'alt' attribute is present.

<getname> <gettopic> ...
... and all other deprecated tags, including the old <get_xxx> syntax are not
supported.

- Conversation history is not supported past <that>
- multidimensional <that> indices are also not supported (like, who cares :-)
- Don't know if this is a bug or a feature (other behaviour is easy) - the
  bot shows only the reply to the last sentence you told it, but the rest is
  processed.

If you find about anything that should be working and isn't, feel free to
contact me on alicebot@seznam.cz


Thanks & Acknowledgements
*************************

* Dr. Richard Wallace for inventing AIML (www.alicebot.org)
* Dirk Scheuring for most inspiring conversations
* Stefan Heymann for is excelent free XML parser for Delphi - the one library
  that made this implementation possible (www.destructor.de)
* Roman Janda for talking with the example bot a lot
* All the people from the alicebot mailinglists, who are making AIML what it is
  today

Licence
*******
For PASCALice, the GNU/GPL licence applies, see licence.txt
For the XML Parser, see the DSL, available at destructor.de

********************************************************************************
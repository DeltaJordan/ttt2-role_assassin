L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[ASSASSIN.name] = "Assassin"
L["info_popup_" .. ASSASSIN.name] = [[You are the Assassin!
Attack Innocents from behind with your assassin knife to gain credits.
Also, if you kill your target, you get a random Traitor item!]]
L["body_found_" .. ASSASSIN.abbr] = "They were an Assassin."
L["search_role_" .. ASSASSIN.abbr] = "This person was an Assassin!"
L["target_" .. ASSASSIN.name] = "Assassin"
L["ttt2_desc_" .. ASSASSIN.name] = [[The Assassin needs to win with the traitors!]]

L["ttt2_assassin_target_killed_item"] = "You received {item} for eliminating your target."
L["ttt2_assassin_target_killed"] = "You've killed your target!"
L["ttt2_assassin_chat_reveal"] = "'{playername}' is an Assassin!"
L["ttt2_assassin_target_died"] = "Your target died..."
L["ttt2_assassin_target_unavailable"] = "No targetable player available."
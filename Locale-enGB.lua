local L = LibStub("AceLocale-3.0"):NewLocale("ZebraKarmaFrames", "enGB", true)

if L then

-- Debug
L["oninit"] = "Initialized."
L["onenable"] = "Enabled."
L["ondisable"] = "Disabled."

L["BINDING_HEADER"] = "LootPlan"
L["BINDING_NAME_SELECTITEM"] = "Select Item"
L["BINDING_NAME_QUICKADD"] = "Quick Add to 'Other'"

-- Options menu
L["menu_gui_name"] = "GUI"
L["menu_gui_desc"] = "Open the Graphical User Interface"
L["menu_settings_name"] = "Settings"
L["menu_settings_desc"] = "Configure settings for LootPlan."
L["menu_settings_version_name"] = "This is version %s of %s."
L["menu_settings_debug_name"] = "Debug"
L["menu_settings_debug_desc"] = "If enabled, debug-messages will be printed to assist with debugging."
L["menu_settings_keybind_name"] = "Keybinding: Select Item"
L["menu_settings_keybind_desc"] = "When a item-tooltip is opened, press this button to select the item with the purpose of adding it to the system."
L["menu_settings_quickbind_name"] = "Keybinding: Quick AddItem"
L["menu_settings_quickbind_desc"] = "When a item-tooltip is opened, press this button to immediately add the item to the category 'Other'."
L["menu_settings_noteintooltip_name"] = "Add item-notes to tooltip"
L["menu_settings_noteintooltip_desc"] = "If enabled, when a tooltip of an item in the system is shown, the notes you added to that item will be added to the tooltip aswell."
L["menu_loot_name"] = "Items"
L["menu_loot_desc"] = ""
L["menu_loot_additem_name"] = "Add Item"
L["menu_loot_additem_desc"] = ""
L["menu_loot_additem_view_name"] = "View"
L["menu_loot_additem_view_desc"] = ""
L["menu_loot_additem_print_name"] = "Print"
L["menu_loot_additem_print_desc"] = ""
L["menu_loot_additem_note_name"] = "Note (optional)"
L["menu_loot_additem_note_desc"] = "Enter an optional note about this item."
L["menu_loot_additem_button_name"] = "Add Item"
L["menu_loot_additem_button_desc"] = "Add the selected item to the system."
L["menu_loot_item_view_name"] = "View"
L["menu_loot_item_view_desc"] = ""
L["menu_loot_item_print_name"] = "Print"
L["menu_loot_item_print_desc"] = ""
L["menu_loot_item_remove_name"] = "Remove"
L["menu_loot_item_remove_desc"] = "Remove this item from the system."
L["menu_import_name"] = "Import Items"
L["menu_import_desc"] = " "
L["menu_import_explaincat"] = "|cffffd000Add imported items to:|r"
L["menu_import_input_name"] = "Input (Format: 'itemID1:note; itemID2:note; itemID3:note;')"
L["menu_import_input_desc"] = ""
L["menu_import_button_name"] = "Import"
L["menu_import_button_desc"] = ""

L["menu_error_noitemtooltip"] = "No item data is present, please click an item-link first."
L["menu_error_itemalreadyexists"] = "This item is already in that category."

L["menu_confirm_removeitem"] = "Are you sure you want to remove this item from this category?"

L["menu_warning_noitemtooltip"] = " < No item has been selected >"

-- Class/Category matrix
L["CAT1"] = "Tank"
L["CAT2"] = "Melee"
L["CAT3"] = "Ranged"
L["CAT4"] = "Heal"
L["CAT5"] = "Other"

L["TIER"] = "Tier Token"

L["id "] = "id "
L["ilevel "] = "ilevel "
L["category "] = ""
L["slot "] = "slot "

L["notequippable"] = "not equippable"
L["unknowndrop"] = "<unknown source>"

L["tooltip_category"] = "|cffff0000!|cffff8000!|cff00ff00! |cff0080ffLootPlan: %s |cff00ff00!|cffff8000!|cffff0000!|r"
L["tooltip_note"] = "'%s' note: %s"

L["normal"] = "normal"
L["heroic"] = "heroic"

L["quickadd_string"] = "Added %s to category 'Other'."

L["import_log_invalidformat"] = "|cffff0000Invalid format|r"
L["import_log_alreadyincat"] = "|cffff0000Already in that category|r"
L["import_log_notlootitem"] = "|cffff0000Is not a loot item|r"
L["import_log_itemdoesnotexist"] = "|cffff0000Item does not exist|r"
L["import_log_succes"] = "|cff00ff00Imported succesfully|r"

end



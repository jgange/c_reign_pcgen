
$elements = [System.Collections.ArrayList]@()

$componentFile = "./UIComponents.json"

$elements = Get-Content -Path $componentFile | ConvertFrom-Json
exit 0

$element = @{
    "doubleExpandableComboBox"=
    @(
        @{
            "Name"   = "addItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="0"
                }
            },
        @{
            "Name"   = "primarySelectItem"
            "Type"   = "ComboBox"
            "Offset" = @{
                "row"="0"
                "column"="1"
                }
        },
        @{
            "Name"   = "relatedSelectItem"
            "Type"   = "ComboBox"
            "Offset" = @{
                "row"="0"
                "column"="2"
                }
        },
        @{
            "Name"   = "removeItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="2"
            }
        }
    )
}

$elements.add($element)

$element = @{
    "expandableComboBox"=
    @(
        @{
            "Name"   = "addItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="0"
                }
            },
        @{
            "Name"   = "primarySelectItem"
            "Type"   = "ComboBox"
            "Offset" = @{
                "row"="0"
                "column"="1"
                }
        },
        @{
            "Name"   = "removeItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="2"
            }
        }
    )
}

$elements.add($element)

$element = @{
    "labeledList" = 
    @(
        @{
            "Name"   = "itemLabel"
            "Type"   = "Label"
            "Offset" = @{
                "row"="0"
                "column"="0"
                } 
        },
        @{
            "Name"   = "item"
            "Type"   = "TextBox"
            "Offset" = @{
                "row"="0"
                "column"="1"
                } 
        }
    )
}

$elements.add($element)

$element = @{
    "expandableList" = 
    @(
        @{
            "Name"   = "addItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="0"
                }
        },
        @{
            "Name"   = "item"
            "Type"   = "TextBox"
            "Offset" = @{
                "row"="0"
                "column"="1"
                } 
        }
        @{
            "Name"   = "removeItem"
            "Type"   = "Button"
            "Offset" = @{
                "row"="0"
                "column"="2"
                }
        }
    )
}


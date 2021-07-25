GLOBAL MISSILES IS LIST().
GLOBAL MISSILE_HIGHLIGHTS IS LIST().
GLOBAL MISSILE_BODIES IS LIST().
GLOBAL FIRED IS LIST().

FUNCTION MAIN {
    CLEARSCREEN.
    ID_MISSILES().
    DRAW_TARGET().
    GLOBAL WEAPONS_SYSTEM_STOPPED IS FALSE.
    SETUP_GUI().
    HIDE_TARGET().
    GLOBAL TARGET_LOCKED IS FALSE.
    UNTIL WEAPONS_SYSTEM_STOPPED {
        IF NOT TARGET_LOCKED {
            UPDATE_TARGET_COORDS().
        }
    }
    CLEARVECDRAWS().
    WEAPONS_SYSTEM_WINDOW:HIDE().
}

FUNCTION SETUP_GUI {
    // WINDOW
    GLOBAL WEAPONS_SYSTEM_WINDOW IS GUI(350).
    SET WEAPONS_SYSTEM_WINDOW:Y TO 100.
    SET WEAPONS_SYSTEM_WINDOW:X TO 100.

    // TITLE
    LOCAL TITLE_LAYOUT IS WEAPONS_SYSTEM_WINDOW:ADDHLAYOUT().
    TITLE_LAYOUT:ADDSPACING(15).
    LOCAL TITLE IS TITLE_LAYOUT:ADDLABEL("<B>MISSILE SYSTEM</B>").
    SET TITLE:STYLE:ALIGN TO "CENTER".
    SET TITLE:STYLE:FONTSIZE TO 20.
    SET TITLE:STYLE:FONT TO "OCR B MT".

    // CLOSE GUI
    LOCAL CLOSE_BUTTON IS TITLE_LAYOUT:ADDBUTTON("<COLOR=RED> X</COLOR>").
    SET CLOSE_BUTTON:STYLE:WIDTH TO 25.
    SET CLOSE_BUTTON:STYLE:ALIGN TO "CENTER".
    SET CLOSE_BUTTON:ONCLICK TO {
        SET WEAPONS_SYSTEM_STOPPED TO TRUE.
    }.

    // TARGETING
    WEAPONS_SYSTEM_WINDOW:ADDLABEL("TARGETING").
    LOCAL TARGETING_BOX IS WEAPONS_SYSTEM_WINDOW:ADDVBOX().

    // TARGET SHOW/HIDE
    LOCAL TARGET_SHOW_BOX IS TARGETING_BOX:ADDVLAYOUT().
    SET TARGET_SHOW_BOX:STYLE:HEIGHT TO 25.
    LOCAL TARGET_SHOW_BOX_LAYOUT IS TARGET_SHOW_BOX:ADDHLAYOUT().
    TARGET_SHOW_BOX_LAYOUT:ADDSPACING(10).
    LOCAL VISIBILITY_LABEL IS TARGET_SHOW_BOX_LAYOUT:ADDLABEL("VISIBILITY:").
    SET VISIBILITY_LABEL:STYLE:WIDTH TO 100.
    LOCAL SHOW_TARGET_BUTTON IS TARGET_SHOW_BOX_LAYOUT:ADDRADIOBUTTON("SHOW").
    SET SHOW_TARGET_BUTTON:STYLE:WIDTH TO 100.
    LOCAL HIDE_TARGET_BUTTON IS TARGET_SHOW_BOX_LAYOUT:ADDRADIOBUTTON("HIDE", TRUE).
    SET TARGET_SHOW_BOX_LAYOUT:ONRADIOCHANGE TO {
        DECLARE PARAMETER STATE.
        IF STATE:TEXT = "SHOW" {
            SHOW_TARGET().
        } ELSE {
            HIDE_TARGET().
        }
    }.

    // TARGET LOCKING
    LOCAL TARGET_LOCK_BOX IS TARGETING_BOX:ADDVLAYOUT().
    SET TARGET_LOCK_BOX:STYLE:HEIGHT TO 25.
    LOCAL TARGET_LOCK_BOX_LAYOUT IS TARGET_LOCK_BOX:ADDHLAYOUT().
    TARGET_LOCK_BOX_LAYOUT:ADDSPACING(10).
    LOCAL LOCKING_LABEL IS TARGET_LOCK_BOX_LAYOUT:ADDLABEL("LOCKING:").
    SET LOCKING_LABEL:STYLE:WIDTH TO 100.
    LOCAL LOCK_TARGET_BUTTON IS TARGET_LOCK_BOX_LAYOUT:ADDRADIOBUTTON("LOCKED").
    SET LOCK_TARGET_BUTTON:STYLE:WIDTH TO 100.
    LOCAL FREE_TARGET_BUTTON IS TARGET_LOCK_BOX_LAYOUT:ADDRADIOBUTTON("FREE", TRUE).
    SET TARGET_LOCK_BOX_LAYOUT:ONRADIOCHANGE TO {
        DECLARE PARAMETER STATE.
        IF STATE:TEXT = "LOCKED" {
            LOCK_TARGET().
        } ELSE {
            UNLOCK_TARGET().
        }
    }.

    TARGETING_BOX:ADDSPACING(5).

    // ADJUST TARGET
    LOCAL ADJUST_TARGET_BOX IS TARGETING_BOX:ADDHLAYOUT().
    LOCAL ADJUST_TARGET_BOX_LAYOUT IS ADJUST_TARGET_BOX:ADDVLAYOUT().

    LOCAL NORTH_ROW IS ADJUST_TARGET_BOX_LAYOUT:ADDHLAYOUT().
    NORTH_ROW:ADDSPACING(135).
    LOCAL ADJUST_TARGET_NORTH_BUTTON IS NORTH_ROW:ADDBUTTON("NORTH").
    SET ADJUST_TARGET_NORTH_BUTTON:STYLE:WIDTH TO 70.

    LOCAL EAST_WEST_ROW IS ADJUST_TARGET_BOX_LAYOUT:ADDHLAYOUT().
    EAST_WEST_ROW:ADDSPACING(70).
    LOCAL ADJUST_TARGET_WEST_BUTTON IS EAST_WEST_ROW:ADDBUTTON("WEST").
    SET ADJUST_TARGET_WEST_BUTTON:STYLE:WIDTH TO 70.
    EAST_WEST_ROW:ADDSPACING(50).
    LOCAL ADJUST_TARGET_EAST_BUTTON IS EAST_WEST_ROW:ADDBUTTON("EAST").
    SET ADJUST_TARGET_EAST_BUTTON:STYLE:WIDTH TO 70.

    LOCAL SOUTH_ROW IS ADJUST_TARGET_BOX_LAYOUT:ADDHLAYOUT().
    SOUTH_ROW:ADDSPACING(135).
    LOCAL ADJUST_TARGET_SOUTH_BUTTON IS SOUTH_ROW:ADDBUTTON("SOUTH").
    SET ADJUST_TARGET_SOUTH_BUTTON:STYLE:WIDTH TO 70.


    LOCAL ADJUSTMENT_SCALE IS ADJUST_TARGET_BOX:ADDVSLIDER(5,9,2).
    LOCK ADJUSTMENT_AMOUNT TO 10^(ADJUSTMENT_SCALE:VALUE-7).

    ADJUST_TARGET_BOX:ADDSPACING(30).

    TARGETING_BOX:ADDSPACING(5).

    SET ADJUST_TARGET_NORTH_BUTTON:ONCLICK TO { ADJUST_TARGET_LAT(ADJUSTMENT_AMOUNT). }.
    SET ADJUST_TARGET_SOUTH_BUTTON:ONCLICK TO { ADJUST_TARGET_LAT(-ADJUSTMENT_AMOUNT). }.
    SET ADJUST_TARGET_EAST_BUTTON:ONCLICK TO { ADJUST_TARGET_LNG(ADJUSTMENT_AMOUNT). }.
    SET ADJUST_TARGET_WEST_BUTTON:ONCLICK TO { ADJUST_TARGET_LNG(-ADJUSTMENT_AMOUNT). }.

    // MISSILES
    WEAPONS_SYSTEM_WINDOW:ADDLABEL("MISSILES").

    LOCAL MISSILE_SECTION IS WEAPONS_SYSTEM_WINDOW:ADDVBOX().
    MISSILE_SECTION:ADDSPACING(5).
    LOCAL MISSILE_SECTION_MAIN IS MISSILE_SECTION:ADDHLAYOUT().
    LOCAL MISSILE_BOX IS MISSILE_SECTION_MAIN:ADDVLAYOUT().
    GLOBAL MISSILE_INFO_BOX IS MISSILE_SECTION_MAIN:ADDVBOX().
    SET MISSILE_INFO_BOX:STYLE:WIDTH TO 220.
    GLOBAL MISSILE_BOX_LAYOUT IS MISSILE_BOX:ADDVLAYOUT().
    LOCAL NONE_BUTTON IS MISSILE_BOX_LAYOUT:ADDRADIOBUTTON("NONE", TRUE).
    FOR I IN RANGE(MISSILES:LENGTH) {
        LOCAL MISSILE_SELECTION IS MISSILE_BOX_LAYOUT:ADDRADIOBUTTON("MISSILE " + (I+1), FALSE).
        SET MISSILE_SELECTION:ONCLICK TO SELECT_MISSILE@.
    }
    SET MISSILE_BOX_LAYOUT:ONRADIOCHANGE TO {
        DECLARE PARAMETER SELECTED_BUTTON.
        SETUP_MISSILE_INFO(SELECTED_BUTTON:TEXT).
    }.
    LOCAL FIRE_BUTTON_LAYOUT IS WEAPONS_SYSTEM_WINDOW:ADDHLAYOUT().
    FIRE_BUTTON_LAYOUT:ADDSPACING(70).
    LOCAL FIRE_BUTTON IS FIRE_BUTTON_LAYOUT:ADDBUTTON("FIRE").
    SET FIRE_BUTTON:STYLE:BG TO "IMAGES/FIRE.PNG".
    SET FIRE_BUTTON:STYLE:HOVER:BG TO "IMAGES/FIRE_SELECTED.PNG".
    SET FIRE_BUTTON:STYLE:ACTIVE:BG TO "IMAGES/FIRE_PRESSED.PNG".
    SET FIRE_BUTTON:STYLE:WIDTH TO 200.
    SET FIRE_BUTTON:ONCLICK TO {
        IF MISSILE_BOX_LAYOUT:RADIOVALUE <> "NONE" {
            LOCAL MISSILE_TEXT IS MISSILE_BOX_LAYOUT:RADIOVALUE:SPLIT(" ").
            LOCAL MISSILE_NUMBER IS MISSILE_TEXT[MISSILE_TEXT:LENGTH - 1]:TONUMBER().
            FIRE_MISSILE(MISSILES[MISSILE_NUMBER - 1]).
        }
    }.
    SETUP_MISSILE_INFO(NONE_BUTTON:TEXT).

    WEAPONS_SYSTEM_WINDOW:SHOW().
}

FUNCTION SETUP_MISSILE_INFO {
    DECLARE PARAMETER SELECTION.
    MISSILE_INFO_BOX:CLEAR().
    LOCAL MISSILE_INFO_LABEL IS MISSILE_INFO_BOX:ADDLABEL("MISSILE INFO").
    SET MISSILE_INFO_LABEL:STYLE:ALIGN TO "CENTER".
    IF SELECTION <> "NONE" {
        LOCAL MISSILE_TEXT IS SELECTION:SPLIT(" ").
        LOCAL MISSILE_NUMBER IS MISSILE_TEXT[MISSILE_TEXT:LENGTH - 1]:TONUMBER() - 1.
        LOCAL MISSILE_STATUS IS CHOOSE "LAUNCHED" IF FIRED[MISSILE_NUMBER] ELSE "READY".
        LOCAL MISSILE_INFO_ONE IS MISSILE_INFO_BOX:ADDHLAYOUT().
        MISSILE_INFO_ONE:ADDLABEL("STATUS:").
        MISSILE_INFO_ONE:ADDLABEL(MISSILE_STATUS).
        LOCAL MISSILE_INFO_TWO IS MISSILE_INFO_BOX:ADDHLAYOUT().
        MISSILE_INFO_TWO:ADDLABEL("MASS:").
        MISSILE_INFO_TWO:ADDLABEL(ROUND(GET_MISSILE_MASS(MISSILE_BODIES[MISSILE_NUMBER]), 3):TOSTRING).
        LOCAL MISSILE_INFO_THREE IS MISSILE_INFO_BOX:ADDHLAYOUT().
        MISSILE_INFO_THREE:ADDLABEL("FUEL TYPE:").
        MISSILE_INFO_THREE:ADDLABEL(GET_MISSILE_TYPE(MISSILE_BODIES[MISSILE_NUMBER])).
    } ELSE {
        LOCAL NO_MISSILE_LABEL IS MISSILE_INFO_BOX:ADDLABEL("NO MISSILE SELECTED").
        SET NO_MISSILE_LABEL:STYLE:ALIGN TO "CENTER".
    }
}

FUNCTION GET_MISSILE_TYPE {
    DECLARE PARAMETER MISSILE_BODY.
    LOCAL FUEL_TYPES IS LIST().
    FUEL_TYPES:ADD("LIQUID FUEL").
    FUEL_TYPES:ADD("SOLID FUEL").
    LOCAL FUEL_TYPES_USED IS LIST().
    LIST ENGINES IN ENGS.
    FOR ENG IN ENGS {
        IF MISSILE_BODY:FIND(ENG) <> -1 {
            FOR FUEL_TYPE IN FUEL_TYPES {
                IF ENG:CONSUMEDRESOURCES:HASKEY(FUEL_TYPE) {
                    FUEL_TYPES_USED:ADD(FUEL_TYPE).
                }
            }
        }
    }
    RETURN FUEL_TYPES_USED:JOIN(", ").
}

FUNCTION GET_MISSILE_MASS {
    DECLARE PARAMETER MISSILE_BODY.
    LOCAL TOTAL_MASS IS 0.
    FOR MISSILE_PART IN MISSILE_BODY {
        SET TOTAL_MASS TO TOTAL_MASS + MISSILE_PART:MASS.
    }
    RETURN TOTAL_MASS.
}

FUNCTION SELECT_MISSILE {
    FOR MISSILE_HIGHLIGHT IN MISSILE_HIGHLIGHTS {
        SET MISSILE_HIGHLIGHT:ENABLED TO FALSE.
    }
    IF MISSILE_BOX_LAYOUT:RADIOVALUE <> "NONE" {
        LOCAL MISSILE_TEXT IS MISSILE_BOX_LAYOUT:RADIOVALUE:SPLIT(" ").
        LOCAL MISSILE_NUMBER IS MISSILE_TEXT[MISSILE_TEXT:LENGTH - 1]:TONUMBER().
        IF NOT FIRED[MISSILE_NUMBER - 1] {
            SET MISSILE_HIGHLIGHTS[MISSILE_NUMBER - 1]:ENABLED TO TRUE.
        }
    }
}

FUNCTION ADJUST_TARGET_LAT {
    DECLARE PARAMETER ADJUSTMENT.
    LOCAL NEW_LAT IS TARGET_COORDS:LAT + ADJUSTMENT.
    IF NEW_LAT > 90 {
        SET NEW_LAT TO 90.
    } ELSE IF NEW_LAT < -90 {
        SET NEW_LAT TO -90.
    }
    SET TARGET_COORDS TO LATLNG(NEW_LAT, TARGET_COORDS:LNG).
}

FUNCTION ADJUST_TARGET_LNG {
    DECLARE PARAMETER ADJUSTMENT.
    LOCAL NEW_LNG IS TARGET_COORDS:LNG + ADJUSTMENT.
    IF NEW_LNG > 180 {
        SET NEW_LNG TO 180.
    } ELSE IF NEW_LNG < -180 {
        SET NEW_LNG TO -180.
    }
    SET TARGET_COORDS TO LATLNG(TARGET_COORDS:LAT, NEW_LNG).
}

FUNCTION UPDATE_TARGET_COORDS {
    GLOBAL TARGET_COORDS IS SHIP:BODY:GEOPOSITIONOF(SHIP:FACING*V(0,0,150*ALT:RADAR/100)).
}

FUNCTION GET_TARGET_POINT {
    SET GROUND_POINT TO TARGET_COORDS:ALTITUDEPOSITION(TARGET_COORDS:TERRAINHEIGHT + 15).
    RETURN GROUND_POINT.
}

FUNCTION ARROW1_START {
    RETURN GET_TARGET_POINT() + VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR)*100.
}

FUNCTION ARROW1_VEC {
    RETURN VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR)*-100.
}

FUNCTION ARROW2_START {
    RETURN GET_TARGET_POINT() + VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR)*-100.
}

FUNCTION ARROW2_VEC {
    RETURN VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR)*100.
}

FUNCTION ARROW3_START {
    RETURN GET_TARGET_POINT() + VCRS(SHIP:UP:VECTOR, VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR))*100.
}

FUNCTION ARROW3_VEC {
    RETURN VCRS(SHIP:UP:VECTOR, VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR))*-100.
}

FUNCTION ARROW4_START {
    RETURN GET_TARGET_POINT() + VCRS(SHIP:UP:VECTOR, VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR))*-100.
}

FUNCTION ARROW4_VEC {
    RETURN VCRS(SHIP:UP:VECTOR, VCRS(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR))*100.
}

FUNCTION SHOW_TARGET {
    SET ARROW1:SHOW TO TRUE.
    SET ARROW2:SHOW TO TRUE.
    SET ARROW3:SHOW TO TRUE.
    SET ARROW4:SHOW TO TRUE.
}

FUNCTION HIDE_TARGET {
    SET ARROW1:SHOW TO FALSE.
    SET ARROW2:SHOW TO FALSE.
    SET ARROW3:SHOW TO FALSE.
    SET ARROW4:SHOW TO FALSE.
}

FUNCTION DRAW_TARGET {
    GLOBAL ARROW1 IS VECDRAW(ARROW1_START@, ARROW1_VEC@, RGB(1,0,0)).
    GLOBAL ARROW2 IS VECDRAW(ARROW2_START@, ARROW2_VEC@, RGB(1,0,0)).
    GLOBAL ARROW3 IS VECDRAW(ARROW3_START@, ARROW3_VEC@, RGB(1,0,0)).
    GLOBAL ARROW4 IS VECDRAW(ARROW4_START@, ARROW4_VEC@, RGB(1,0,0)).
}

FUNCTION LOCK_TARGET {
    SET TARGET_LOCKED TO TRUE.
}

FUNCTION UNLOCK_TARGET {
    SET TARGET_LOCKED TO FALSE.
}

FUNCTION ID_MISSILES {
    LIST PROCESSORS IN ALL_PROCESSORS.
    FOR PROCESSOR IN ALL_PROCESSORS {
        IF PROCESSOR:TAG = "MISSILE" {
            MISSILES:ADD(PROCESSOR).
            FIRED:ADD(FALSE).
            LOCAL MISSILE_BODY IS GET_MISSILE_BODY(PROCESSOR).
            MISSILE_BODIES:ADD(MISSILE_BODY).
            SET MISSILE_HIGHLIGHT TO HIGHLIGHT(MISSILE_BODY, RGB(1.0,0.0,0.0)).
            SET MISSILE_HIGHLIGHT:ENABLED TO FALSE.
            MISSILE_HIGHLIGHTS:ADD(MISSILE_HIGHLIGHT).
        }
    }
}

FUNCTION GET_MISSILE_BODY {
    DECLARE PARAMETER PROCESSOR.
    LOCAL DECOUPLER IS PROCESSOR:PART:DECOUPLER.
    LOCAL MISSILE_BODY IS LIST().
    LOCAL Q IS QUEUE().
    Q:PUSH(DECOUPLER:CHILDREN[0]).
    UNTIL Q:EMPTY {
        SET CURRENT_PART TO Q:POP().
        MISSILE_BODY:ADD(CURRENT_PART).
        FOR P IN CURRENT_PART:CHILDREN {
            Q:PUSH(P).
        }
    }
    RETURN MISSILE_BODY.
}

FUNCTION FIRE_MISSILE {
    DECLARE PARAMETER MISSILE.
    SET MISSILE_HIGHLIGHTS[MISSILES:FIND(MISSILE)]:ENABLED TO FALSE.
    LOCAL MISSILE_CONNECTION IS MISSILE:CONNECTION.
    IF MISSILE:CONNECTION:SENDMESSAGE(TARGET_COORDS) {
        PRINT "MISSILE FIRED".
        SET FIRED[MISSILES:FIND(MISSILE)] TO TRUE.
        SETUP_MISSILE_INFO(MISSILE_BOX_LAYOUT:RADIOVALUE).
    } ELSE {
        PRINT "FIRING FAILED".
    }
}

MAIN().
mtype = {aliceKey, aliceID, aliceNonce, 
        bobKey, bobID, bobNonce, 
        intruderKey, intruderID, intruderNonce};

chan sync = [0] of {mtype, mtype, mtype};

active proctype Alice() {
    sync!aliceID, aliceNonce, bobKey;

    mtype nonce1;
    mtype nonce2;
    mtype key;
    do
        :: sync?nonce1, nonce2, key; break;
        :: timeout -> goto aliceend;
    od

    if
        :: nonce1 == aliceNonce && key == aliceKey;
        :: else -> {
            //Ignore the message, it's not meant for alice
            goto aliceend; 
        } 
    fi

    sync!0, nonce2, bobKey;

    alice_protocol_complete:

    aliceend:
}

active proctype Bob() {
    mtype nonce;
    mtype id;
    mtype key;
    sync?id, nonce, key;

    if
        :: key != bobKey -> {
            //Ignore the message, it's not meant for bob
            goto bobend; 
        } 
        :: else;
    fi

    sync!nonce, bobNonce, aliceKey;

    do
        :: sync?id, nonce, key; break;
        :: timeout -> goto bobend;
    od

    if
        :: nonce == bobNonce && key == bobKey;
        :: else -> goto bobend;
    fi

    bob_protocol_complete:

    bobend:
}

active proctype Intruder() {
    mtype p1, p2, p3;
    sync?p1,p2,p3;
    if
        ::sync!p1,p2,p3;
        ::sync!p2,p1,p3;
    fi
}

//ltl{[]<>(Bob@bobend <-> Alice@aliceend)};
ltl{[]<>(Bob@bob_protocol_complete <-> Alice@alice_protocol_complete)};

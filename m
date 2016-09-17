Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:57532 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752212AbcIQSEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 14:04:46 -0400
Subject: Re: [PATCH v5 00/25] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
Date: Sat, 17 Sep 2016 14:04:26 -0400
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 17, 2016, at 1:13 AM, Trond Myklebust wrote:

> According to RFC5661, if any of the SEQUENCE status bits
> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
> TEST_STATEID to figure out which stateids have been revoked, so we
> can acknowledge the loss of state using FREE_STATEID.
> 
> While we already do this for open and lock state, we have not been doing
> so for all the delegations.
> 
> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
> v3: Now with added lock revoke fixes and close/delegreturn/locku fixes
> v4: Close a bunch of corner cases
> v5: Report revoked delegations as invalid in nfs_have_delegation()
>    Fix an infinite loop in nfs_reap_expired_delegations.
>    Fixes for other looping behaviour

This time around the loop seems to be more tight,
in userspace process:

[ 9197.256571] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
[ 9197.256572] --> nfs41_setup_sequence
[ 9197.256573] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[ 9197.256574] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[ 9197.256574] <-- nfs41_setup_sequence slotid=0 seqid=14013800
[ 9197.256582] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013800 slotid=0 max_slotid=0 cache_this=1
[ 9197.256755] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[ 9197.256756] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[ 9197.256757] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 9197.256758] nfs41_sequence_process: Error 0 free the slot 
[ 9197.256760] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 9197.256779] --> nfs_put_client({2})
[ 9197.256799] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
[ 9197.256800] --> nfs41_setup_sequence
[ 9197.256801] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[ 9197.256802] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[ 9197.256803] <-- nfs41_setup_sequence slotid=0 seqid=14013801
[ 9197.256811] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013801 slotid=0 max_slotid=0 cache_this=1
[ 9197.257005] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[ 9197.257006] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[ 9197.257008] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 9197.257008] nfs41_sequence_process: Error 0 free the slot 
[ 9197.257010] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 9197.257029] --> nfs_put_client({2})
[ 9197.257035] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
[ 9197.257035] --> nfs41_setup_sequence
[ 9197.257036] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[ 9197.257037] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[ 9197.257038] <-- nfs41_setup_sequence slotid=0 seqid=14013802
[ 9197.257063] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013802 slotid=0 max_slotid=0 cache_this=1
[ 9197.257238] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[ 9197.257239] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[ 9197.257240] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 9197.257241] nfs41_sequence_process: Error 0 free the slot 
[ 9197.257242] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 9197.257262] --> nfs_put_client({2})
[ 9197.257267] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
[ 9197.257267] --> nfs41_setup_sequence
[ 9197.257268] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[ 9197.257269] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[ 9197.257270] <-- nfs41_setup_sequence slotid=0 seqid=14013803
[ 9197.257278] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013803 slotid=0 max_slotid=0 cache_this=1
[ 9197.257451] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[ 9197.257452] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[ 9197.257454] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 9197.257454] nfs41_sequence_process: Error 0 free the slot 
[ 9197.257456] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 9197.257475] --> nfs_put_client({2})
[ 9197.257480] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
[ 9197.257480] --> nfs41_setup_sequence
[ 9197.257481] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[ 9197.257482] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[ 9197.257483] <-- nfs41_setup_sequence slotid=0 seqid=14013804
[ 9197.257491] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013804 slotid=0 max_slotid=0 cache_this=1
[ 9197.257658] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[ 9197.257659] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[ 9197.257660] nfs4_free_slot: slotid 1 highest_used_slotid 0
[ 9197.257661] nfs41_sequence_process: Error 0 free the slot 
[ 9197.257662] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[ 9197.257681] --> nfs_put_client({2})



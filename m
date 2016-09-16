Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:52298 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751223AbcIPEiz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 00:38:55 -0400
Subject: Re: [PATCH v4 00/20] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 16 Sep 2016 00:38:35 -0400
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <F3BA1CBE-EADB-4B0A-8DE6-A3B5FB2E2156@linuxhacker.ru>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 15, 2016, at 12:45 PM, Trond Myklebust wrote:

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

This one seems to be looping on the client in a way very similar
to the first failure in that it's the serverip-named process that's
using the cpu, but the debug log is very similar to the second failure
in test stateid, except this time it's not "success 0", but "success -10025":

[21114.650534] NFS call  test_stateid ffff8800ca2f3da4
[21114.650537] --> nfs41_call_sync_prepare data->seq_server ffff880099003000
[21114.650538] --> nfs41_setup_sequence
[21114.650538] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21114.650539] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21114.650539] <-- nfs41_setup_sequence slotid=0 seqid=160421364
[21114.650544] encode_sequence: sessionid=1473979571:1:2:0 seqid=160421364 slotid=0 max_slotid=0 cache_this=0
[21114.650646] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21114.650646] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21114.650647] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21114.650648] nfs41_sequence_process: Error 0 free the slot 
[21114.650648] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21114.650660] NFS reply test_stateid: succeeded, -10025
[21114.650663] NFS call  test_stateid ffff8800ca2f3da4
[21114.650666] --> nfs41_call_sync_prepare data->seq_server ffff880099003000
[21114.650666] --> nfs41_setup_sequence
[21114.650667] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21114.650667] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21114.650667] <-- nfs41_setup_sequence slotid=0 seqid=160421365
[21114.650673] encode_sequence: sessionid=1473979571:1:2:0 seqid=160421365 slotid=0 max_slotid=0 cache_this=0
[21114.650792] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21114.650792] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21114.650793] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21114.650793] nfs41_sequence_process: Error 0 free the slot 
[21114.650794] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21114.650806] NFS reply test_stateid: succeeded, -10025
[21114.650809] NFS call  test_stateid ffff8800ca2f3da4
[21114.650812] --> nfs41_call_sync_prepare data->seq_server ffff880099003000
[21114.650812] --> nfs41_setup_sequence
[21114.650812] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21114.650813] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21114.650813] <-- nfs41_setup_sequence slotid=0 seqid=160421366
[21114.650819] encode_sequence: sessionid=1473979571:1:2:0 seqid=160421366 slotid=0 max_slotid=0 cache_this=0
[21114.650922] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21114.650922] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21114.650923] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21114.650923] nfs41_sequence_process: Error 0 free the slot 
[21114.650924] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21114.650936] NFS reply test_stateid: succeeded, -10025



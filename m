Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:59056 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751014AbcIJAt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 20:49:27 -0400
Subject: Re: [PATCH v3 00/12] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 9 Sep 2016 20:49:17 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <3D861710-09C5-42ED-8AB1-4B4D1A1180F2@linuxhacker.ru>
References: <1473444253-12433-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 9, 2016, at 2:04 PM, Trond Myklebust wrote:

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

With this set there are changes in behavior of my reproducer.

Change #1, server leaks dentries now, so once it's stopped, I cannot
unmount the ext4 that was exported.
I see your changes are just to the client, so I guess there's another nfsd bug
that needs to be tracked here.

Change #2, instead of client wedged in the old way, it's now wedges in another,
but similar way:
nfs client mountpoint is busy, but instead of server-ip-named thread spinning,
it's one of actual userspace threads that's now wedged.
-1 debug logs shows:
[21122.814992] NFS call  test_stateid ffff880069fb1f24
[21122.814997] --> nfs41_call_sync_prepare data->seq_server ffff88005fca9000
[21122.814997] --> nfs41_setup_sequence
[21122.814999] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21122.815000] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21122.815001] <-- nfs41_setup_sequence slotid=0 seqid=3502621
[21122.815010] encode_sequence: sessionid=1473458059:7:8:0 seqid=3502621 slotid=0 max_slotid=0 cache_this=0
[21122.815191] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21122.815192] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21122.815193] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21122.815194] nfs41_sequence_process: Error 0 free the slot 
[21122.815195] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21122.815226] NFS reply test_stateid: succeeded, 0
[21122.815235] --> nfs_put_client({3})
[21122.815253] --> nfs_put_client({2})
[21122.815260] --> nfs41_call_sync_prepare data->seq_server ffff88005fca9000
[21122.815260] --> nfs41_setup_sequence
[21122.815262] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21122.815263] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21122.815264] <-- nfs41_setup_sequence slotid=0 seqid=3502622
[21122.815273] encode_sequence: sessionid=1473458059:7:8:0 seqid=3502622 slotid=0 max_slotid=0 cache_this=1
[21122.815437] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21122.815438] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21122.815439] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21122.815440] nfs41_sequence_process: Error 0 free the slot 
[21122.815442] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21122.815462] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
[21122.815578] NFS call  test_stateid ffff880069fb1f24
[21122.815583] --> nfs41_call_sync_prepare data->seq_server ffff88005fca9000
[21122.815583] --> nfs41_setup_sequence
[21122.815585] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21122.815586] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21122.815587] <-- nfs41_setup_sequence slotid=0 seqid=3502623
[21122.815596] encode_sequence: sessionid=1473458059:7:8:0 seqid=3502623 slotid=0 max_slotid=0 cache_this=0
[21122.819581] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21122.819583] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21122.819585] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21122.819586] nfs41_sequence_process: Error 0 free the slot 
[21122.819588] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21122.819613] NFS reply test_stateid: succeeded, 0
[21122.819629] --> nfs_put_client({3})
[21122.819658] --> nfs_put_client({2})
[21122.819669] --> nfs41_call_sync_prepare data->seq_server ffff88005fca9000
[21122.819669] --> nfs41_setup_sequence
[21122.819671] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[21122.819672] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[21122.819673] <-- nfs41_setup_sequence slotid=0 seqid=3502624
[21122.819688] encode_sequence: sessionid=1473458059:7:8:0 seqid=3502624 slotid=0 max_slotid=0 cache_this=1
[21122.819924] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[21122.819926] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[21122.819927] nfs4_free_slot: slotid 1 highest_used_slotid 0
[21122.819928] nfs41_sequence_process: Error 0 free the slot 
[21122.819929] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[21122.819952] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
[21122.823396] NFS call  test_stateid ffff880069fb1f24

This is happening not as frequently as a previous problem, or possibly it's
just masked by the dentry leakage server-side that I saw more frequently than this one.

> Trond Myklebust (12):
>  NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
>  NFSv4.1: Don't check delegations that are already marked as revoked
>  NFSv4.1: Allow test_stateid to handle session errors without waiting
>  NFSv4.1: Add a helper function to deal with expired stateids
>  NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a
>    stateid
>  NFSv4.1: Test delegation stateids when server declares "some state
>    revoked"
>  NFSv4.1: Deal with server reboots during delegation expiration
>    recovery
>  NFSv4.1: Don't recheck delegations that have already been checked
>  NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
>  NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
>  NFSv4.1: FREE_STATEID can be asynchronous
>  NFSv4.1: Ensure we call FREE_STATEID if needed on
>    close/delegreturn/locku
> 
> fs/nfs/delegation.c                    | 153 ++++++++++++++++++-
> fs/nfs/delegation.h                    |   6 +-
> fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
> fs/nfs/nfs4_fs.h                       |   5 +-
> fs/nfs/nfs4proc.c                      | 258 ++++++++++++++++++++++-----------
> fs/nfs/nfs4session.h                   |   1 +
> fs/nfs/nfs4state.c                     |  29 ++--
> include/linux/nfs4.h                   |   1 +
> 8 files changed, 348 insertions(+), 107 deletions(-)
> 
> -- 
> 2.7.4


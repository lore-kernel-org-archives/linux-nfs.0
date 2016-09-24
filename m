Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:41404 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754611AbcIXUi7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 24 Sep 2016 16:38:59 -0400
Subject: Re: [PATCH v7 00/31] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
Date: Sat, 24 Sep 2016 16:38:45 -0400
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <ADE65AC8-EF13-46B3-983E-4D8E6806E608@linuxhacker.ru>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 22, 2016, at 1:38 PM, Trond Myklebust wrote:

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
>        Fixes for other looping behaviour
> v6: Fix nfs4_do_handle_exception to handle all stateids, not just delegations
>    Stable fix for nfs4_copy_delegation_stateid
>    Marked fix "NFSv4: Don't report revoked delegations as valid in
>        nfs_have_delegation" for stable.
>    Stable fix for the inode mode/fileid corruption
> v7: Fix handling of NFS4ERR_OPENMODE
>    Handle matching stateids that have set seqid==0

I just gave this another whirl and it holds up great, so I guess

Tested-by: Oleg Drokin <green@linuxhacker.ru>

> 
> 
> Many thanks to Oleg Drokin for all his time helping to test and debug these
> issues!
> 
> 
> Trond Myklebust (31):
>  NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
>  NFS: Fix inode corruption in nfs_prime_dcache()
>  NFSv4: Don't report revoked delegations as valid in
>    nfs_have_delegation()
>  NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is
>    invalid
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
>  NFSv4: Ensure we don't re-test revoked and freed stateids
>  NFSv4: nfs_inode_find_state_and_recover() should check all stateids
>  NFSv4: nfs4_handle_delegation_recall_error() handle expiration as
>    revoke case
>  NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
>  NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
>  NFSv4: Pass the stateid to the exception handler in
>    nfs4_read/write_done_cb
>  NFSv4: Fix a race in nfs_inode_reclaim_delegation()
>  NFSv4: Fix a race when updating an open_stateid
>  NFS: Always call nfs_inode_find_state_and_recover() when revoking a
>    delegation
>  NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single
>    stateid
>  NFSv4: Don't test open_stateid unless it is set
>  NFSv4: Mark the lock and open stateids as invalid after freeing them
>  NFSv4: Open state recovery must account for file permission changes
>  NFSv4: Fix retry issues with nfs41_test/free_stateid
>  NFSv4: If recovery failed for a specific open stateid, then don't
>    retry
>  NFSv4.1: Even if the stateid is OK, we may need to recover the open
>    modes
> 
> fs/nfs/delegation.c                    | 213 +++++++++++++++--
> fs/nfs/delegation.h                    |   8 +-
> fs/nfs/dir.c                           |  16 +-
> fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
> fs/nfs/nfs4_fs.h                       |   5 +-
> fs/nfs/nfs4proc.c                      | 402 +++++++++++++++++++++++----------
> fs/nfs/nfs4session.h                   |   1 +
> fs/nfs/nfs4state.c                     |  84 +++++--
> include/linux/nfs4.h                   |   1 +
> 9 files changed, 565 insertions(+), 167 deletions(-)
> 
> -- 
> 2.7.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33845 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcITQ4P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 12:56:15 -0400
Received: by mail-qk0-f193.google.com with SMTP id b204so1439138qkc.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 09:56:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v6 00/29] Fix delegation behaviour when server revokes some state
Date: Tue, 20 Sep 2016 12:55:42 -0400
Message-Id: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661, if any of the SEQUENCE status bits
SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
TEST_STATEID to figure out which stateids have been revoked, so we
can acknowledge the loss of state using FREE_STATEID.

While we already do this for open and lock state, we have not been doing
so for all the delegations.

v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
v3: Now with added lock revoke fixes and close/delegreturn/locku fixes
v4: Close a bunch of corner cases
v5: Report revoked delegations as invalid in nfs_have_delegation()
    Fix an infinite loop in nfs_reap_expired_delegations.
        Fixes for other looping behaviour
v6: Fix nfs4_do_handle_exception to handle all stateids, not just delegations
    Stable fix for nfs4_copy_delegation_stateid
    Marked fix "NFSv4: Don't report revoked delegations as valid in
        nfs_have_delegation" for stable.
    Stable fix for the inode mode/fileid corruption

Trond Myklebust (29):
  NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
  NFS: Fix inode corruption in nfs_prime_dcache()
  NFSv4: Don't report revoked delegations as valid in
    nfs_have_delegation()
  NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is
    invalid
  NFSv4.1: Don't check delegations that are already marked as revoked
  NFSv4.1: Allow test_stateid to handle session errors without waiting
  NFSv4.1: Add a helper function to deal with expired stateids
  NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a
    stateid
  NFSv4.1: Test delegation stateids when server declares "some state
    revoked"
  NFSv4.1: Deal with server reboots during delegation expiration
    recovery
  NFSv4.1: Don't recheck delegations that have already been checked
  NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
  NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
  NFSv4.1: FREE_STATEID can be asynchronous
  NFSv4.1: Ensure we call FREE_STATEID if needed on
    close/delegreturn/locku
  NFSv4: Ensure we don't re-test revoked and freed stateids
  NFSv4: nfs_inode_find_delegation_state_and_recover() should check all
    stateids
  NFSv4: nfs4_handle_delegation_recall_error() handle expiration as
    revoke case
  NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
  NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
  NFSv4: Pass the stateid to the exception handler in
    nfs4_read/write_done_cb
  NFSv4: Fix a race in nfs_inode_reclaim_delegation()
  NFSv4: Fix a race when updating an open_stateid
  NFS: Always call nfs_inode_find_state_and_recover() when revoking a
    delegation
  NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single
    stateid
  NFSv4: Don't test open_stateid unless it is set
  NFSv4: Mark the lock and open stateids as invalid after freeing them
  NFSv4: Open state recovery must account for file permission changes
  NFSv4: Fix retry issues with nfs41_test/free_stateid

 fs/nfs/delegation.c                    | 212 ++++++++++++++++--
 fs/nfs/delegation.h                    |   8 +-
 fs/nfs/dir.c                           |  14 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
 fs/nfs/nfs4_fs.h                       |   5 +-
 fs/nfs/nfs4proc.c                      | 378 +++++++++++++++++++++++----------
 fs/nfs/nfs4session.h                   |   1 +
 fs/nfs/nfs4state.c                     |  76 +++++--
 include/linux/nfs4.h                   |   1 +
 9 files changed, 538 insertions(+), 159 deletions(-)

-- 
2.7.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35152 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbcIOQqE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 12:46:04 -0400
Received: by mail-it0-f66.google.com with SMTP id e20so4991477itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2016 09:46:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v4 00/20] Fix delegation behaviour when server revokes some state
Date: Thu, 15 Sep 2016 12:45:40 -0400
Message-Id: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com>
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

Trond Myklebust (20):
  NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
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
  NFSv4: nfs_inode_find_delegation_state_and_recover() should check all
    stateids
  NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single
    stateid
  NFSv4: nfs4_handle_delegation_recall_error() handle expiration as
    revoke case
  NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
  NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
  NFSv4: Pass the stateid to the exception handler in
    nfs4_read/write_done_cb
  NFSv4: Fix a race in nfs_inode_reclaim_delegation()
  NFSv4: Fix a race when updating an open_stateid

 fs/nfs/delegation.c                    | 183 +++++++++++++++--
 fs/nfs/delegation.h                    |   8 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
 fs/nfs/nfs4_fs.h                       |   5 +-
 fs/nfs/nfs4proc.c                      | 364 ++++++++++++++++++++++-----------
 fs/nfs/nfs4session.h                   |   1 +
 fs/nfs/nfs4state.c                     |  73 +++++--
 include/linux/nfs4.h                   |   1 +
 8 files changed, 490 insertions(+), 147 deletions(-)

-- 
2.7.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34154 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757562AbcHaCMN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 22:12:13 -0400
Received: by mail-it0-f67.google.com with SMTP id e124so1140819ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 19:12:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] Fix delegation behaviour when server revokes some state
Date: Tue, 30 Aug 2016 22:11:37 -0400
Message-Id: <1472609504-69094-1-git-send-email-trond.myklebust@primarydata.com>
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


Trond Myklebust (7):
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

 fs/nfs/delegation.c                    | 153 +++++++++++++++++++++++++++++++--
 fs/nfs/delegation.h                    |   6 +-
 fs/nfs/flexfilelayout/flexfilelayout.c |   2 +-
 fs/nfs/nfs4_fs.h                       |   3 +
 fs/nfs/nfs4proc.c                      |  95 ++++++++++++++------
 fs/nfs/nfs4state.c                     |  17 ++--
 6 files changed, 230 insertions(+), 46 deletions(-)

-- 
2.7.4


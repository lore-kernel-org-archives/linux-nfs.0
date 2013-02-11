Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27966 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758718Ab3BKTaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] Fix NFSv4.1 deadlocks during reboot recover
Date: Mon, 11 Feb 2013 14:29:20 -0500
Message-Id: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches address a couple of deadlocks that we've been
seeing during reboot recovery and/or delegation recovery.

For NFSv4, it was safe for ordinary processes to grab the nfs_inode->rwsem
across an NFSv4 RPC call, since if the stateid needed recovery, the server
would return an appropriate error, the rpc call would return, and the
process would release the nfs_inode->rwsem so that the state recovery
thread could proceed.

In NFSv4.1, things get a little more interesting: the state recovery
thread will block all outstanding RPC calls using the NFS4_SESSION_DRAINING
flag. It needs to be able to do this so that we can safely recover
session state, stateids, etc.

The problem is that if a process is holding a lock, then that lock will
remain held until we call nfs4_end_drain_session(). So if the recovery
process needs to take that lock, we end up deadlocking...

The following patchset attempts to address this issue by adjusting the
locking in the state recovery and delegation recovery.

Trond Myklebust (6):
  NFSv4: Allow the state manager to mark an open_owner as being
    recovered
  NFSv4.1: Prevent deadlocks between state recovery and file locking
  NFSv4.1: Don't lose locks when a server reboots during delegation
    return
  NFSv4: Fix up the return values of nfs4_open_delegation_recall
  NFSv4: Ensure delegation recall and byte range lock removal don't
    conflict
  NFSv4: Fix a reboot recovery race when opening a file

 fs/nfs/delegation.c | 154 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfs/delegation.h |   1 +
 fs/nfs/nfs4_fs.h    |   4 ++
 fs/nfs/nfs4proc.c   |  96 +++++++++++++++++++++++---------
 fs/nfs/nfs4state.c  |  10 +++-
 5 files changed, 193 insertions(+), 72 deletions(-)

-- 
1.8.1.2


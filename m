Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27746 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758986Ab3BKTaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:24 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] NFSv4.1: Prevent deadlocks between state recovery and file locking
Date: Mon, 11 Feb 2013 14:29:22 -0500
Message-Id: <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have a deadlock in which the state recovery thread
ends up blocking due to one of the locks which it is trying to
recover holding the nfs_inode->rwsem.
The situation is as follows: the state recovery thread is
scheduled in order to recover from a reboot. It immediately
drains the session, forcing all ordinary NFSv4.1 calls to
nfs41_setup_sequence() to be put to sleep.  This includes the
file locking process that holds the nfs_inode->rwsem.
When the thread gets to nfs4_reclaim_locks(), it tries to
grab a write lock on nfs_inode->rwsem, and boom...

Fix is to have the lock drop the nfs_inode->rwsem while it is
doing RPC calls. We use a sequence lock in order to signal to
the locking process whether or not a state recovery thread has
run on that inode, in which case it should retry the lock.

Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 62fa400..92584c1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4813,8 +4813,10 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
+	struct nfs4_state_owner *sp = state->owner;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
+	unsigned int seq;
 	int status = -ENOLCK;
 
 	if ((fl_flags & FL_POSIX) &&
@@ -4836,9 +4838,16 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		status = do_vfs_lock(request->fl_file, request);
 		goto out_unlock;
 	}
+	seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
+	up_read(&nfsi->rwsem);
 	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
 	if (status != 0)
+		goto out;
+	down_read(&nfsi->rwsem);
+	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq)) {
+		status = -NFS4ERR_DELAY;
 		goto out_unlock;
+	}
 	/* Note: we always want to sleep here! */
 	request->fl_flags = fl_flags | FL_SLEEP;
 	if (do_vfs_lock(request->fl_file, request) < 0)
-- 
1.8.1.2


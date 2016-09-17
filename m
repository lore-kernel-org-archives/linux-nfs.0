Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34214 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754773AbcIQWRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 18:17:46 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v4 7/9] nfs: move nfs4_set_lock_state call into caller
Date: Sat, 17 Sep 2016 18:17:37 -0400
Message-Id: <1474150659-23894-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
References: <1474150659-23894-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to have this info set up before adding the waiter to the
waitqueue, so move this out of the _nfs4_proc_setlk and into the
caller. That's more efficient anyway since we don't need to do
this more than once if we end up waiting on the lock.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 74d8acadfd89..7a0d81b17eda 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6135,15 +6135,8 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs4_state_owner *sp = state->owner;
 	unsigned char fl_flags = request->fl_flags;
-	int status = -ENOLCK;
+	int status;
 
-	if ((fl_flags & FL_POSIX) &&
-			!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
-		goto out;
-	/* Is this a delegated open? */
-	status = nfs4_set_lock_state(state, request);
-	if (status != 0)
-		goto out;
 	request->fl_flags |= FL_ACCESS;
 	status = locks_lock_inode_wait(state->inode, request);
 	if (status < 0)
@@ -6217,6 +6210,11 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 
 	if (state == NULL)
 		return -ENOLCK;
+
+	if ((request->fl_flags & FL_POSIX) &&
+	    !test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
+		return -ENOLCK;
+
 	/*
 	 * Don't rely on the VFS having checked the file open mode,
 	 * since it won't do this for flock() locks.
@@ -6231,6 +6229,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 			return -EBADF;
 	}
 
+	status = nfs4_set_lock_state(state, request);
+	if (status != 0)
+		return status;
+
 	do {
 		status = nfs4_proc_setlk(state, cmd, request);
 		if ((status != -EAGAIN) || IS_SETLK(cmd))
-- 
2.7.4


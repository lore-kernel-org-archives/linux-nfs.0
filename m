Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965229AbcIPU1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:27:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 7/9] nfs: move nfs4_set_lock_state call into caller
Date: Fri, 16 Sep 2016 16:27:09 -0400
Message-Id: <1474057631-31209-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to have this info set up before adding the waiter to the
waitqueue, so move this out of the _nfs4_proc_setlk and into the
caller. That's more efficient anyway since we don't need to do
this more than once if we end up waiting on the lock.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c8ccf13e3ffb..c807850ac476 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6135,14 +6135,8 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs4_state_owner *sp = state->owner;
 	unsigned char fl_flags = request->fl_flags;
-	int status = -ENOLCK;
+	int status;
 
-	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
-		goto out;
-	/* Is this a delegated open? */
-	status = nfs4_set_lock_state(state, request);
-	if (status != 0)
-		goto out;
 	request->fl_flags |= FL_ACCESS;
 	status = locks_lock_inode_wait(state->inode, request);
 	if (status < 0)
@@ -6216,6 +6210,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 
 	if (state == NULL)
 		return -ENOLCK;
+
+	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
+		return -ENOLCK;
+
 	/*
 	 * Don't rely on the VFS having checked the file open mode,
 	 * since it won't do this for flock() locks.
@@ -6230,6 +6228,10 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
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


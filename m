Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:34122 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcDKUUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:20:25 -0400
Received: by mail-ig0-f195.google.com with SMTP id qu10so99501igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 11 Apr 2016 13:20:25 -0700 (PDT)
Subject: [PATCH] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:20:22 -0400
Message-ID: <20160411201733.20911.86904.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At Connectathon 2016, we found that recent upstream Linux clients
would occasionally send a LOCK operation with a zero stateid. This
appeared to happen in close proximity to another thread returning
a delegation before unlinking the same file while it remained open.

Earlier, the client received a write delegation on this file and
returned the open stateid. Now, as it is getting ready to unlink the
file, it returns the write delegation. But there is still an open
file descriptor on that file, so the client must OPEN the file
again before it returns the delegation.

Since commit 24311f884189 ('NFSv4: Recovery of recalled read
delegations is broken'), nfs_open_delegation_recall() clears the
NFS_DELEGATED_STATE flag _before_ it sends the OPEN. This allows a
racing LOCK on the same inode to be put on the wire before the OPEN
operation has returned a valid open stateid.

To eliminate this race, serialize delegation return with the
acquisition of a file lock on the same file. Adopt the same approach
as is used in the unlock path.

Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ... ')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi-

This fix appears to be both safe and effective. Please consider
it for v4.7 and for stable. Thanks!


 fs/nfs/nfs4proc.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 01bef06..c40f1b6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
+	struct nfs4_state_owner *sp = state->owner;
 	unsigned char fl_flags = request->fl_flags;
 	int status = -ENOLCK;
 
@@ -6068,6 +6069,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	status = do_vfs_lock(state->inode, request);
 	if (status < 0)
 		goto out;
+	mutex_lock(&sp->so_delegreturn_mutex);
 	down_read(&nfsi->rwsem);
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
 		/* Yes: cache locks! */
@@ -6075,9 +6077,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 		request->fl_flags = fl_flags & ~FL_SLEEP;
 		status = do_vfs_lock(state->inode, request);
 		up_read(&nfsi->rwsem);
+		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
 	}
 	up_read(&nfsi->rwsem);
+	mutex_unlock(&sp->so_delegreturn_mutex);
 	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
 out:
 	request->fl_flags = fl_flags;


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33506 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbcC1VTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 17:19:09 -0400
Received: by mail-ig0-f195.google.com with SMTP id nt3so11734365igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2016 14:19:08 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:1dce])
        by smtp.gmail.com with ESMTPSA id w129sm11127023iof.11.2016.03.28.14.19.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 14:19:07 -0700 (PDT)
Subject: [PATCH RFCv2] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 28 Mar 2016 17:19:06 -0400
Message-ID: <20160328211906.20739.10519.stgit@manet.1015granger.net>
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

To eliminate this race, serialize delegation return with the
acquisition of a file lock on the same file. Adopt the same approach
as is used in the unlock path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 01bef06..dd435f4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6054,6 +6054,7 @@ static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *reques
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
+	struct nfs4_state_owner *sp = state->owner;
 	unsigned char fl_flags = request->fl_flags;
 	int status = -ENOLCK;
 
@@ -6065,9 +6066,12 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status != 0)
 		goto out;
 	request->fl_flags |= FL_ACCESS;
+	mutex_lock(&sp->so_delegreturn_mutex);
 	status = do_vfs_lock(state->inode, request);
-	if (status < 0)
+	if (status < 0) {
+		mutex_unlock(&sp->so_delegreturn_mutex);
 		goto out;
+	}
 	down_read(&nfsi->rwsem);
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
 		/* Yes: cache locks! */
@@ -6075,9 +6079,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
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


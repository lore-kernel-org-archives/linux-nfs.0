Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36243 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbcCaQij (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Mar 2016 12:38:39 -0400
Received: by mail-io0-f196.google.com with SMTP id e3so14270901ioa.3
        for <linux-nfs@vger.kernel.org>; Thu, 31 Mar 2016 09:38:38 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:1dce])
        by smtp.gmail.com with ESMTPSA id 99sm4108454ior.16.2016.03.31.09.38.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 09:38:37 -0700 (PDT)
Subject: [PATCH RFCv3] NFS: Fix an LOCK/OPEN race when unlinking an open file
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 31 Mar 2016 12:38:35 -0400
Message-ID: <20160331163835.2791.6712.stgit@manet.1015granger.net>
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


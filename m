Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:33147 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbcC1PvU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 11:51:20 -0400
Received: by mail-ig0-f195.google.com with SMTP id nt3so10430080igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2016 08:51:19 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:1dce])
        by smtp.gmail.com with ESMTPSA id oq8sm4199817igb.7.2016.03.28.08.51.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 08:51:16 -0700 (PDT)
Subject: [PATCH RFC] xprtrdma: Fix an LOCK/OPEN race when unlinking an open
 file
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 28 Mar 2016 11:51:14 -0400
Message-ID: <20160328155114.19702.71714.stgit@manet.1015granger.net>
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

After the OPEN(CLAIM_DELEG_CUR_FH) returns, the client holds both
a write delegation and a valid open stateid. It is safe to clear
NFS_DELEGATED_STATE at that point, allowing fresh lock requests
to go on the wire using the newly acquired open stateid.

I'm not certain of this fix. nfs4_handle_delegation_recall_error()
is called from both nfs_open_delegation_recall() and
nfs_lock_delegation_recall(). Is it safe and correct to clear
NFS_DELEGATED_STATE after success in both of these code paths?

Fixes: 24311f884189 ('NFSv4: Recovery of recalled read ...')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 01bef06..3ccdc76 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1794,10 +1794,12 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 		default:
 			printk(KERN_ERR "NFS: %s: unhandled error "
 					"%d.\n", __func__, err);
+			break;
 		case 0:
 		case -ENOENT:
 		case -EAGAIN:
 		case -ESTALE:
+			clear_bit(NFS_DELEGATED_STATE, &state->flags);
 			break;
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -1857,7 +1859,6 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
 	write_seqlock(&state->seqlock);
 	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
 	write_sequnlock(&state->seqlock);
-	clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	switch (type & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ|FMODE_WRITE:
 	case FMODE_WRITE:


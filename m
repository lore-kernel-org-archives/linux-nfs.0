From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 52/85] nfs41: increment_{open,lock}_seqid
Date: Mon, 10 Nov 2008 22:27:21 +0200
Message-ID: <1226348841-8961-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59975 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbYKJU11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:27:27 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike minorversion0, in nfsv4.1 the open and lock seqids need
not be incremented by the client and should always be set to zero.

This is implemented using a new nfs_rpc_ops methods -
increment_open_seqid and increment_lock_seqid

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c  |    4 ++++
 fs/nfs/nfs4state.c |   14 +++++++++-----
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 699bbe7..28c3cf8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1757,6 +1757,10 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
 	calldata->arg.stateid = &state->open_stateid;
+	if (server->minorversion) {
+		BUG_ON(server->minorversion != 1);
+		memset(calldata->arg.stateid->data, 0, 4);    /* clear seqid */
+	}
 	/* Serialization for the sequence id */
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
 	if (calldata->arg.seqid == NULL)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0d6b902..6035634 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -747,12 +747,16 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 
 void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid)
 {
-	if (status == -NFS4ERR_BAD_SEQID) {
-		struct nfs4_state_owner *sp = container_of(seqid->sequence,
-				struct nfs4_state_owner, so_seqid);
+	struct nfs4_state_owner *sp = container_of(seqid->sequence,
+					struct nfs4_state_owner, so_seqid);
+	struct nfs_server *server = sp->so_server;
+
+	if (status == -NFS4ERR_BAD_SEQID)
 		nfs4_drop_state_owner(sp);
-	}
-	nfs_increment_seqid(status, seqid);
+	if (server->minorversion == 0)
+		nfs_increment_seqid(status, seqid);
+	else
+		BUG_ON(server->minorversion != 1);
 }
 
 /*
-- 
1.6.0.2


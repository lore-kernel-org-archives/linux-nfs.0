From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 67/67] nfs41: increment_{open,lock}_seqid
Date: Thu,  2 Apr 2009 17:00:27 +0300
Message-ID: <1238680827-15499-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32191 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758330AbZDBOAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 10:00:33 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unlike minorversion0, in nfsv4.1 the open and lock seqids need
not be incremented by the client and should always be set to zero.

This is implemented using a new nfs_rpc_ops methods -
increment_open_seqid and increment_lock_seqid

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: check for session not minorversion]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c  |    2 ++
 fs/nfs/nfs4state.c |   12 +++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f6db7a5..ef3dca3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1820,6 +1820,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
 	calldata->arg.stateid = &state->open_stateid;
+	if (nfs4_has_session(server->nfs_client))
+		memset(calldata->arg.stateid->data, 0, 4);    /* clear seqid */
 	/* Serialization for the sequence id */
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
 	if (calldata->arg.seqid == NULL)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7dc9713..c16f24d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -742,12 +742,14 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 
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
+	if (!nfs4_has_session(server->nfs_client))
+		nfs_increment_seqid(status, seqid);
 }
 
 /*
-- 
1.6.2.1


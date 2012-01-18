Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62013 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756965Ab2ARERg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 23:17:36 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/10] NFSv4: Clean up nfs4_get_state_owner
Date: Tue, 17 Jan 2012 23:17:05 -0500
Message-Id: <1326860233-27947-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1326860233-27947-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |    2 +-
 fs/nfs/nfs4state.c |   24 +++++++++++-------------
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4d7d0ae..6d439c2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -319,7 +319,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session)
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
+extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *, gfp_t);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
 extern void nfs4_purge_state_owners(struct nfs_server *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f0c849c..4072754 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1754,7 +1754,7 @@ static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, fmode_t fmode
 
 	/* Protect against reboot recovery conflicts */
 	status = -ENOMEM;
-	if (!(sp = nfs4_get_state_owner(server, cred))) {
+	if (!(sp = nfs4_get_state_owner(server, cred, GFP_KERNEL))) {
 		dprintk("nfs4_do_open: nfs4_get_state_owner failed!\n");
 		goto out_err;
 	}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a53f33b..a8a42a6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -444,13 +444,17 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
  *
  */
 static struct nfs4_state_owner *
-nfs4_alloc_state_owner(void)
+nfs4_alloc_state_owner(struct nfs_server *server,
+		struct rpc_cred *cred,
+		gfp_t gfp_flags)
 {
 	struct nfs4_state_owner *sp;
 
-	sp = kzalloc(sizeof(*sp),GFP_NOFS);
+	sp = kzalloc(sizeof(*sp), gfp_flags);
 	if (!sp)
 		return NULL;
+	sp->so_server = server;
+	sp->so_cred = get_rpccred(cred);
 	spin_lock_init(&sp->so_lock);
 	INIT_LIST_HEAD(&sp->so_states);
 	rpc_init_wait_queue(&sp->so_sequence.wait, "Seqid_waitqueue");
@@ -516,7 +520,8 @@ static void nfs4_gc_state_owners(struct nfs_server *server)
  * Returns a pointer to an instantiated nfs4_state_owner struct, or NULL.
  */
 struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
-					      struct rpc_cred *cred)
+					      struct rpc_cred *cred,
+					      gfp_t gfp_flags)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state_owner *sp, *new;
@@ -526,20 +531,13 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 	spin_unlock(&clp->cl_lock);
 	if (sp != NULL)
 		goto out;
-	new = nfs4_alloc_state_owner();
+	new = nfs4_alloc_state_owner(server, cred, gfp_flags);
 	if (new == NULL)
 		goto out;
-	new->so_server = server;
-	new->so_cred = cred;
-	spin_lock(&clp->cl_lock);
 	sp = nfs4_insert_state_owner_locked(new);
 	spin_unlock(&clp->cl_lock);
-	if (sp == new)
-		get_rpccred(cred);
-	else {
-		rpc_destroy_wait_queue(&new->so_sequence.wait);
-		kfree(new);
-	}
+	if (sp != new)
+		nfs4_free_state_owner(new);
 out:
 	nfs4_gc_state_owners(server);
 	return sp;
-- 
1.7.7.5


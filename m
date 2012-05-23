Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57765 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760650Ab2EWRcv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 13:32:51 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 2/3] NFSv4: Fix a race in the net namespace mount notification
Date: Wed, 23 May 2012 13:32:42 -0400
Message-Id: <1337794363-11905-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337794363-11905-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1337794363-11905-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the struct nfs_client gets added to the global nfs_client_list
before it is initialised, it is possible that rpc_pipefs_event can
end up trying to create idmapper entries on such a thing.

The solution is to have the mount notification wait for the
initialisation of each nfs_client to complete, and then to
skip any entries for which the it failed.

Reported-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/client.c   |   16 +++++++++++++---
 fs/nfs/idmap.c    |   15 +++++++++++++++
 fs/nfs/internal.h |    1 +
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 78970a1..e6070ea 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -504,6 +504,17 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 	return NULL;
 }
 
+static bool nfs_client_init_is_complete(const struct nfs_client *clp)
+{
+	return clp->cl_cons_state != NFS_CS_INITING;
+}
+
+int nfs_wait_client_init_complete(const struct nfs_client *clp)
+{
+	return wait_event_killable(nfs_client_active_wq,
+			nfs_client_init_is_complete(clp));
+}
+
 /*
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
@@ -564,8 +575,7 @@ found_client:
 	if (new)
 		nfs_free_client(new);
 
-	error = wait_event_killable(nfs_client_active_wq,
-				clp->cl_cons_state < NFS_CS_INITING);
+	error = nfs_wait_client_init_complete(clp);
 	if (error < 0) {
 		nfs_put_client(clp);
 		return ERR_PTR(-ERESTARTSYS);
@@ -1317,7 +1327,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 		 * so that the client back channel can find the
 		 * nfs_client struct
 		 */
-		clp->cl_cons_state = NFS_CS_SESSION_INITING;
+		nfs_mark_client_ready(clp, NFS_CS_SESSION_INITING);
 	}
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 3e8edbe..6ca949b 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -530,9 +530,24 @@ static struct nfs_client *nfs_get_client_for_event(struct net *net, int event)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct dentry *cl_dentry;
 	struct nfs_client *clp;
+	int err;
 
+restart:
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
+		/* Wait for initialisation to finish */
+		if (clp->cl_cons_state == NFS_CS_INITING) {
+			atomic_inc(&clp->cl_count);
+			spin_unlock(&nn->nfs_client_lock);
+			err = nfs_wait_client_init_complete(clp);
+			nfs_put_client(clp);
+			if (err)
+				return NULL;
+			goto restart;
+		}
+		/* Skip nfs_clients that failed to initialise */
+		if (clp->cl_cons_state < 0)
+			continue;
 		if (clp->rpc_ops != &nfs_v4_clientops)
 			continue;
 		cl_dentry = clp->cl_idmap->idmap_pipe->dentry;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 00b66de..a23daa9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -167,6 +167,7 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
 					   struct nfs_fattr *,
 					   rpc_authflavor_t);
+extern int nfs_wait_client_init_complete(const struct nfs_client *clp);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
-- 
1.7.7.6


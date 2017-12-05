Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4465 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752410AbdLESzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 13:55:44 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3] nfs: fix a deadlock in nfs client initialization
Date: Tue,  5 Dec 2017 13:55:44 -0500
Message-Id: <20171205185544.22870-1-smayhew@redhat.com>
In-Reply-To: <1512139349.27358.2.camel@primarydata.com>
References: <1512139349.27358.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following deadlock can occur between a process waiting for a client
to initialize in while walking the client list during nfsv4 server trunking
detection and another process waiting for the nfs_clid_init_mutex so it
can initialize that client:

Process 1                               Process 2
---------                               ---------
spin_lock(&nn->nfs_client_lock);
list_add_tail(&CLIENTA->cl_share_link,
        &nn->nfs_client_list);
spin_unlock(&nn->nfs_client_lock);
                                        spin_lock(&nn->nfs_client_lock);
                                        list_add_tail(&CLIENTB->cl_share_link,
                                                &nn->nfs_client_list);
                                        spin_unlock(&nn->nfs_client_lock);
                                        mutex_lock(&nfs_clid_init_mutex);
                                        nfs41_walk_client_list(clp, result, cred);
                                        nfs_wait_client_init_complete(CLIENTA);
(waiting for nfs_clid_init_mutex)

Make sure nfs_match_client() only evaluates clients that have completed
initialization in order to prevent that deadlock.

This patch also fixes v4.0 trunking behavior by not marking the client
NFS_CS_READY until the clientid has been confirmed.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/client.c     | 11 +++++++++++
 fs/nfs/nfs4client.c | 17 +++++++++++++----
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 0ac2fb1..b9129e2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -291,12 +291,23 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 	const struct sockaddr *sap = data->addr;
 	struct nfs_net *nn = net_generic(data->net, nfs_net_id);
 
+again:
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
 
+		/* If a client is still initializing then we need to wait */
+		if (clp->cl_cons_state > NFS_CS_READY) {
+			refcount_inc(&clp->cl_count);
+			spin_unlock(&nn->nfs_client_lock);
+			nfs_wait_client_init_complete(clp);
+			nfs_put_client(clp);
+			spin_lock(&nn->nfs_client_lock);
+			goto again;
+		}
+
 		/* Different NFS versions cannot share the same nfs_client */
 		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
 			continue;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 12bbab0..65a7e5d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -404,15 +404,19 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 	if (error < 0)
 		goto error;
 
-	if (!nfs4_has_session(clp))
-		nfs_mark_client_ready(clp, NFS_CS_READY);
-
 	error = nfs4_discover_server_trunking(clp, &old);
 	if (error < 0)
 		goto error;
 
-	if (clp != old)
+	if (clp != old) {
 		clp->cl_preserve_clid = true;
+		/*
+		 * Mark the client as having failed initialization so other
+		 * processes walking the nfs_client_list in nfs_match_client()
+		 * won't try to use it.
+		 */
+		nfs_mark_client_ready(clp, -EPERM);
+	}
 	nfs_put_client(clp);
 	clear_bit(NFS_CS_TSM_POSSIBLE, &clp->cl_flags);
 	return old;
@@ -539,6 +543,9 @@ int nfs40_walk_client_list(struct nfs_client *new,
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
 
+		if (pos == new)
+			goto found;
+
 		status = nfs4_match_client(pos, new, &prev, nn);
 		if (status < 0)
 			goto out_unlock;
@@ -559,6 +566,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		 * way that a SETCLIENTID_CONFIRM to pos can succeed is
 		 * if new and pos point to the same server:
 		 */
+found:
 		refcount_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
@@ -572,6 +580,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		case 0:
 			nfs4_swap_callback_idents(pos, new);
 			pos->cl_confirm = new->cl_confirm;
+			nfs_mark_client_ready(pos, NFS_CS_READY);
 
 			prev = NULL;
 			*result = pos;
-- 
2.9.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42786 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968102Ab2ERWFo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 18:05:44 -0400
Received: by yhmm54 with SMTP id m54so3385192yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2012 15:05:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/14] NFS: Use proper naming conventions for
 nfs_client.impl_id field
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 18 May 2012 18:05:41 -0400
Message-ID: <20120518220541.774.82062.stgit@degas.1015granger.net>
In-Reply-To: <20120518220145.774.53741.stgit@degas.1015granger.net>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  When naming fields and data types, follow established
conventions to facilitate accurate grep/cscope searches.

Additionally, for consistency, move the impl_id field into the NFSv4-
specific part of the nfs_client, and free that memory in the logic
that shuts down NFSv4 nfs_clients.

Introduced by commit 7d2ed9ac "NFSv4: parse and display server
implementation ids," Fri Feb 17, 2012.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    2 +-
 fs/nfs/nfs4proc.c         |   12 ++++++------
 fs/nfs/super.c            |    4 ++--
 include/linux/nfs_fs_sb.h |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1285f70..ec5a276 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -236,6 +236,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
 	kfree(clp->cl_serverscope);
+	kfree(clp->cl_implid);
 }
 
 /* idr_remove_all is not needed as all id's are removed by nfs_put_client */
@@ -304,7 +305,6 @@ static void nfs_free_client(struct nfs_client *clp)
 
 	put_net(clp->net);
 	kfree(clp->cl_hostname);
-	kfree(clp->impl_id);
 	kfree(clp);
 
 	dprintk("<-- nfs_free_client()\n");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 35585ef..386a756 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5147,8 +5147,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 
 	if (!status) {
 		/* use the most recent implementation id */
-		kfree(clp->impl_id);
-		clp->impl_id = res.impl_id;
+		kfree(clp->cl_implid);
+		clp->cl_implid = res.impl_id;
 	} else
 		kfree(res.impl_id);
 
@@ -5172,12 +5172,12 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 out_server_scope:
 	kfree(res.server_scope);
 out:
-	if (clp->impl_id)
+	if (clp->cl_implid)
 		dprintk("%s: Server Implementation ID: "
 			"domain: %s, name: %s, date: %llu,%u\n",
-			__func__, clp->impl_id->domain, clp->impl_id->name,
-			clp->impl_id->date.seconds,
-			clp->impl_id->date.nseconds);
+			__func__, clp->cl_implid->domain, clp->cl_implid->name,
+			clp->cl_implid->date.seconds,
+			clp->cl_implid->date.nseconds);
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4ac7fca..2c5390e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -786,8 +786,8 @@ static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 
 static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 {
-	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
-		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
+	if (nfss->nfs_client && nfss->nfs_client->cl_implid) {
+		struct nfs41_impl_id *impl_id = nfss->nfs_client->cl_implid;
 		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
 			   "date='%llu,%u'",
 			   impl_id->name, impl_id->domain,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 900d733..773e021 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -81,13 +81,13 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session;	/* shared session */
 	struct nfs41_server_scope *cl_serverscope;
+	struct nfs41_impl_id	*cl_implid;
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
 
-	struct nfs41_impl_id	*impl_id;	/* from exchange_id */
 	struct net		*net;
 };
 


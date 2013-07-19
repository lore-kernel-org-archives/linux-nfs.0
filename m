Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26225 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574Ab3GSVGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 17:06:44 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 1/2] NFS Remove unused authflavour parameter from init_client
Date: Fri, 19 Jul 2013 17:06:36 -0400
Message-ID: <1374267997-4305-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c         | 6 ++----
 fs/nfs/internal.h       | 5 ++---
 fs/nfs/nfs4client.c     | 3 +--
 include/linux/nfs_xdr.h | 2 +-
 4 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 340b1ef..2dceee4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -501,8 +501,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 					&nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
 			new->cl_flags = cl_init->init_flags;
-			return rpc_ops->init_client(new, timeparms, ip_addr,
-						    authflavour);
+			return rpc_ops->init_client(new, timeparms, ip_addr);
 		}
 
 		spin_unlock(&nn->nfs_client_lock);
@@ -694,13 +693,12 @@ EXPORT_SYMBOL_GPL(nfs_init_server_rpcclient);
  * @clp: nfs_client to initialise
  * @timeparms: timeout parameters for underlying RPC transport
  * @ip_addr: IP presentation address (not used)
- * @authflavor: authentication flavor for underlying RPC transport
  *
  * Returns pointer to an NFS client, or an ERR_PTR value.
  */
 struct nfs_client *nfs_init_client(struct nfs_client *clp,
 		    const struct rpc_timeout *timeparms,
-		    const char *ip_addr, rpc_authflavor_t authflavour)
+		    const char *ip_addr)
 {
 	int error;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3c8373f..9b694f1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -267,7 +267,7 @@ extern struct rpc_procinfo nfs4_procedures[];
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const struct rpc_timeout *timeparms,
-			   const char *ip_addr, rpc_authflavor_t authflavour);
+			   const char *ip_addr);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
@@ -451,8 +451,7 @@ extern ssize_t nfs_dreq_bytes_left(struct nfs_direct_req *dreq);
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
 extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
-			    const char *ip_addr,
-			    rpc_authflavor_t authflavour);
+			    const char *ip_addr);
 extern int nfs40_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
 				struct rpc_cred *cred);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 90dce91..767a5e3 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -187,8 +187,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
  */
 struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    const struct rpc_timeout *timeparms,
-				    const char *ip_addr,
-				    rpc_authflavor_t authflavour)
+				    const char *ip_addr)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
 	struct nfs_client *old;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8651574..ddc3e32 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1442,7 +1442,7 @@ struct nfs_rpc_ops {
 	struct nfs_client *(*alloc_client) (const struct nfs_client_initdata *);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
-				const char *, rpc_authflavor_t);
+				const char *);
 	void	(*free_client) (struct nfs_client *);
 	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
 	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
-- 
1.8.3.1


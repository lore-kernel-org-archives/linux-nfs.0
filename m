Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585Ab2DWUy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:54:59 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:54:58 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/20] NFS: Refactor nfs_get_client(): initialize nfs_client
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:54:56 -0400
Message-ID: <20120423205456.11446.73723.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Continue to rationalize the locking in nfs_get_client() by
moving the logic that handles the case where a matching server IP
address is not found.

When we support server trunking detection, client initialization may
return a different nfs_client struct than was passed to it.  Change
the synopsis of the init_client methods to return an nfs_client.

The client initialization logic in nfs_get_client() is not much more
than a wrapper around ->init_client.  It's simpler to keep the little
bits of error handling in the version-specific init_client methods.

No behavior change is expected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c         |   52 ++++++++++++++++++++---------------------------
 fs/nfs/internal.h       |   19 +++++++++--------
 include/linux/nfs_xdr.h |    3 ++-
 3 files changed, 34 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 09b3f55..d62f7e4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -548,7 +548,6 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       int noresvport)
 {
 	struct nfs_client *clp, *new = NULL;
-	int error;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
 
 	dprintk("--> nfs_get_client(%s,v%u)\n",
@@ -565,8 +564,13 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 				nfs_free_client(new);
 			return nfs_found_client(cl_init, clp);
 		}
-		if (new)
-			goto install_client;
+		if (new) {
+			list_add(&new->cl_share_link, &nn->nfs_client_list);
+			spin_unlock(&nn->nfs_client_lock);
+			return cl_init->rpc_ops->init_client(new,
+						timeparms, ip_addr,
+						authflavour, noresvport);
+		}
 
 		spin_unlock(&nn->nfs_client_lock);
 
@@ -576,21 +580,6 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
 		cl_init->hostname ?: "", PTR_ERR(new));
 	return new;
-
-	/* install a new client and return with it unready */
-install_client:
-	clp = new;
-	list_add(&clp->cl_share_link, &nn->nfs_client_list);
-	spin_unlock(&nn->nfs_client_lock);
-
-	error = cl_init->rpc_ops->init_client(clp, timeparms, ip_addr,
-					      authflavour, noresvport);
-	if (error < 0) {
-		nfs_put_client(clp);
-		return ERR_PTR(error);
-	}
-	dprintk("--> nfs_get_client() = %p [new]\n", clp);
-	return clp;
 }
 
 /*
@@ -818,7 +807,8 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 /*
  * Initialise an NFS2 or NFS3 client
  */
-int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
+struct nfs_client *nfs_init_client(struct nfs_client *clp,
+		    const struct rpc_timeout *timeparms,
 		    const char *ip_addr, rpc_authflavor_t authflavour,
 		    int noresvport)
 {
@@ -827,7 +817,7 @@ int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is already initialised */
 		dprintk("<-- nfs_init_client() = 0 [already %p]\n", clp);
-		return 0;
+		return clp;
 	}
 
 	/*
@@ -839,12 +829,13 @@ int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
-	return 0;
+	return clp;
 
 error:
 	nfs_mark_client_ready(clp, error);
+	nfs_put_client(clp);
 	dprintk("<-- nfs_init_client() = xerror %d\n", error);
-	return error;
+	return ERR_PTR(error);
 }
 
 /*
@@ -1353,11 +1344,11 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 /*
  * Initialise an NFS4 client record
  */
-int nfs4_init_client(struct nfs_client *clp,
-		     const struct rpc_timeout *timeparms,
-		     const char *ip_addr,
-		     rpc_authflavor_t authflavour,
-		     int noresvport)
+struct nfs_client *nfs4_init_client(struct nfs_client *clp,
+				    const struct rpc_timeout *timeparms,
+				    const char *ip_addr,
+				    rpc_authflavor_t authflavour,
+				    int noresvport)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
 	int error;
@@ -1365,7 +1356,7 @@ int nfs4_init_client(struct nfs_client *clp,
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is initialised already */
 		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
-		return 0;
+		return clp;
 	}
 
 	/* Check NFS protocol revision and initialize RPC op vector */
@@ -1405,12 +1396,13 @@ int nfs4_init_client(struct nfs_client *clp,
 
 	if (!nfs4_has_session(clp))
 		nfs_mark_client_ready(clp, NFS_CS_READY);
-	return 0;
+	return clp;
 
 error:
 	nfs_mark_client_ready(clp, error);
+	nfs_put_client(clp);
 	dprintk("<-- nfs4_init_client() = xerror %d\n", error);
-	return error;
+	return ERR_PTR(error);
 }
 
 /*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index faf15eb..f1021c8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -154,6 +154,16 @@ extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 				struct nfs4_sessionid *);
+extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
+				const struct rpc_timeout *timeparms,
+				const char *ip_addr,
+				rpc_authflavor_t authflavour,
+				int noresvport);
+extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
+				const struct rpc_timeout *timeparms,
+				const char *ip_addr,
+				rpc_authflavor_t authflavour,
+				int noresvport);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
@@ -241,10 +251,6 @@ extern int nfs4_init_ds_session(struct nfs_client *clp);
 
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
-extern int nfs_init_client(struct nfs_client *clp,
-			   const struct rpc_timeout *timeparms,
-			   const char *ip_addr, rpc_authflavor_t authflavour,
-			   int noresvport);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
@@ -345,11 +351,6 @@ extern int nfs_migrate_page(struct address_space *,
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
 extern void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data);
-extern int nfs4_init_client(struct nfs_client *clp,
-			    const struct rpc_timeout *timeparms,
-			    const char *ip_addr,
-			    rpc_authflavor_t authflavour,
-			    int noresvport);
 extern void nfs4_reset_write(struct rpc_task *task, struct nfs_write_data *data);
 extern int _nfs4_call_sync(struct rpc_clnt *clnt,
 			   struct nfs_server *server,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ece705d..7437931 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1284,7 +1284,8 @@ struct nfs_rpc_ops {
 				struct nfs_open_context *ctx,
 				int open_flags,
 				struct iattr *iattr);
-	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
+	struct nfs_client *
+		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
 	int	(*secinfo)(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
 };


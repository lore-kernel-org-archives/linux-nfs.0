Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42512 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082Ab2EVCqB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:46:01 -0400
Received: by mail-yx0-f174.google.com with SMTP id m10so4991681yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:46:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/14] NFS: Refactor nfs_get_client(): initialize nfs_client
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:45:59 -0400
Message-ID: <20120522024559.1787.46820.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
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

 fs/nfs/client.c         |   76 ++++++++++++++++++++++++++---------------------
 fs/nfs/internal.h       |    4 +-
 include/linux/nfs_xdr.h |    3 +-
 3 files changed, 46 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5f19f95..8a4b3c2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -546,7 +546,6 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	       int noresvport)
 {
 	struct nfs_client *clp, *new = NULL;
-	int error;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
 
 	dprintk("--> nfs_get_client(%s,v%u)\n",
@@ -563,8 +562,13 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
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
 
@@ -574,21 +578,6 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
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
@@ -813,10 +802,19 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 	return 0;
 }
 
-/*
- * Initialise an NFS2 or NFS3 client
+/**
+ * nfs_init_client - Initialise an NFS2 or NFS3 client
+ *
+ * @clp: nfs_client to initialise
+ * @timeparms: timeout parameters for underlying RPC transport
+ * @ip_addr: IP presentation address (not used)
+ * @authflavor: authentication flavor for underlying RPC transport
+ * @noresvport: set if RPC transport can use an ephemeral source port
+ *
+ * Returns pointer to an NFS client, or an ERR_PTR value.
  */
-int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
+struct nfs_client *nfs_init_client(struct nfs_client *clp,
+		    const struct rpc_timeout *timeparms,
 		    const char *ip_addr, rpc_authflavor_t authflavour,
 		    int noresvport)
 {
@@ -825,7 +823,7 @@ int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is already initialised */
 		dprintk("<-- nfs_init_client() = 0 [already %p]\n", clp);
-		return 0;
+		return clp;
 	}
 
 	/*
@@ -837,12 +835,13 @@ int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
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
@@ -1358,14 +1357,22 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 	return nfs4_init_callback(clp);
 }
 
-/*
- * Initialise an NFS4 client record
+/**
+ * nfs4_init_client - Initialise an NFS4 client record
+ *
+ * @clp: nfs_client to initialise
+ * @timeparms: timeout parameters for underlying RPC transport
+ * @ip_addr: callback IP address in presentation format
+ * @authflavor: authentication flavor for underlying RPC transport
+ * @noresvport: set if RPC transport can use an ephemeral source port
+ *
+ * Returns pointer to an NFS client, or an ERR_PTR value.
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
@@ -1373,7 +1380,7 @@ int nfs4_init_client(struct nfs_client *clp,
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is initialised already */
 		dprintk("<-- nfs4_init_client() = 0 [already %p]\n", clp);
-		return 0;
+		return clp;
 	}
 
 	/* Check NFS protocol revision and initialize RPC op vector */
@@ -1413,12 +1420,13 @@ int nfs4_init_client(struct nfs_client *clp,
 
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
index 989959a..3a9e80c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -238,7 +238,7 @@ extern int nfs4_init_ds_session(struct nfs_client *clp);
 
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
-extern int nfs_init_client(struct nfs_client *clp,
+extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const struct rpc_timeout *timeparms,
 			   const char *ip_addr, rpc_authflavor_t authflavour,
 			   int noresvport);
@@ -373,7 +373,7 @@ void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 
 /* nfs4proc.c */
 extern void __nfs4_read_done_cb(struct nfs_read_data *);
-extern int nfs4_init_client(struct nfs_client *clp,
+extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct rpc_timeout *timeparms,
 			    const char *ip_addr,
 			    rpc_authflavor_t authflavour,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c420b8d..0c521cd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1397,7 +1397,8 @@ struct nfs_rpc_ops {
 				struct nfs_open_context *ctx,
 				int open_flags,
 				struct iattr *iattr);
-	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
+	struct nfs_client *
+		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t, int);
 };
 


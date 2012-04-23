Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab2DWUzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:46 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/20] NFS: EXCHANGE_ID should save the server major and minor
 ID
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:44 -0400
Message-ID: <20120423205543.11446.43244.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To detect server trunking, we need to have the server major and minor
ID available in each server's struct nfs_client.  Currently these are
being discarded in the XDR decoder for EXCHANGE_ID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4proc.c         |   18 +++++++++++++++++-
 fs/nfs/nfs4xdr.c          |   13 ++++++++-----
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_xdr.h   |    3 ++-
 5 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 07b106e..920abbc 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -235,6 +235,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 		nfs_idmap_delete(clp);
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+	kfree(clp->cl_serverowner);
 	kfree(clp->cl_serverscope);
 	kfree(clp->cl_implid);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9fe19d4..3fd9944 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5098,11 +5098,19 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 	nfs4_init_boot_verifier(clp, &verifier);
 	args.id_len = nfs4_init_uniform_client_string(clp, args.id,
 							sizeof(args.id));
+
+	res.server_owner = kzalloc(sizeof(struct nfs41_server_owner),
+					GFP_KERNEL);
+	if (unlikely(res.server_owner == NULL)) {
+		status = -ENOMEM;
+		goto out;
+	}
+
 	res.server_scope = kzalloc(sizeof(struct nfs41_server_scope),
 					GFP_KERNEL);
 	if (unlikely(res.server_scope == NULL)) {
 		status = -ENOMEM;
-		goto out;
+		goto out_server_owner;
 	}
 
 	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_KERNEL);
@@ -5116,6 +5124,12 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 
 	if (status == NFS4_OK) {
+		kfree(clp->cl_serverowner);
+		clp->cl_serverowner = res.server_owner;
+		res.server_owner = NULL;
+	}
+
+	if (status == NFS4_OK) {
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
@@ -5139,6 +5153,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		}
 	}
 
+out_server_owner:
+	kfree(res.server_owner);
 out_server_scope:
 	kfree(res.server_scope);
 out:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 312f619..3cf7519 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5163,24 +5163,27 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	if (dummy != SP4_NONE)
 		return -EIO;
 
-	/* Throw away minor_id */
+	/* server_owner4.so_minor_id */
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
+	p = xdr_decode_hyper(p, &res->server_owner->minor_id);
 
-	/* Throw away Major id */
+	/* server_owner4.so_major_id */
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
 		return status;
+	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+		return -EIO;
+	memcpy(res->server_owner->major_id, dummy_str, dummy);
+	res->server_owner->major_id_sz = dummy;
 
-	/* Save server_scope */
+	/* server_scope4 */
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
 	if (unlikely(status))
 		return status;
-
 	if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
 		return -EIO;
-
 	memcpy(res->server_scope->server_scope, dummy_str, dummy);
 	res->server_scope->server_scope_sz = dummy;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 1a5a4cc..597ada7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -80,6 +80,7 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session;	/* shared session */
+	struct nfs41_server_owner *cl_serverowner;
 	struct nfs41_server_scope *cl_serverscope;
 	struct nfs41_impl_id	*cl_implid;
 #endif /* CONFIG_NFS_V4 */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1fbca8b..6c4a856 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1067,7 +1067,7 @@ struct nfs41_exchange_id_args {
 	u32				flags;
 };
 
-struct server_owner {
+struct nfs41_server_owner {
 	uint64_t			minor_id;
 	uint32_t			major_id_sz;
 	char				major_id[NFS4_OPAQUE_LIMIT];
@@ -1087,6 +1087,7 @@ struct nfs41_impl_id {
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
+	struct nfs41_server_owner	*server_owner;
 	struct nfs41_server_scope	*server_scope;
 	struct nfs41_impl_id		*impl_id;
 };


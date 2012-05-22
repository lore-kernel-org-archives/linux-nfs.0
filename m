Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39388 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757169Ab2EVCqU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 22:46:20 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so5054100yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 19:46:19 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/14] NFS: EXCHANGE_ID should save the server major and minor
 ID
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 21 May 2012 22:46:16 -0400
Message-ID: <20120522024616.1787.32939.stgit@degas.1015granger.net>
In-Reply-To: <20120522022702.1787.45940.stgit@degas.1015granger.net>
References: <20120522022702.1787.45940.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save the server major and minor ID results from EXCHANGE_ID, as they
are needed for detecting server trunking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4proc.c         |   17 ++++++++++++++++-
 fs/nfs/nfs4xdr.c          |   13 ++++++++-----
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_xdr.h   |    3 ++-
 5 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 34b2e68..3c14468 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -237,6 +237,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 		nfs_idmap_delete(clp);
 
 	rpc_destroy_wait_queue(&clp->cl_rpcwaitq);
+	kfree(clp->cl_serverowner);
 	kfree(clp->cl_serverscope);
 	kfree(clp->cl_implid);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e9334a..0d46fe4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5109,11 +5109,18 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 				clp->cl_rpcclient->cl_nodename,
 				clp->cl_rpcclient->cl_auth->au_flavor);
 
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
@@ -5127,6 +5134,12 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 
 	if (status == 0) {
+		kfree(clp->cl_serverowner);
+		clp->cl_serverowner = res.server_owner;
+		res.server_owner = NULL;
+	}
+
+	if (status == 0) {
 		/* use the most recent implementation id */
 		kfree(clp->cl_implid);
 		clp->cl_implid = res.impl_id;
@@ -5150,6 +5163,8 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		}
 	}
 
+out_server_owner:
+	kfree(res.server_owner);
 out_server_scope:
 	kfree(res.server_scope);
 out:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 12b9982..5ad2b2c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5144,24 +5144,27 @@ static int decode_exchange_id(struct xdr_stream *xdr,
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
index 3a99f52..fbb78fb 100644
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
index 07048c0..0872f32 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1098,7 +1098,7 @@ struct nfs41_exchange_id_args {
 	u32				flags;
 };
 
-struct server_owner {
+struct nfs41_server_owner {
 	uint64_t			minor_id;
 	uint32_t			major_id_sz;
 	char				major_id[NFS4_OPAQUE_LIMIT];
@@ -1118,6 +1118,7 @@ struct nfs41_impl_id {
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
+	struct nfs41_server_owner	*server_owner;
 	struct nfs41_server_scope	*server_scope;
 	struct nfs41_impl_id		*impl_id;
 };


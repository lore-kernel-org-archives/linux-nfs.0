Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab2BQUUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 15:20:42 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/3] NFSv4: parse and display server implementation ids
Date: Fri, 17 Feb 2012 15:20:26 -0500
Message-Id: <1329510026-30403-3-git-send-email-dros@netapp.com>
In-Reply-To: <1329510026-30403-1-git-send-email-dros@netapp.com>
References: <1329510026-30403-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Shows the implementation ids in /proc/self/mountstats.  This doesn't break
the nfs-utils mountstats tool.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4proc.c         |   21 +++++++++++++++++++++
 fs/nfs/nfs4xdr.c          |   42 +++++++++++++++++++++++++++++++++++++-----
 fs/nfs/super.c            |    8 ++++++++
 include/linux/nfs_fs_sb.h |    2 ++
 include/linux/nfs_xdr.h   |   15 +++++++--------
 6 files changed, 76 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0f850f..3fd9a47 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -302,6 +302,7 @@ static void nfs_free_client(struct nfs_client *clp)
 
 	kfree(clp->cl_hostname);
 	kfree(clp->server_scope);
+	kfree(clp->impl_id);
 	kfree(clp);
 
 	dprintk("<-- nfs_free_client()\n");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 20c3bb0..90a17cc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4950,11 +4950,24 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 		goto out;
 	}
 
+	res.impl_id = kzalloc(sizeof(struct nfs41_impl_id), GFP_KERNEL);
+	if (unlikely(!res.impl_id)) {
+		status = -ENOMEM;
+		goto out_server_scope;
+	}
+
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (!status)
 		status = nfs4_check_cl_exchange_flags(clp->cl_exchange_flags);
 
 	if (!status) {
+		/* use the most recent implementation id */
+		kfree(clp->impl_id);
+		clp->impl_id = res.impl_id;
+	} else
+		kfree(res.impl_id);
+
+	if (!status) {
 		if (clp->server_scope &&
 		    !nfs41_same_server_scope(clp->server_scope,
 					     res.server_scope)) {
@@ -4970,8 +4983,16 @@ int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 			goto out;
 		}
 	}
+
+out_server_scope:
 	kfree(res.server_scope);
 out:
+	if (clp->impl_id)
+		dprintk("%s: Server Implementation ID: "
+			"domain: %s, name: %s, date: %llu,%u\n",
+			__func__, clp->impl_id->domain, clp->impl_id->name,
+			clp->impl_id->date.seconds,
+			clp->impl_id->date.nseconds);
 	dprintk("<-- %s status= %d\n", __func__, status);
 	return status;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d824aed..b7c0433 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -291,7 +291,11 @@ static int nfs4_stat_to_errno(int);
 				/* eir_server_scope<> */ \
 				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1 + \
 				1 /* eir_server_impl_id array length */ + \
-				0 /* ignored eir_server_impl_id contents */)
+				1 /* nii_domain */ + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+				1 /* nii_name */ + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
+				3 /* nii_date */)
 #define encode_channel_attrs_maxsz  (6 + 1 /* ca_rdma_ird.len (0) */)
 #define decode_channel_attrs_maxsz  (6 + \
 				     1 /* ca_rdma_ird.len */ + \
@@ -5256,6 +5260,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	char *dummy_str;
 	int status;
 	struct nfs_client *clp = res->client;
+	uint32_t impl_id_count;
 
 	status = decode_op_hdr(xdr, OP_EXCHANGE_ID);
 	if (status)
@@ -5297,11 +5302,38 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	memcpy(res->server_scope->server_scope, dummy_str, dummy);
 	res->server_scope->server_scope_sz = dummy;
 
-	/* Throw away Implementation id array */
-	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
-	if (unlikely(status))
-		return status;
+	/* Implementation Id */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	impl_id_count = be32_to_cpup(p++);
 
+	if (impl_id_count) {
+		/* nii_domain */
+		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+		if (unlikely(status))
+			return status;
+		if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+			return -EIO;
+		memcpy(res->impl_id->domain, dummy_str, dummy);
+
+		/* nii_name */
+		status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+		if (unlikely(status))
+			return status;
+		if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
+			return -EIO;
+		memcpy(res->impl_id->name, dummy_str, dummy);
+
+		/* nii_date */
+		p = xdr_inline_decode(xdr, 12);
+		if (unlikely(!p))
+			goto out_overflow;
+		p = xdr_decode_hyper(p, &res->impl_id->date.seconds);
+		res->impl_id->date.nseconds = be32_to_cpup(p);
+
+		/* if there's more than one entry, ignore the rest */
+	}
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d05024a..5462225 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -809,6 +809,14 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
 
 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
 
+	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
+		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
+		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
+			   "date='%llu,%u'",
+			   impl_id->name, impl_id->domain,
+			   impl_id->date.seconds, impl_id->date.nseconds);
+	}
+
 	seq_printf(m, "\n\tcaps:\t");
 	seq_printf(m, "caps=0x%x", nfss->caps);
 	seq_printf(m, ",wtmult=%u", nfss->wtmult);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3bf4766..03d0b91 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -18,6 +18,7 @@ struct nfs4_sequence_res;
 struct nfs_server;
 struct nfs4_minor_version_ops;
 struct server_scope;
+struct nfs41_impl_id;
 
 /*
  * The nfs_client identifies our client state to the server.
@@ -86,6 +87,7 @@ struct nfs_client {
 #endif
 
 	struct server_scope	*server_scope;	/* from exchange_id */
+	struct nfs41_impl_id	*impl_id;	/* from exchange_id */
 	struct net		*net;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index adbc84a..046c1bf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1054,14 +1054,6 @@ struct nfstime4 {
 };
 
 #ifdef CONFIG_NFS_V4_1
-struct nfs_impl_id4 {
-	u32		domain_len;
-	char		*domain;
-	u32		name_len;
-	char		*name;
-	struct nfstime4	date;
-};
-
 #define NFS4_EXCHANGE_ID_LEN	(48)
 struct nfs41_exchange_id_args {
 	struct nfs_client		*client;
@@ -1082,10 +1074,17 @@ struct server_scope {
 	char 				server_scope[NFS4_OPAQUE_LIMIT];
 };
 
+struct nfs41_impl_id {
+	char				domain[NFS4_OPAQUE_LIMIT + 1];
+	char				name[NFS4_OPAQUE_LIMIT + 1];
+	struct nfstime4			date;
+};
+
 struct nfs41_exchange_id_res {
 	struct nfs_client		*client;
 	u32				flags;
 	struct server_scope		*server_scope;
+	struct nfs41_impl_id		*impl_id;
 };
 
 struct nfs41_create_session_args {
-- 
1.7.4.4


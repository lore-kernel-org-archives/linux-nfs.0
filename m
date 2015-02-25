Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:25255 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbbBYUc4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Feb 2015 15:32:56 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2] NFS: Don't zap caches on fallocate()
Date: Wed, 25 Feb 2015 15:32:52 -0500
Message-ID: <1424896372-20531-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds a GETATTR to the end of ALLOCATE and DEALLOCATE
operations so we can set the updated inode size and change attribute
directly.  DEALLOCATE will still need to release pagecache pages, so
nfs42_proc_deallocate() now calls truncate_pagecache_range() before
contacting the server.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/inode.c          |  1 -
 fs/nfs/nfs42proc.c      | 21 +++++++++++++++++----
 fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
 fs/nfs/nfs4file.c       |  1 -
 include/linux/nfs_xdr.h |  4 ++++
 5 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 83107be..b39ae50 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -192,7 +192,6 @@ void nfs_zap_caches(struct inode *inode)
 	nfs_zap_caches_locked(inode);
 	spin_unlock(&inode->i_lock);
 }
-EXPORT_SYMBOL_GPL(nfs_zap_caches);
 
 void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 {
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index cb17072..cbae958 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -36,13 +36,16 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 				 loff_t offset, loff_t len)
 {
 	struct inode *inode = file_inode(filep);
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs42_falloc_args args = {
 		.falloc_fh	= NFS_FH(inode),
 		.falloc_offset	= offset,
 		.falloc_length	= len,
+		.falloc_bitmask	= server->cache_consistency_bitmask,
+	};
+	struct nfs42_falloc_res res = {
+		.falloc_server	= server,
 	};
-	struct nfs42_falloc_res res;
-	struct nfs_server *server = NFS_SERVER(inode);
 	int status;
 
 	msg->rpc_argp = &args;
@@ -52,8 +55,17 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 	if (status)
 		return status;
 
-	return nfs4_call_sync(server->client, server, msg,
-			      &args.seq_args, &res.seq_res, 0);
+	res.falloc_fattr = nfs_alloc_fattr();
+	if (!res.falloc_fattr)
+		return -ENOMEM;
+
+	status = nfs4_call_sync(server->client, server, msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status == 0)
+		status = nfs_post_op_update_inode(inode, res.falloc_fattr);
+
+	kfree(res.falloc_fattr);
+	return status;
 }
 
 static int nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
@@ -101,6 +113,7 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	if (!nfs_server_capable(inode, NFS_CAP_DEALLOCATE))
 		return -EOPNOTSUPP;
 
+	truncate_pagecache_range(inode, offset, (offset + len) -1);
 	err = nfs42_proc_fallocate(&msg, filep, offset, len);
 	if (err == -EOPNOTSUPP)
 		NFS_SERVER(inode)->caps &= ~NFS_CAP_DEALLOCATE;
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 038a7e1..1a25b27 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -25,16 +25,20 @@
 
 #define NFS4_enc_allocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
-					 encode_allocate_maxsz)
+					 encode_allocate_maxsz + \
+					 encode_getattr_maxsz)
 #define NFS4_dec_allocate_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
-					 decode_allocate_maxsz)
+					 decode_allocate_maxsz + \
+					 decode_getattr_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
-					 encode_deallocate_maxsz)
+					 encode_deallocate_maxsz + \
+					 encode_getattr_maxsz)
 #define NFS4_dec_deallocate_sz		(compound_decode_hdr_maxsz + \
 					 decode_putfh_maxsz + \
-					 decode_deallocate_maxsz)
+					 decode_deallocate_maxsz + \
+					 decode_getattr_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
@@ -92,6 +96,7 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->falloc_fh, &hdr);
 	encode_allocate(xdr, args, &hdr);
+	encode_getfattr(xdr, args->falloc_bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -110,6 +115,7 @@ static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->falloc_fh, &hdr);
 	encode_deallocate(xdr, args, &hdr);
+	encode_getfattr(xdr, args->falloc_bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -183,6 +189,9 @@ static int nfs4_xdr_dec_allocate(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_allocate(xdr, res);
+	if (status)
+		goto out;
+	decode_getfattr(xdr, res->falloc_fattr, res->falloc_server);
 out:
 	return status;
 }
@@ -207,6 +216,9 @@ static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_deallocate(xdr, res);
+	if (status)
+		goto out;
+	decode_getfattr(xdr, res->falloc_fattr, res->falloc_server);
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8b46389..d09c689 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -159,7 +159,6 @@ static long nfs42_fallocate(struct file *filep, int mode, loff_t offset, loff_t
 		ret = nfs42_proc_allocate(filep, offset, len);
 	mutex_unlock(&inode->i_mutex);
 
-	nfs_zap_caches(inode);
 	return ret;
 }
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4cb3eaa..38346b6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1271,11 +1271,15 @@ struct nfs42_falloc_args {
 	nfs4_stateid			 falloc_stateid;
 	u64				 falloc_offset;
 	u64				 falloc_length;
+	const u32			*falloc_bitmask;
 };
 
 struct nfs42_falloc_res {
 	struct nfs4_sequence_res	seq_res;
 	unsigned int			status;
+
+	struct nfs_fattr		*falloc_fattr;
+	const struct nfs_server		*falloc_server;
 };
 
 struct nfs42_seek_args {
-- 
2.3.0


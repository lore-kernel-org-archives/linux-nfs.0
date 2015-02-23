Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:41480 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbbBWVxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2015 16:53:25 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Thomas.Haynes@primarydata.com>
Subject: [PATCH] NFS: Add a GETATTR to ALLOCATE and DEALLOCATE calls
Date: Mon, 23 Feb 2015 16:53:22 -0500
Message-ID: <1424728402-22455-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding a GETATTR lets us update file attributes immediately, rather than
invalidating all cached data and updating later on.  I use the offset
provided to fallocate() to determine what page cache data needs to be
trashed.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/inode.c          |  4 ++--
 fs/nfs/nfs42proc.c      | 21 ++++++++++++++++-----
 fs/nfs/nfs42xdr.c       | 20 ++++++++++++++++----
 fs/nfs/nfs4file.c       |  1 -
 include/linux/nfs_fs.h  |  1 +
 include/linux/nfs_xdr.h |  4 ++++
 6 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 83107be..f67aadb 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -192,7 +192,6 @@ void nfs_zap_caches(struct inode *inode)
 	nfs_zap_caches_locked(inode);
 	spin_unlock(&inode->i_lock);
 }
-EXPORT_SYMBOL_GPL(nfs_zap_caches);
 
 void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 {
@@ -557,7 +556,7 @@ EXPORT_SYMBOL_GPL(nfs_setattr);
  * corrected to take into account the fact that NFS requires
  * inode->i_size to be updated under the inode->i_lock.
  */
-static int nfs_vmtruncate(struct inode * inode, loff_t offset)
+int nfs_vmtruncate(struct inode * inode, loff_t offset)
 {
 	int err;
 
@@ -576,6 +575,7 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_vmtruncate);
 
 /**
  * nfs_setattr_update_inode - Update inode metadata after a setattr call.
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index cb17072..407bfc3 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -36,24 +36,35 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 				 loff_t offset, loff_t len)
 {
 	struct inode *inode = file_inode(filep);
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs42_falloc_args args = {
 		.falloc_fh	= NFS_FH(inode),
 		.falloc_offset	= offset,
 		.falloc_length	= len,
+		.falloc_bitmask	= server->attr_bitmask,
 	};
-	struct nfs42_falloc_res res;
-	struct nfs_server *server = NFS_SERVER(inode);
-	int status;
+	struct nfs42_falloc_res res = {
+		.falloc_server	= server,
+	};
+	int status = -ENOMEM;
 
 	msg->rpc_argp = &args;
 	msg->rpc_resp = &res;
 
+	nfs_fattr_init(&res.falloc_fattr);
+
 	status = nfs42_set_rw_stateid(&args.falloc_stateid, filep, FMODE_WRITE);
 	if (status)
 		return status;
 
-	return nfs4_call_sync(server->client, server, msg,
-			      &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(server->client, server, msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (!status) {
+		nfs_vmtruncate(inode, offset);
+		status = nfs_post_op_update_inode(inode, &res.falloc_fattr);
+	}
+
+	return status;
 }
 
 static int nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 038a7e1..d3fcc5f 100644
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
+	decode_getfattr(xdr, &res->falloc_fattr, res->falloc_server);
 out:
 	return status;
 }
@@ -207,6 +216,9 @@ static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
 	if (status)
 		goto out;
 	status = decode_deallocate(xdr, res);
+	if (status)
+		goto out;
+	decode_getfattr(xdr, &res->falloc_fattr, res->falloc_server);
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
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2f77e0c..fb3dc3a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -337,6 +337,7 @@ static inline int nfs_verify_change_attribute(struct inode *dir, unsigned long c
 extern int nfs_sync_mapping(struct address_space *mapping);
 extern void nfs_zap_mapping(struct inode *inode, struct address_space *mapping);
 extern void nfs_zap_caches(struct inode *);
+extern int nfs_vmtruncate(struct inode *, loff_t);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
 				struct nfs_fattr *, struct nfs4_label *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4cb3eaa..23aa37a 100644
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
+	struct nfs_fattr		 falloc_fattr;
+	const struct nfs_server		*falloc_server;
 };
 
 struct nfs42_seek_args {
-- 
2.3.0


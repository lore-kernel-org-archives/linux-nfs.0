Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:46321 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752303AbdI1R2p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:45 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 06/11] NFS add ca_source_server<> to COPY
Date: Thu, 28 Sep 2017 13:28:34 -0400
Message-ID: <20170928172839.50741-7-kolga@netapp.com>
In-Reply-To: <20170928172839.50741-1-kolga@netapp.com>
References: <20170928172839.50741-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support only one source server address: the same address that
the client and source server use.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h          |  3 ++-
 fs/nfs/nfs42proc.c      | 26 +++++++++++++++++---------
 fs/nfs/nfs42xdr.c       | 12 ++++++++++--
 fs/nfs/nfs4file.c       |  7 ++++++-
 include/linux/nfs_xdr.h |  1 +
 5 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index b4e4d6ab..92d4d604 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -15,7 +15,8 @@
 #if defined(CONFIG_NFS_V4_2)
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
-ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t,
+			struct nl4_server *, nfs4_stateid *);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 7b1650c..79af87d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -219,7 +219,9 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 				struct file *dst,
 				struct nfs_lock_context *dst_lock,
 				struct nfs42_copy_args *args,
-				struct nfs42_copy_res *res)
+				struct nfs42_copy_res *res,
+				struct nl4_server *nss,
+				nfs4_stateid *cnr_stateid)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
@@ -233,11 +235,15 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	size_t count = args->count;
 	ssize_t status;
 
-	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
-				     src_lock, FMODE_READ);
-	if (status)
-		return status;
-
+	if (nss) {
+		args->cp_src = nss;
+		nfs4_stateid_copy(&args->src_stateid, cnr_stateid);
+	} else {
+		status = nfs4_set_rw_stateid(&args->src_stateid,
+				src_lock->open_context, src_lock, FMODE_READ);
+		if (status)
+			return status;
+	}
 	status = nfs_filemap_write_and_wait_range(file_inode(src)->i_mapping,
 			pos_src, pos_src + (loff_t)count - 1);
 	if (status)
@@ -316,8 +322,9 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
-			struct file *dst, loff_t pos_dst,
-			size_t count)
+			struct file *dst, loff_t pos_dst, size_t count,
+			struct nl4_server *nss,
+			nfs4_stateid *cnr_stateid)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	struct nfs_lock_context *src_lock;
@@ -362,7 +369,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		inode_lock(file_inode(dst));
 		err = _nfs42_proc_copy(src, src_lock,
 				dst, dst_lock,
-				&args, &res);
+				&args, &res,
+				nss, cnr_stateid);
 		inode_unlock(file_inode(dst));
 
 		if (err >= 0)
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 081c883..8902168 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -20,7 +20,10 @@
 #define encode_copy_maxsz		(op_encode_hdr_maxsz +          \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
 					 XDR_QUADLEN(NFS4_STATEID_SIZE) + \
-					 2 + 2 + 2 + 1 + 1 + 1)
+					 2 + 2 + 2 + 1 + 1 + 1 +\
+					 1 + /* One cnr_source_server */\
+					 1 + /* nl4_type */ \
+					 1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
 #define decode_copy_maxsz		(op_decode_hdr_maxsz + \
 					 NFS42_WRITE_RES_SIZE + \
 					 1 /* cr_consecutive */ + \
@@ -196,7 +199,12 @@ static void encode_copy(struct xdr_stream *xdr,
 
 	encode_uint32(xdr, 1); /* consecutive = true */
 	encode_uint32(xdr, args->sync);
-	encode_uint32(xdr, 0); /* src server list */
+	if (args->cp_src == NULL) { /* intra-ssc */
+		encode_uint32(xdr, 0); /* no src server list */
+		return;
+	}
+	encode_uint32(xdr, 1); /* supporting 1 server */
+	encode_nl4_server(xdr, args->cp_src);
 }
 
 static void encode_offload_status(struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8b9483d..b0194ad 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -134,6 +134,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    size_t count, unsigned int flags)
 {
 	struct nfs42_copy_notify_res *cn_resp = NULL;
+	struct nl4_server *nss = NULL;
+	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
 	if (file_inode(file_in) == file_inode(file_out))
@@ -151,8 +153,11 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 		ret = nfs42_proc_copy_notify(file_in, file_out, cn_resp);
 		if (ret)
 			goto out;
+		nss = &cn_resp->cnr_src;
+		cnrs = &cn_resp->cnr_stateid;
 	}
-	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count, nss,
+				cnrs);
 
 out:
 	kfree(cn_resp);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index af39603..52a9761 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1385,6 +1385,7 @@ struct nfs42_copy_args {
 
 	u64				count;
 	bool				sync;
+	struct nl4_server		*cp_src;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1


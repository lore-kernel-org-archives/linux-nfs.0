Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12561 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755079AbcHSRZt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:49 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>,
        Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH Version-2 06/12] NFS add ca_source_server<> to COPY
Date: Fri, 19 Aug 2016 13:25:06 -0400
Message-ID: <1471627512-4102-7-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Support only one source server address: the same address that
the client and source server use.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h          |  3 ++-
 fs/nfs/nfs42proc.c      | 35 +++++++++++++++++++++++++++--------
 fs/nfs/nfs42xdr.c       | 19 +++++++++++++++++--
 fs/nfs/nfs4file.c       |  7 ++++++-
 include/linux/nfs_xdr.h |  2 ++
 5 files changed, 54 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 2f780d2..820fd63 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -14,7 +14,8 @@
 /* nfs4.2proc.c */
 #if defined(CONFIG_NFS_V4_2)
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
-ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t,
+			struct nl4_servers *, nfs4_stateid *);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ace3fae..7a6b3c9 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -171,7 +171,9 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 				struct nfs_lock_context *src_lock,
 				struct file *dst, loff_t pos_dst,
 				struct nfs_lock_context *dst_lock,
-				size_t count)
+				size_t count,
+				struct nl4_servers *nss,
+				nfs4_stateid *cnr_stateid)
 {
 	struct nfs42_copy_args args = {
 		.src_fh		= NFS_FH(file_inode(src)),
@@ -190,10 +192,25 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 	struct nfs_server *server = NFS_SERVER(dst_inode);
 	int status;
 
-	status = nfs4_set_rw_stateid(&args.src_stateid, src_lock->open_context,
-				     src_lock, FMODE_READ);
-	if (status)
-		return status;
+	if (nss) {
+		args.cp_src = nss;
+
+		dprintk("--> %s nl4_type %d cp_addr netid %d:%s uaddr %d:%s\n",
+			__func__, args.cp_src->nl_svr->nl4_type,
+			args.cp_src->nl_svr->u.nl4_addr.na_netid_len,
+			args.cp_src->nl_svr->u.nl4_addr.na_netid,
+			args.cp_src->nl_svr->u.nl4_addr.na_uaddr_len,
+			args.cp_src->nl_svr->u.nl4_addr.na_uaddr);
+
+		nfs4_stateid_copy(&args.src_stateid, cnr_stateid);
+	} else {
+
+		status = nfs4_set_rw_stateid(&args.src_stateid,
+					src_lock->open_context,
+					src_lock, FMODE_READ);
+		if (status)
+			return status;
+	}
 
 	status = nfs_filemap_write_and_wait_range(file_inode(src)->i_mapping,
 			pos_src, pos_src + (loff_t)count - 1);
@@ -229,8 +246,9 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
-			struct file *dst, loff_t pos_dst,
-			size_t count)
+			struct file *dst, loff_t pos_dst, size_t count,
+			struct nl4_servers *nss,
+			nfs4_stateid *cnr_stateid)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	struct nfs_lock_context *src_lock;
@@ -261,7 +279,8 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	do {
 		inode_lock(file_inode(dst));
 		err = _nfs42_proc_copy(src, pos_src, src_lock,
-				       dst, pos_dst, dst_lock, count);
+				       dst, pos_dst, dst_lock, count,
+				       nss, cnr_stateid);
 		inode_unlock(file_inode(dst));
 
 		if (err == -ENOTSUPP) {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 29bfaab..4738c70 100644
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
@@ -164,6 +167,9 @@ static void encode_copy(struct xdr_stream *xdr,
 			struct nfs42_copy_args *args,
 			struct compound_hdr *hdr)
 {
+	struct nl4_server *ns;
+	int i;
+
 	encode_op_hdr(xdr, OP_COPY, decode_copy_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &args->src_stateid);
 	encode_nfs4_stateid(xdr, &args->dst_stateid);
@@ -174,7 +180,16 @@ static void encode_copy(struct xdr_stream *xdr,
 
 	encode_uint32(xdr, 1); /* consecutive = true */
 	encode_uint32(xdr, 1); /* synchronous = true */
-	encode_uint32(xdr, 0); /* src server list */
+	if (args->cp_src == NULL) { /* intra-ssc */
+		encode_uint32(xdr, 0); /* no src server list */
+		return;
+	}
+	encode_uint32(xdr, args->cp_src->nl_nsvr);
+	ns = args->cp_src->nl_svr;
+	for (i = 0; i < args->cp_src->nl_nsvr; i++) {
+		encode_nl4_server(xdr, args->cp_src->nl_svr);
+		ns++;
+	}
 }
 
 static void encode_copy_notify(struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index cf78bf8..599f1ca 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    size_t count, unsigned int flags)
 {
 	struct nfs42_copy_notify_res *cn_resp = NULL;
+	struct nl4_servers *nss = NULL;
+	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
 	if (file_inode(file_in) == file_inode(file_out))
@@ -160,8 +162,11 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
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
 	if (cn_resp) {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ecd4132..ee3dd09 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1342,6 +1342,8 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	/* Support one source server */
+	struct nl4_servers		*cp_src;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1


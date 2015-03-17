Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:36219 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932554AbbCQWlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:42 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 06/10] NFS add ca_source_server<> to COPY
Date: Tue, 17 Mar 2015 18:31:34 -0400
Message-ID: <1426631498-14772-7-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Support only one source server address: the same address that the client and
source server use.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs42.h          |  3 ++-
 fs/nfs/nfs42proc.c      | 18 +++++++++++++++++-
 fs/nfs/nfs42xdr.c       | 30 +++++++++++++++++++++++++-----
 fs/nfs/nfs4file.c       |  6 ++++--
 include/linux/nfs_xdr.h | 13 +++++++++++++
 5 files changed, 61 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 849b51e..e5a0b17 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -7,7 +7,8 @@
 
 /* nfs4.2proc.c */
 int nfs42_proc_allocate(struct file *, loff_t, loff_t);
-ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
+ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t,
+		size_t, struct nfs42_copy_notify_res *);
 int nfs42_proc_copy_notify(struct file *, struct file *,
 		 struct nfs42_copy_notify_res *);
 int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index e09e793..325adb7 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -146,9 +146,12 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+/**
+ * Support one source address for now.
+ */
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			struct file *dst, loff_t pos_dst,
-			size_t count)
+			size_t count, struct nfs42_copy_notify_res *cn_res)
 {
 	struct nfs42_copy_args args = {
 		.src_fh		= NFS_FH(file_inode(src)),
@@ -166,6 +169,19 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	int status;
 
+	if (cn_res) {
+		args.cp_nsrc = 1; /* support for one NL4_NETADDR for now */
+		args.src[0].cp_nl_type = cn_res->src[0].cnr_nl_type;
+		args.src[0].u.cp_addr = cn_res->src[0].u.cnr_addr;
+
+		dprintk("--> %s nl4_type %dcp_addr netid %d:%s uaddr %d:%s\n",
+			__func__, args.src[0].cp_nl_type,
+			args.src[0].u.cp_addr.na_netid_len,
+			args.src[0].u.cp_addr.na_netid,
+			args.src[0].u.cp_addr.na_uaddr_len,
+			args.src[0].u.cp_addr.na_uaddr);
+	}
+
 	if (!(server->caps & NFS_CAP_COPY))
 		return -ENOTSUPP;
 
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 94a484a..38d9a6a 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -1,6 +1,3 @@
-/*
- * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
- */
 #ifndef __LINUX_FS_NFS_NFS4_2XDR_H
 #define __LINUX_FS_NFS_NFS4_2XDR_H
 
@@ -18,7 +15,10 @@
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
@@ -131,7 +131,27 @@ static void encode_copy(struct xdr_stream *xdr,
 
 	encode_uint32(xdr, 1); /* consecutive = true */
 	encode_uint32(xdr, 1); /* synchronous = true */
-	encode_uint32(xdr, 0); /* src server list */
+	encode_uint32(xdr, args->cp_nsrc); /* set to 1 for inter-ssc*/
+	if (args->cp_nsrc ==0) /* intra-ssc */
+		return;
+
+	encode_uint32(xdr, args->src[0].cp_nl_type);
+	/* Support one src server in list for now */
+	switch(args->src[0].cp_nl_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		encode_string(xdr, args->src[0].u.cp_str_sz,
+			      args->src[0].u.cp_str);
+		break;
+	case NL4_NETADDR:
+		encode_string(xdr, args->src[0].u.cp_addr.na_netid_len,
+			      args->src[0].u.cp_addr.na_netid);
+		encode_string(xdr, args->src[0].u.cp_addr.na_uaddr_len,
+			      args->src[0].u.cp_addr.na_uaddr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
 }
 
 static void encode_copy_notify(struct xdr_stream *xdr,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index c71bf6a..a72f402 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -140,7 +140,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 		if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb ||
 			       file_in->f_path.mnt != file_out->f_path.mnt)
 			return -ENOTSUPP;
-		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out,
+				       count, NULL);
 	} else {  /* Inter-ssc */
 		struct nfs42_copy_notify_res cn_res = {
 			.cnr_nsrc = 0,
@@ -150,7 +151,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 		err = nfs42_proc_copy_notify(file_in, file_out, &cn_res);
 		if (err)
 			return err;
-		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+		return nfs42_proc_copy(file_in, pos_in, file_out, pos_out,
+				       count, &cn_res);
 	}
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 984e0e6..cf1accc 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1300,6 +1300,19 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	/* Support one source server */
+	int				cp_nsrc;
+	struct { /* ca_source_server<> */
+		enum netloc_type4		cp_nl_type;
+		union {
+			struct {
+			/* NL4_NAME, NL4_URL */
+				int	cp_str_sz;
+				char	cp_str[NFS4_OPAQUE_LIMIT + 1];
+			};
+			struct nfs42_netaddr	cp_addr; /* NL4_NETADDR */
+		} u;
+	} src[NFS42_MAX_SSC_SRC];
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1


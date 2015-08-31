Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:36911 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105AbbHaTux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:53 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 10/16] NFS add ca_source_server<> to COPY
Date: Mon, 31 Aug 2015 15:50:00 -0400
Message-ID: <1441050606-40897-11-git-send-email-andros@netapp.com>
In-Reply-To: <1441050606-40897-1-git-send-email-andros@netapp.com>
References: <1441050606-40897-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Support only one source server address: the same address that
the client and source server use.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs42proc.c      | 22 ++++++++++++++++++++--
 fs/nfs/nfs42xdr.c       | 27 +++++++++++++++++++++++++--
 include/linux/nfs_xdr.h |  3 +++
 3 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 92b5d5a..42cab7e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -157,8 +157,12 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+/**
+ * Support one source address for now.
+ */
 static ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
-			       struct file *dst, loff_t pos_dst, size_t count)
+			       struct file *dst, loff_t pos_dst, size_t count,
+			       struct nfs42_copy_notify_res *cn_res)
 {
 	struct nfs42_copy_args args = {
 		.src_fh		= NFS_FH(file_inode(src)),
@@ -176,6 +180,19 @@ static ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	int status;
 
+	if (cn_res) {
+		args.cp_nsrc = 1; /* support for one NL4_NETADDR for now */
+		args.cp_src[0].nl4_type = cn_res->cnr_src[0].nl4_type;
+		args.cp_src[0].u.nl4_addr = cn_res->cnr_src[0].u.nl4_addr;
+
+		dprintk("--> %s nl4_type %d cp_addr netid %d:%s uaddr %d:%s\n",
+			__func__, args.cp_src[0].nl4_type,
+			args.cp_src[0].u.nl4_addr.na_netid_len,
+			args.cp_src[0].u.nl4_addr.na_netid,
+			args.cp_src[0].u.nl4_addr.na_uaddr_len,
+			args.cp_src[0].u.nl4_addr.na_uaddr);
+	}
+
 	if (!(server->caps & NFS_CAP_COPY))
 		return -ENOTSUPP;
 
@@ -297,7 +314,8 @@ ssize_t nfs42_do_copy(struct file *src, loff_t pos_src, struct file *dst,
 		if (ret)
 			goto out_err;
 	}
-	ret = nfs42_proc_copy(src, pos_src, dst, pos_dst, count);
+	 /* NULL nfs42_copy_notify_res pointer signals intra ssc */
+	ret = nfs42_proc_copy(src, pos_src, dst, pos_dst, count, cn_resp);
 
 out_err:
 	kfree(cn_resp);
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index feb29af..060d4eb 100644
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
@@ -136,7 +139,27 @@ static void encode_copy(struct xdr_stream *xdr,
 
 	encode_uint32(xdr, 1); /* consecutive = true */
 	encode_uint32(xdr, 1); /* synchronous = true */
-	encode_uint32(xdr, 0); /* src server list */
+	encode_uint32(xdr, args->cp_nsrc); /* set to 1 for inter-ssc*/
+	if (args->cp_nsrc == 0) /* intra-ssc */
+		return;
+
+	encode_uint32(xdr, args->cp_src[0].nl4_type);
+	/* Support one src server in list for now */
+	switch (args->cp_src[0].nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		encode_string(xdr, args->cp_src[0].u.nl4_str_sz,
+			      args->cp_src[0].u.nl4_str);
+		break;
+	case NL4_NETADDR:
+		encode_string(xdr, args->cp_src[0].u.nl4_addr.na_netid_len,
+			      args->cp_src[0].u.nl4_addr.na_netid);
+		encode_string(xdr, args->cp_src[0].u.nl4_addr.na_uaddr_len,
+			      args->cp_src[0].u.nl4_addr.na_uaddr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
 }
 
 static void encode_copy_notify(struct xdr_stream *xdr,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a7f63fb..dd9009a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1339,6 +1339,9 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	/* Support one source server */
+	int				cp_nsrc;
+	struct nl4_server		cp_src[NFS42_MAX_SSC_SRC];
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1


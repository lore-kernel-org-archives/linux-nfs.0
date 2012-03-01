Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51202 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738Ab2CAWCH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:02:07 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389945iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:02:06 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] NFS: Request fh_expire_type attribute in "server caps"
 operation
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:02:05 -0500
Message-ID: <20120301220205.2138.14819.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fh_expire_type file attribute is a filesystem wide attribute that
consists of flags that indicate what characteristics file handles
on this FSID have.

Our client doesn't support volatile file handles.  It should find
out early (say, at mount time) whether the server is going to play
shenanighans with file handles during a migration.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c         |    1 +
 fs/nfs/nfs4xdr.c          |   26 ++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    3 +++
 include/linux/nfs_xdr.h   |    1 +
 4 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ced56d0..07bd1f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2220,6 +2220,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->acl_bitmask = res.acl_bitmask;
+		server->fh_expire_type = res.fh_expire_type;
 	}
 
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bec7227..018bbd7 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2637,6 +2637,7 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fhandle, &hdr);
 	encode_getattr_one(xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
+			   FATTR4_WORD0_FH_EXPIRE_TYPE|
 			   FATTR4_WORD0_LINK_SUPPORT|
 			   FATTR4_WORD0_SYMLINK_SUPPORT|
 			   FATTR4_WORD0_ACLSUPPORT, &hdr);
@@ -3184,6 +3185,28 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_fh_expire_type(struct xdr_stream *xdr,
+				      uint32_t *bitmap, uint32_t *type)
+{
+	__be32 *p;
+
+	*type = 0;
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_FH_EXPIRE_TYPE - 1U)))
+		return -EIO;
+	if (likely(bitmap[0] & FATTR4_WORD0_FH_EXPIRE_TYPE)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		*type = be32_to_cpup(p);
+		bitmap[0] &= ~FATTR4_WORD0_FH_EXPIRE_TYPE;
+	}
+	dprintk("%s: expire type=0x%x\n", __func__, *type);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *change)
 {
 	__be32 *p;
@@ -4232,6 +4255,9 @@ static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_re
 		goto xdr_error;
 	if ((status = decode_attr_supported(xdr, bitmap, res->attr_bitmask)) != 0)
 		goto xdr_error;
+	if ((status = decode_attr_fh_expire_type(xdr, bitmap,
+						 &res->fh_expire_type)) != 0)
+		goto xdr_error;
 	if ((status = decode_attr_link_support(xdr, bitmap, &res->has_links)) != 0)
 		goto xdr_error;
 	if ((status = decode_attr_symlink_support(xdr, bitmap, &res->has_symlinks)) != 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0a2c826..4f72b53 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -146,6 +146,9 @@ struct nfs_server {
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */
+	u32			fh_expire_type;	/* V4 bitmask representing file
+						   handle volatility type for
+						   this filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct rpc_wait_queue	roc_rpcwaitq;
 	void			*pnfs_ld_data;	/* per mount point data */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 07eb9c9..211b280 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -977,6 +977,7 @@ struct nfs4_server_caps_res {
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
+	u32				fh_expire_type;
 	struct nfs4_sequence_res	seq_res;
 };
 


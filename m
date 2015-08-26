Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35644 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932969AbbHZNNI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:13:08 -0400
Received: by pacdd16 with SMTP id dd16so160632289pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 06:13:08 -0700 (PDT)
Subject: [PATCH 4/5 v3] NFS: Get suppattr_exclcreat when getting server
 capabilities
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55DDBA9E.1040008@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55DDBB5A.6070500@gmail.com>
Date: Wed, 26 Aug 2015 21:12:58 +0800
MIME-Version: 1.0
In-Reply-To: <55DDBA9E.1040008@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create file with attributs as NFS4_CREATE_EXCLUSIVE4_1 mode
depends on suppattr_exclcreat attribut.

v3, same as v2.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c         | 14 +++++++++++++-
 fs/nfs/nfs4xdr.c          | 26 +++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |  5 +++++
 include/linux/nfs_xdr.h   |  2 ++
 4 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e5a2fb..2a888cb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2883,8 +2883,10 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
+	u32 bitmask[3] = {}, minorversion = server->nfs_client->cl_minorversion;
 	struct nfs4_server_caps_arg args = {
 		.fhandle = fhandle,
+		.bitmask = bitmask,
 	};
 	struct nfs4_server_caps_res res = {};
 	struct rpc_message msg = {
@@ -2894,10 +2896,18 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
+	bitmask[0] = FATTR4_WORD0_SUPPORTED_ATTRS |
+		     FATTR4_WORD0_FH_EXPIRE_TYPE |
+		     FATTR4_WORD0_LINK_SUPPORT |
+		     FATTR4_WORD0_SYMLINK_SUPPORT |
+		     FATTR4_WORD0_ACLSUPPORT;
+	if (minorversion)
+		bitmask[2] = FATTR4_WORD2_SUPPATTR_EXCLCREAT;
+
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (status == 0) {
 		/* Sanity check the server answers */
-		switch (server->nfs_client->cl_minorversion) {
+		switch (minorversion) {
 		case 0:
 			res.attr_bitmask[1] &= FATTR4_WORD1_NFS40_MASK;
 			res.attr_bitmask[2] = 0;
@@ -2950,6 +2960,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->cache_consistency_bitmask[2] = 0;
+		memcpy(server->exclcreat_bitmask, res.exclcreat_bitmask,
+			sizeof(server->exclcreat_bitmask));
 		server->acl_bitmask = res.acl_bitmask;
 		server->fh_expire_type = res.fh_expire_type;
 	}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..fc88fcf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2580,6 +2580,7 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
 				     struct nfs4_server_caps_arg *args)
 {
+	const u32 *bitmask = args->bitmask;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2587,11 +2588,7 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fhandle, &hdr);
-	encode_getattr_one(xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
-			   FATTR4_WORD0_FH_EXPIRE_TYPE|
-			   FATTR4_WORD0_LINK_SUPPORT|
-			   FATTR4_WORD0_SYMLINK_SUPPORT|
-			   FATTR4_WORD0_ACLSUPPORT, &hdr);
+	encode_getattr_three(xdr, bitmask[0], bitmask[1], bitmask[2], &hdr);
 	encode_nops(&hdr);
 }
 
@@ -3368,6 +3365,22 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_exclcreat_supported(struct xdr_stream *xdr,
+				 uint32_t *bitmap, uint32_t *bitmask)
+{
+	if (likely(bitmap[2] & FATTR4_WORD2_SUPPATTR_EXCLCREAT)) {
+		int ret;
+		ret = decode_attr_bitmap(xdr, bitmask);
+		if (unlikely(ret < 0))
+			return ret;
+		bitmap[2] &= ~FATTR4_WORD2_SUPPATTR_EXCLCREAT;
+	} else
+		bitmask[0] = bitmask[1] = bitmask[2] = 0;
+	dprintk("%s: bitmask=%08x:%08x:%08x\n", __func__,
+		bitmask[0], bitmask[1], bitmask[2]);
+	return 0;
+}
+
 static int decode_attr_filehandle(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fh *fh)
 {
 	__be32 *p;
@@ -4321,6 +4334,9 @@ static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_re
 		goto xdr_error;
 	if ((status = decode_attr_aclsupport(xdr, bitmap, &res->acl_bitmask)) != 0)
 		goto xdr_error;
+	if ((status = decode_attr_exclcreat_supported(xdr, bitmap,
+				res->exclcreat_bitmask)) != 0)
+		goto xdr_error;
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
 	dprintk("%s: xdr returned %d!\n", __func__, -status);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 20bc8e5..570a7df 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -173,6 +173,11 @@ struct nfs_server {
 						   set of attributes supported
 						   on this filesystem excluding
 						   the label support bit. */
+	u32			exclcreat_bitmask[3];
+						/* V4 bitmask representing the
+						   set of attributes supported
+						   on this filesystem for the
+						   exclusive create. */
 	u32			cache_consistency_bitmask[3];
 						/* V4 bitmask representing the subset
 						   of change attribute, size, ctime
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7bbe505..aac795b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1057,11 +1057,13 @@ struct nfs4_statfs_res {
 struct nfs4_server_caps_arg {
 	struct nfs4_sequence_args	seq_args;
 	struct nfs_fh		       *fhandle;
+	const u32 *			bitmask;
 };
 
 struct nfs4_server_caps_res {
 	struct nfs4_sequence_res	seq_res;
 	u32				attr_bitmask[3];
+	u32				exclcreat_bitmask[3];
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
-- 
2.4.3


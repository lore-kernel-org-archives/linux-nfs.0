Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759Ab2FUVvg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:36 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFSv4: Simplify the GETATTR attribute length calculation
Date: Thu, 21 Jun 2012 17:51:25 -0400
Message-Id: <1340315487-18309-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the xdr_stream position counter as the basis for the calculation
instead of assuming that we can calculate an offset to the start
of the iovec.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2754f72..93f8bec 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3078,7 +3078,7 @@ out_overflow:
 	return -EIO;
 }
 
-static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen, __be32 **savep)
+static int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen, unsigned int *savep)
 {
 	__be32 *p;
 
@@ -3086,7 +3086,7 @@ static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen,
 	if (unlikely(!p))
 		goto out_overflow;
 	*attrlen = be32_to_cpup(p);
-	*savep = xdr->p;
+	*savep = xdr_stream_pos(xdr);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -4068,10 +4068,10 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 	return status;
 }
 
-static int verify_attr_len(struct xdr_stream *xdr, __be32 *savep, uint32_t attrlen)
+static int verify_attr_len(struct xdr_stream *xdr, unsigned int savep, uint32_t attrlen)
 {
 	unsigned int attrwords = XDR_QUADLEN(attrlen);
-	unsigned int nwords = xdr->p - savep;
+	unsigned int nwords = (xdr_stream_pos(xdr) - savep) >> 2;
 
 	if (unlikely(attrwords != nwords)) {
 		dprintk("%s: server returned incorrect attribute length: "
@@ -4193,7 +4193,7 @@ out_overflow:
 
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
-	__be32 *savep;
+	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
@@ -4222,7 +4222,7 @@ xdr_error:
 
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
-	__be32 *savep;
+	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
@@ -4254,7 +4254,7 @@ xdr_error:
 
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
-	__be32 *savep;
+	unsigned int savep;
 	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
@@ -4299,7 +4299,8 @@ out_overflow:
 static int decode_first_threshold_item4(struct xdr_stream *xdr,
 					struct nfs4_threshold *res)
 {
-	__be32 *p, *savep;
+	__be32 *p;
+	unsigned int savep;
 	uint32_t bitmap[3] = {0,}, attrlen;
 	int status;
 
@@ -4503,7 +4504,7 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 		struct nfs_fh *fh, struct nfs4_fs_locations *fs_loc,
 		const struct nfs_server *server)
 {
-	__be32 *savep;
+	unsigned int savep;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
 	int status;
@@ -4615,7 +4616,7 @@ static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
-	__be32 *savep;
+	unsigned int savep;
 	uint32_t attrlen, bitmap[3];
 	int status;
 
@@ -5044,7 +5045,8 @@ decode_restorefh(struct xdr_stream *xdr)
 static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 			 struct nfs_getaclres *res)
 {
-	__be32 *savep, *bm_p;
+	unsigned int savep;
+	__be32 *bm_p;
 	uint32_t attrlen,
 		 bitmap[3] = {0};
 	int status;
@@ -7076,6 +7078,7 @@ out:
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       int plus)
 {
+	unsigned int savep;
 	uint32_t bitmap[3] = {0};
 	uint32_t len;
 	__be32 *p = xdr_inline_decode(xdr, 4);
@@ -7114,7 +7117,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (decode_attr_bitmap(xdr, bitmap) < 0)
 		goto out_overflow;
 
-	if (decode_attr_length(xdr, &len, &p) < 0)
+	if (decode_attr_length(xdr, &len, &savep) < 0)
 		goto out_overflow;
 
 	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
-- 
1.7.10.2


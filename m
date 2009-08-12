From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 13/13] nfs: nfs4xdr: get rid of READ_BUF
Date: Wed, 12 Aug 2009 18:22:58 +0300
Message-ID: <1250090578-9927-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10677
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752759AbZHLPW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:59 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Open code return pointer assignment and error checking using
a read_buf helper (macro), yet keep the dprintk on failure using an
internal __read_buf helper that gets the function name for printing.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  386 ++++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 277 insertions(+), 109 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ed9bbd2..fb10a77 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2438,26 +2438,17 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-/*
- * START OF "GENERIC" DECODE ROUTINES.
- *   These may look a little ugly since they are imported from a "generic"
- * set of XDR encode/decode routines which are intended to be shared by
- * all of our NFSv4 implementations (OpenBSD, MacOS X...).
- *
- * If the pain of reading these is too great, it should be a straightforward
- * task to translate them into Linux-specific versions which are more
- * consistent with the style used in NFSv2/v3...
- */
-#define READ_BUF(nbytes)  do { \
-	p = xdr_inline_decode(xdr, nbytes); \
-	if (unlikely(!p)) { \
-		dprintk("nfs: %s: prematurely hit end of receive" \
-				" buffer\n", __func__); \
-		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
-				__func__, xdr->p, nbytes, xdr->end); \
-		return -EIO; \
-	} \
-} while (0)
+static __be32 *__read_buf(struct xdr_stream *xdr, size_t nbytes, char *func)
+{
+	__be32 *p = xdr_inline_decode(xdr, nbytes);
+	if (unlikely(!p))
+		dprintk("nfs: %s: prematurely hit end of receive buffer: "
+			"xdr->p=%p, bytes=%u, xdr->end=%p\n",
+			func, xdr->p, nbytes, xdr->end);
+	return p;
+}
+
+#define read_buf(xdr, nbytes)	__read_buf(xdr, nbytes, __func__)
 
 static __be32 *copymem(void *x, __be32 *p, u32 nbytes)
 {
@@ -2469,9 +2460,13 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
 {
 	__be32 *p;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, len);
-	READ_BUF(*len);
+	p = read_buf(xdr, *len);
+	if (unlikely(!p))
+		return -EIO;
 	*string = (char *)p;
 	return 0;
 }
@@ -2480,11 +2475,15 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &hdr->status);
 	p = xdr_decode_int(p, &hdr->taglen);
 
-	READ_BUF(hdr->taglen + 4);
+	p = read_buf(xdr, hdr->taglen + 4);
+	if (unlikely(!p))
+		return -EIO;
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	p = xdr_decode_int(p, &hdr->nops);
@@ -2499,7 +2498,9 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	uint32_t opnum;
 	int32_t nfserr;
 
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &opnum);
 	if (opnum != expected) {
 		dprintk("nfs: Server returned operation"
@@ -2520,7 +2521,9 @@ static int decode_ace(struct xdr_stream *xdr, void *ace, struct nfs_client *clp)
 	unsigned int strlen;
 	char *str;
 
-	READ_BUF(12);
+	p = read_buf(xdr, 12);
+	if (unlikely(!p))
+		return -EIO;
 	return decode_opaque_inline(xdr, &strlen, &str);
 }
 
@@ -2529,11 +2532,15 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	uint32_t bmlen;
 	__be32 *p;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &bmlen);
 
 	bitmap[0] = bitmap[1] = 0;
-	READ_BUF((bmlen << 2));
+	p = read_buf(xdr, (bmlen << 2));
+	if (unlikely(!p))
+		return -EIO;
 	if (bmlen > 0) {
 		p = xdr_decode_int(p, &bitmap[0]);
 		if (bmlen > 1)
@@ -2546,7 +2553,9 @@ static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen,
 {
 	__be32 *p;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, attrlen);
 	*savep = xdr->p;
 	return 0;
@@ -2572,7 +2581,9 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_TYPE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, type);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
@@ -2594,7 +2605,9 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_CHANGE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_CHANGE)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
@@ -2613,7 +2626,9 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_SIZE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SIZE)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
@@ -2630,7 +2645,9 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_LINK_SUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
@@ -2646,7 +2663,9 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_SYMLINK_SUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
@@ -2664,7 +2683,9 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FSID - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FSID)) {
-		READ_BUF(16);
+		p = read_buf(xdr, 16);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, &fsid->major);
 		p = xdr_decode_hyper(p, &fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
@@ -2684,7 +2705,9 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_LEASE_TIME - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
@@ -2700,7 +2723,9 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACLSUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
@@ -2717,7 +2742,9 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEID - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEID)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
@@ -2735,7 +2762,9 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MOUNTED_ON_FILEID - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
@@ -2753,7 +2782,9 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_AVAIL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_AVAIL)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
@@ -2770,7 +2801,9 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_FREE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_FREE)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
@@ -2787,7 +2820,9 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_TOTAL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_TOTAL)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
@@ -2801,7 +2836,9 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	__be32 *p;
 	int status = 0;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &n);
 	if (n == 0)
 		goto root_path;
@@ -2853,7 +2890,9 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
 		goto out;
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &n);
 	if (n <= 0)
 		goto out_eio;
@@ -2862,7 +2901,9 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		u32 m;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &m);
 
 		loc->nservers = 0;
@@ -2916,7 +2957,9 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXFILESIZE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXFILESIZE)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
@@ -2933,7 +2976,9 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXLINK - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, maxlink);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
@@ -2950,7 +2995,9 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXNAME - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, maxname);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
@@ -2968,7 +3015,9 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXREAD)) {
 		uint64_t maxread;
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, &maxread);
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
@@ -2989,7 +3038,9 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXWRITE)) {
 		uint64_t maxwrite;
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, &maxwrite);
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
@@ -3010,7 +3061,9 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MODE - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &tmp);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
@@ -3029,7 +3082,9 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_NUMLINKS - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, nlink);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
@@ -3048,9 +3103,13 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &len);
-		READ_BUF(len);
+		p = read_buf(xdr, len);
+		if (unlikely(!p))
+			return -EIO;
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
 				ret = NFS_ATTR_FATTR_OWNER;
@@ -3076,9 +3135,13 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &len);
-		READ_BUF(len);
+		p = read_buf(xdr, len);
+		if (unlikely(!p))
+			return -EIO;
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
 				ret = NFS_ATTR_FATTR_GROUP;
@@ -3106,7 +3169,9 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 	if (likely(bitmap[1] & FATTR4_WORD1_RAWDEV)) {
 		dev_t tmp;
 
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &major);
 		p = xdr_decode_int(p, &minor);
 		tmp = MKDEV(major, minor);
@@ -3128,7 +3193,9 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_AVAIL - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_AVAIL)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
@@ -3145,7 +3212,9 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_FREE - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_FREE)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
@@ -3162,7 +3231,9 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_TOTAL - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_TOTAL)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
@@ -3179,7 +3250,9 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_USED - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_USED)) {
-		READ_BUF(8);
+		p = read_buf(xdr, 8);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
@@ -3195,7 +3268,9 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 	uint64_t sec;
 	uint32_t nsec;
 
-	READ_BUF(12);
+	p = read_buf(xdr, 12);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_hyper(p, &sec);
 	p = xdr_decode_int(p, &nsec);
 	time->tv_sec = (time_t)sec;
@@ -3278,7 +3353,9 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 {
 	__be32 *p;
 
-	READ_BUF(20);
+	p = read_buf(xdr, 20);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &cinfo->atomic);
 	p = xdr_decode_hyper(p, &cinfo->before);
 	p = xdr_decode_hyper(p, &cinfo->after);
@@ -3294,7 +3371,9 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	status = decode_op_hdr(xdr, OP_ACCESS);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &supp);
 	p = xdr_decode_int(p, &acc);
 	access->supported = supp;
@@ -3312,7 +3391,9 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
+	p = read_buf(xdr, NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
@@ -3325,7 +3406,9 @@ static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
 	status = decode_op_hdr(xdr, OP_COMMIT);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(res->verf->verifier, p, 8);
 	return 0;
 }
@@ -3341,9 +3424,13 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 		return status;
 	if ((status = decode_change_info(xdr, cinfo)))
 		return status;
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &bmlen);
-	READ_BUF(bmlen << 2);
+	p = read_buf(xdr, bmlen << 2);
+	if (unlikely(!p))
+		return -EIO;
 	return 0;
 }
 
@@ -3596,12 +3683,16 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 	if (status)
 		return status;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &len);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
-	READ_BUF(len);
+	p = read_buf(xdr, len);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(fh->data, p, len);
 	return 0;
 }
@@ -3625,7 +3716,9 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	__be32 *p;
 	uint32_t namelen, type;
 
-	READ_BUF(32);
+	p = read_buf(xdr, 32);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_hyper(p, &offset);
 	p = xdr_decode_hyper(p, &length);
 	p = xdr_decode_int(p, &type);
@@ -3641,7 +3734,9 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	}
 	p = xdr_decode_hyper(p, &clientid);
 	p = xdr_decode_int(p, &namelen);
-	READ_BUF(namelen);
+	p = read_buf(xdr, namelen);
+	if (unlikely(!p))
+		return -EIO;
 	return -NFS4ERR_DENIED;
 }
 
@@ -3654,7 +3749,9 @@ static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
 	if (status == -EIO)
 		goto out;
 	if (status == 0) {
-		READ_BUF(NFS4_STATEID_SIZE);
+		p = read_buf(xdr, NFS4_STATEID_SIZE);
+		if (unlikely(!p))
+			return -EIO;
 		copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	} else if (status == -NFS4ERR_DENIED)
 		status = decode_lock_denied(xdr, NULL);
@@ -3683,7 +3780,9 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 	if (status != -EIO)
 		nfs_increment_lock_seqid(status, res->seqid);
 	if (status == 0) {
-		READ_BUF(NFS4_STATEID_SIZE);
+		p = read_buf(xdr, NFS4_STATEID_SIZE);
+		if (unlikely(!p))
+			return -EIO;
 		copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	}
 	return status;
@@ -3700,7 +3799,9 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	__be32 *p;
 	uint32_t limit_type, nblocks, blocksize;
 
-	READ_BUF(12);
+	p = read_buf(xdr, 12);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &limit_type);
 	switch (limit_type) {
 	case 1:
@@ -3719,13 +3820,17 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	__be32 *p;
 	uint32_t delegation_type;
 
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &delegation_type);
 	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
 		res->delegation_type = 0;
 		return 0;
 	}
-	READ_BUF(NFS4_STATEID_SIZE+4);
+	p = read_buf(xdr, NFS4_STATEID_SIZE+4);
+	if (unlikely(!p))
+		return -EIO;
 	p = copymem(res->delegation.data, p, NFS4_STATEID_SIZE);
 	p = xdr_decode_int(p, &res->do_recall);
 
@@ -3752,18 +3857,24 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
+	p = read_buf(xdr, NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		return -EIO;
 	p = copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 
 	decode_change_info(xdr, &res->cinfo);
 
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &res->rflags);
 	p = xdr_decode_int(p, &bmlen);
 	if (bmlen > 10)
 		goto xdr_error;
 
-	READ_BUF(bmlen << 2);
+	p = read_buf(xdr, bmlen << 2);
+	if (unlikely(!p))
+		return -EIO;
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
 		p = xdr_decode_int(p, &res->attrset[i]);
@@ -3786,7 +3897,9 @@ static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmre
 		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
+	p = read_buf(xdr, NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
@@ -3801,7 +3914,9 @@ static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *re
 		nfs_increment_open_seqid(status, res->seqid);
 	if (status)
 		return status;
-	READ_BUF(NFS4_STATEID_SIZE);
+	p = read_buf(xdr, NFS4_STATEID_SIZE);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
@@ -3826,7 +3941,9 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	status = decode_op_hdr(xdr, OP_READ);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &eof);
 	p = xdr_decode_int(p, &count);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
@@ -3857,7 +3974,9 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	status = decode_op_hdr(xdr, OP_READDIR);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = copymem(readdir->verifier.data, p, 8);
 	dprintk("%s: verifier = %08x:%08x\n",
 			__func__,
@@ -3953,7 +4072,9 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 		return status;
 
 	/* Convert length of symlink */
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &len);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
@@ -4075,9 +4196,13 @@ static int decode_setattr(struct xdr_stream *xdr)
 	status = decode_op_hdr(xdr, OP_SETATTR);
 	if (status)
 		return status;
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &bmlen);
-	READ_BUF(bmlen << 2);
+	p = read_buf(xdr, bmlen << 2);
+	if (unlikely(!p))
+		return -EIO;
 	return 0;
 }
 
@@ -4087,7 +4212,9 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	uint32_t opnum;
 	int32_t nfserr;
 
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &opnum);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
@@ -4096,21 +4223,31 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	}
 	p = xdr_decode_int(p, &nfserr);
 	if (nfserr == NFS_OK) {
-		READ_BUF(8 + NFS4_VERIFIER_SIZE);
+		p = read_buf(xdr, 8 + NFS4_VERIFIER_SIZE);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_hyper(p, &clp->cl_clientid);
 		copymem(clp->cl_confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
 		/* skip netid string */
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &len);
-		READ_BUF(len);
+		p = read_buf(xdr, len);
+		if (unlikely(!p))
+			return -EIO;
 
 		/* skip uaddr string */
-		READ_BUF(4);
+		p = read_buf(xdr, 4);
+		if (unlikely(!p))
+			return -EIO;
 		p = xdr_decode_int(p, &len);
-		READ_BUF(len);
+		p = read_buf(xdr, len);
+		if (unlikely(!p))
+			return -EIO;
 		return -NFSERR_CLID_INUSE;
 	} else
 		return nfs4_stat_to_errno(nfserr);
@@ -4132,7 +4269,9 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 	if (status)
 		return status;
 
-	READ_BUF(16);
+	p = read_buf(xdr, 16);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &res->count);
 	p = xdr_decode_int(p, &res->verf->committed);
 	copymem(res->verf->verifier, p, 8);
@@ -4157,9 +4296,13 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	if (status)
 		return status;
 
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_hyper(p, &clp->cl_ex_clid);
-	READ_BUF(12);
+	p = read_buf(xdr, 12);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &clp->cl_seqid);
 	p = xdr_decode_int(p, &clp->cl_exchange_flags);
 
@@ -4169,22 +4312,36 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		return -EIO;
 
 	/* Throw away minor_id */
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 
 	/* Throw away Major id */
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &dummy);
-	READ_BUF(dummy);
+	p = read_buf(xdr, dummy);
+	if (unlikely(!p))
+		return -EIO;
 
 	/* Throw away server_scope */
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &dummy);
-	READ_BUF(dummy);
+	p = read_buf(xdr, dummy);
+	if (unlikely(!p))
+		return -EIO;
 
 	/* Throw away Implementation id array */
-	READ_BUF(4);
+	p = read_buf(xdr, 4);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &dummy);
-	READ_BUF(dummy);
+	p = read_buf(xdr, dummy);
+	if (unlikely(!p))
+		return -EIO;
 
 	return 0;
 }
@@ -4195,7 +4352,9 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	__be32 *p;
 	u32 nr_attrs;
 
-	READ_BUF(28);
+	p = read_buf(xdr, 28);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &attrs->headerpadsz);
 	p = xdr_decode_int(p, &attrs->max_rqst_sz);
 	p = xdr_decode_int(p, &attrs->max_resp_sz);
@@ -4208,8 +4367,11 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 			__func__, nr_attrs);
 		return -EINVAL;
 	}
-	if (nr_attrs == 1)
-		READ_BUF(4); /* skip rdma_attrs */
+	if (nr_attrs == 1) {
+		p = read_buf(xdr, 4); /* skip rdma_attrs */
+		if (unlikely(!p))
+			return -EIO;
+	}
 	return 0;
 }
 
@@ -4227,11 +4389,15 @@ static int decode_create_session(struct xdr_stream *xdr,
 		return status;
 
 	/* sessionid */
-	READ_BUF(NFS4_MAX_SESSIONID_LEN);
+	p = read_buf(xdr, NFS4_MAX_SESSIONID_LEN);
+	if (unlikely(!p))
+		return -EIO;
 	copymem(&session->sess_id, p, NFS4_MAX_SESSIONID_LEN);
 
 	/* seqid, flags */
-	READ_BUF(8);
+	p = read_buf(xdr, 8);
+	if (unlikely(!p))
+		return -EIO;
 	p = xdr_decode_int(p, &clp->cl_seqid);
 	p = xdr_decode_int(p, &session->flags);
 
@@ -4273,7 +4439,9 @@ static int decode_sequence(struct xdr_stream *xdr,
 	status = -ESERVERFAULT;
 
 	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
-	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
+	p = read_buf(xdr, NFS4_MAX_SESSIONID_LEN + 20);
+	if (unlikely(!p))
+		return -EIO;
 	p = copymem(id.data, p, NFS4_MAX_SESSIONID_LEN);
 	if (memcmp(id.data, res->sr_session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
-- 
1.6.4


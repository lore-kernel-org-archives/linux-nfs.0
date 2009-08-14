From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 20/21] nfs: nfs4xdr: get rid of READ_BUF
Date: Fri, 14 Aug 2009 17:20:14 +0300
Message-ID: <1250259614-14122-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:26152
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932220AbZHNOUW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:22 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use xdr_inline_decode instead.
Open code debug printout and error return.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  475 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 379 insertions(+), 96 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d971138..2c4a56f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2423,24 +2423,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
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
-		print_overflow_msg(__func__, xdr); \
-		return -EIO; \
-	} \
-} while (0)
-
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
 {
 	dprintk("nfs: %s: prematurely hit end of receive buffer. "
@@ -2452,28 +2434,42 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
 {
 	__be32 *p;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	*len = be32_to_cpup(p++);
-	READ_BUF(*len);
+	p = xdr_inline_decode(xdr, *len);
+	if (unlikely(!p))
+		goto out_overflow;
 	*string = (char *)p;
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	hdr->status = be32_to_cpup(p++);
 	hdr->taglen = be32_to_cpup(p++);
 
-	READ_BUF(hdr->taglen + 4);
+	p = xdr_inline_decode(xdr, hdr->taglen + 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	hdr->nops = be32_to_cpup(p++);
 	if (unlikely(hdr->nops < 1))
 		return nfs4_stat_to_errno(hdr->status);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
@@ -2482,7 +2478,9 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	uint32_t opnum;
 	int32_t nfserr;
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	opnum = be32_to_cpup(p++);
 	if (opnum != expected) {
 		dprintk("nfs: Server returned operation"
@@ -2494,6 +2492,9 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	if (nfserr != NFS_OK)
 		return nfs4_stat_to_errno(nfserr);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 /* Dummy routine */
@@ -2503,8 +2504,11 @@ static int decode_ace(struct xdr_stream *xdr, void *ace, struct nfs_client *clp)
 	unsigned int strlen;
 	char *str;
 
-	READ_BUF(12);
-	return decode_opaque_inline(xdr, &strlen, &str);
+	p = xdr_inline_decode(xdr, 12);
+	if (likely(p))
+		return decode_opaque_inline(xdr, &strlen, &str);
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
@@ -2512,27 +2516,39 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	uint32_t bmlen;
 	__be32 *p;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	bmlen = be32_to_cpup(p++);
 
 	bitmap[0] = bitmap[1] = 0;
-	READ_BUF((bmlen << 2));
+	p = xdr_inline_decode(xdr, (bmlen << 2));
+	if (unlikely(!p))
+		goto out_overflow;
 	if (bmlen > 0) {
 		bitmap[0] = be32_to_cpup(p++);
 		if (bmlen > 1)
 			bitmap[1] = be32_to_cpup(p++);
 	}
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen, __be32 **savep)
 {
 	__be32 *p;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	*attrlen = be32_to_cpup(p++);
 	*savep = xdr->p;
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *bitmask)
@@ -2555,7 +2571,9 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_TYPE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*type = be32_to_cpup(p++);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
@@ -2566,6 +2584,9 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 	}
 	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type]);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *change)
@@ -2577,7 +2598,9 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_CHANGE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_CHANGE)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
@@ -2585,6 +2608,9 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	dprintk("%s: change attribute=%Lu\n", __func__,
 			(unsigned long long)*change);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *size)
@@ -2596,13 +2622,18 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_SIZE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SIZE)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
 	}
 	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2613,12 +2644,17 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_LINK_SUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2629,12 +2665,17 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_SYMLINK_SUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_fsid *fsid)
@@ -2647,7 +2688,9 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FSID - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FSID)) {
-		READ_BUF(16);
+		p = xdr_inline_decode(xdr, 16);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, &fsid->major);
 		p = xdr_decode_hyper(p, &fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
@@ -2657,6 +2700,9 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 			(unsigned long long)fsid->major,
 			(unsigned long long)fsid->minor);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2667,12 +2713,17 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_LEASE_TIME - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2683,12 +2734,17 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACLSUPPORT - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
@@ -2700,13 +2756,18 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILEID - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILEID)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *fileid)
@@ -2718,13 +2779,18 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MOUNTED_ON_FILEID - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MOUNTED_ON_FILEID)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
 	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -2736,12 +2802,17 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_AVAIL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_AVAIL)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
 	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -2753,12 +2824,17 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_FREE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_FREE)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
 	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -2770,12 +2846,17 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_FILES_TOTAL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_FILES_TOTAL)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
 	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
@@ -2784,7 +2865,9 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	__be32 *p;
 	int status = 0;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	n = be32_to_cpup(p++);
 	if (n == 0)
 		goto root_path;
@@ -2819,6 +2902,9 @@ out_eio:
 	dprintk(" status %d", status);
 	status = -EIO;
 	goto out;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
@@ -2836,7 +2922,9 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
 		goto out;
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	n = be32_to_cpup(p++);
 	if (n <= 0)
 		goto out_eio;
@@ -2845,7 +2933,9 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		u32 m;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		m = be32_to_cpup(p++);
 
 		loc->nservers = 0;
@@ -2885,6 +2975,8 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
 out_eio:
 	status = -EIO;
 	goto out;
@@ -2899,12 +2991,17 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXFILESIZE - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXFILESIZE)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
 	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *maxlink)
@@ -2916,12 +3013,17 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXLINK - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*maxlink = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *maxname)
@@ -2933,12 +3035,17 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_MAXNAME - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*maxname = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2951,7 +3058,9 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXREAD)) {
 		uint64_t maxread;
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, &maxread);
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
@@ -2960,6 +3069,9 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 	}
 	dprintk("%s: maxread=%lu\n", __func__, (unsigned long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
@@ -2972,7 +3084,9 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXWRITE)) {
 		uint64_t maxwrite;
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, &maxwrite);
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
@@ -2981,6 +3095,9 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 	}
 	dprintk("%s: maxwrite=%lu\n", __func__, (unsigned long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *mode)
@@ -2993,7 +3110,9 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_MODE - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		tmp = be32_to_cpup(p++);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
@@ -3001,6 +3120,9 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 	}
 	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *nlink)
@@ -3012,13 +3134,18 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_NUMLINKS - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		*nlink = be32_to_cpup(p++);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
 	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *uid)
@@ -3031,9 +3158,13 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		len = be32_to_cpup(p++);
-		READ_BUF(len);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
 				ret = NFS_ATTR_FATTR_OWNER;
@@ -3047,6 +3178,9 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	}
 	dprintk("%s: uid=%d\n", __func__, (int)*uid);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs_client *clp, uint32_t *gid)
@@ -3059,9 +3193,13 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_OWNER_GROUP - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		len = be32_to_cpup(p++);
-		READ_BUF(len);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
 				ret = NFS_ATTR_FATTR_GROUP;
@@ -3075,6 +3213,9 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 	}
 	dprintk("%s: gid=%d\n", __func__, (int)*gid);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rdev)
@@ -3089,7 +3230,9 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 	if (likely(bitmap[1] & FATTR4_WORD1_RAWDEV)) {
 		dev_t tmp;
 
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		major = be32_to_cpup(p++);
 		minor = be32_to_cpup(p++);
 		tmp = MKDEV(major, minor);
@@ -3100,6 +3243,9 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 	}
 	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3111,12 +3257,17 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_AVAIL - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_AVAIL)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
 	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3128,12 +3279,17 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_FREE - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_FREE)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
 	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *res)
@@ -3145,12 +3301,17 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_TOTAL - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_TOTAL)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
 	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *used)
@@ -3162,7 +3323,9 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	if (unlikely(bitmap[1] & (FATTR4_WORD1_SPACE_USED - 1U)))
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_SPACE_USED)) {
-		READ_BUF(8);
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
@@ -3170,6 +3333,9 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 	dprintk("%s: space used=%Lu\n", __func__,
 			(unsigned long long)*used);
 	return ret;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
@@ -3178,12 +3344,17 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 	uint64_t sec;
 	uint32_t nsec;
 
-	READ_BUF(12);
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
 	p = xdr_decode_hyper(p, &sec);
 	nsec = be32_to_cpup(p++);
 	time->tv_sec = (time_t)sec;
 	time->tv_nsec = (long)nsec;
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
@@ -3261,11 +3432,16 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 {
 	__be32 *p;
 
-	READ_BUF(20);
+	p = xdr_inline_decode(xdr, 20);
+	if (unlikely(!p))
+		goto out_overflow;
 	cinfo->atomic = be32_to_cpup(p++);
 	p = xdr_decode_hyper(p, &cinfo->before);
 	p = xdr_decode_hyper(p, &cinfo->after);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
@@ -3277,12 +3453,17 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	status = decode_op_hdr(xdr, OP_ACCESS);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	supp = be32_to_cpup(p++);
 	acc = be32_to_cpup(p++);
 	access->supported = supp;
 	access->access = acc;
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
@@ -3341,10 +3522,16 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 		return status;
 	if ((status = decode_change_info(xdr, cinfo)))
 		return status;
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	bmlen = be32_to_cpup(p++);
-	READ_BUF(bmlen << 2);
-	return 0;
+	p = xdr_inline_decode(xdr, bmlen << 2);
+	if (likely(p))
+		return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
@@ -3596,14 +3783,21 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 	if (status)
 		return status;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	len = be32_to_cpup(p++);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
-	READ_BUF(len);
+	p = xdr_inline_decode(xdr, len);
+	if (unlikely(!p))
+		goto out_overflow;
 	memcpy(fh->data, p, len);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_link(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
@@ -3625,7 +3819,9 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	__be32 *p;
 	uint32_t namelen, type;
 
-	READ_BUF(32);
+	p = xdr_inline_decode(xdr, 32);
+	if (unlikely(!p))
+		goto out_overflow;
 	p = xdr_decode_hyper(p, &offset);
 	p = xdr_decode_hyper(p, &length);
 	type = be32_to_cpup(p++);
@@ -3641,8 +3837,12 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	}
 	p = xdr_decode_hyper(p, &clientid);
 	namelen = be32_to_cpup(p++);
-	READ_BUF(namelen);
-	return -NFS4ERR_DENIED;
+	p = xdr_inline_decode(xdr, namelen);
+	if (likely(p))
+		return -NFS4ERR_DENIED;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
@@ -3697,7 +3897,9 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	__be32 *p;
 	uint32_t limit_type, nblocks, blocksize;
 
-	READ_BUF(12);
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
 	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
 	case 1:
@@ -3709,6 +3911,9 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
@@ -3717,7 +3922,9 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	uint32_t delegation_type;
 	int status;
 
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	delegation_type = be32_to_cpup(p++);
 	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
 		res->delegation_type = 0;
@@ -3726,7 +3933,9 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	status = decode_stateid(xdr, &res->delegation);
 	if (unlikely(status))
 		return status;
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	res->do_recall = be32_to_cpup(p++);
 
 	switch (delegation_type) {
@@ -3739,6 +3948,9 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 				return -EIO;
 	}
 	return decode_ace(xdr, NULL, res->server->nfs_client);
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
@@ -3757,13 +3969,17 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	decode_change_info(xdr, &res->cinfo);
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	res->rflags = be32_to_cpup(p++);
 	bmlen = be32_to_cpup(p++);
 	if (bmlen > 10)
 		goto xdr_error;
 
-	READ_BUF(bmlen << 2);
+	p = xdr_inline_decode(xdr, bmlen << 2);
+	if (unlikely(!p))
+		goto out_overflow;
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
 		res->attrset[i] = be32_to_cpup(p++);
@@ -3774,6 +3990,9 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 xdr_error:
 	dprintk("%s: Bitmap too large! Length = %u\n", __func__, bmlen);
 	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmres *res)
@@ -3820,7 +4039,9 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	status = decode_op_hdr(xdr, OP_READ);
 	if (status)
 		return status;
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p++);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
@@ -3835,6 +4056,9 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	res->eof = eof;
 	res->count = count;
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readdir_res *readdir)
@@ -3947,7 +4171,9 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 		return status;
 
 	/* Convert length of symlink */
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	len = be32_to_cpup(p++);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
@@ -3972,6 +4198,9 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	kaddr[len+rcvbuf->page_base] = '\0';
 	kunmap_atomic(kaddr, KM_USER0);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_remove(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
@@ -4069,10 +4298,16 @@ static int decode_setattr(struct xdr_stream *xdr)
 	status = decode_op_hdr(xdr, OP_SETATTR);
 	if (status)
 		return status;
-	READ_BUF(4);
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	bmlen = be32_to_cpup(p++);
-	READ_BUF(bmlen << 2);
-	return 0;
+	p = xdr_inline_decode(xdr, bmlen << 2);
+	if (likely(p))
+		return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
@@ -4081,7 +4316,9 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	uint32_t opnum;
 	int32_t nfserr;
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	opnum = be32_to_cpup(p++);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
@@ -4090,26 +4327,39 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	}
 	nfserr = be32_to_cpup(p++);
 	if (nfserr == NFS_OK) {
-		READ_BUF(8 + NFS4_VERIFIER_SIZE);
+		p = xdr_inline_decode(xdr, 8 + NFS4_VERIFIER_SIZE);
+		if (unlikely(!p))
+			goto out_overflow;
 		p = xdr_decode_hyper(p, &clp->cl_clientid);
 		memcpy(clp->cl_confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
 		/* skip netid string */
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		len = be32_to_cpup(p++);
-		READ_BUF(len);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
 
 		/* skip uaddr string */
-		READ_BUF(4);
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		len = be32_to_cpup(p++);
-		READ_BUF(len);
+		p = xdr_inline_decode(xdr, len);
+		if (unlikely(!p))
+			goto out_overflow;
 		return -NFSERR_CLID_INUSE;
 	} else
 		return nfs4_stat_to_errno(nfserr);
 
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_setclientid_confirm(struct xdr_stream *xdr)
@@ -4126,11 +4376,16 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 	if (status)
 		return status;
 
-	READ_BUF(16);
+	p = xdr_inline_decode(xdr, 16);
+	if (unlikely(!p))
+		goto out_overflow;
 	res->count = be32_to_cpup(p++);
 	res->verf->committed = be32_to_cpup(p++);
 	memcpy(res->verf->verifier, p, 8);
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_delegreturn(struct xdr_stream *xdr)
@@ -4152,9 +4407,13 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	if (status)
 		return status;
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	p = xdr_decode_hyper(p, &clp->cl_ex_clid);
-	READ_BUF(12);
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
 	clp->cl_seqid = be32_to_cpup(p++);
 	clp->cl_exchange_flags = be32_to_cpup(p++);
 
@@ -4164,7 +4423,9 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		return -EIO;
 
 	/* Throw away minor_id */
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 
 	/* Throw away Major id */
 	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
@@ -4182,6 +4443,9 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 		return status;
 
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_chan_attrs(struct xdr_stream *xdr,
@@ -4190,7 +4454,9 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	__be32 *p;
 	u32 nr_attrs;
 
-	READ_BUF(28);
+	p = xdr_inline_decode(xdr, 28);
+	if (unlikely(!p))
+		goto out_overflow;
 	attrs->headerpadsz = be32_to_cpup(p++);
 	attrs->max_rqst_sz = be32_to_cpup(p++);
 	attrs->max_resp_sz = be32_to_cpup(p++);
@@ -4203,9 +4469,15 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 			__func__, nr_attrs);
 		return -EINVAL;
 	}
-	if (nr_attrs == 1)
-		READ_BUF(4); /* skip rdma_attrs */
+	if (nr_attrs == 1) {
+		p = xdr_inline_decode(xdr, 4); /* skip rdma_attrs */
+		if (unlikely(!p))
+			goto out_overflow;
+	}
 	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_sessionid(struct xdr_stream *xdr, struct nfs4_sessionid *sid)
@@ -4228,7 +4500,9 @@ static int decode_create_session(struct xdr_stream *xdr,
 		return status;
 
 	/* seqid, flags */
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	clp->cl_seqid = be32_to_cpup(p++);
 	session->flags = be32_to_cpup(p++);
 
@@ -4237,6 +4511,9 @@ static int decode_create_session(struct xdr_stream *xdr,
 	if (!status)
 		status = decode_chan_attrs(xdr, &session->bc_attrs);
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
 }
 
 static int decode_destroy_session(struct xdr_stream *xdr, void *dummy)
@@ -4277,7 +4554,9 @@ static int decode_sequence(struct xdr_stream *xdr,
 		goto out_err;
 	}
 
-	READ_BUF(20);
+	p = xdr_inline_decode(xdr, 20);
+	if (unlikely(!p))
+		goto out_overflow;
 
 	/* seqid */
 	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
@@ -4302,6 +4581,10 @@ static int decode_sequence(struct xdr_stream *xdr,
 out_err:
 	res->sr_status = status;
 	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	status = -EIO;
+	goto out_err;
 #else  /* CONFIG_NFS_V4_1 */
 	return 0;
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.4


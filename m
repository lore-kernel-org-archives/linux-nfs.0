From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 21/21] nfs: nfs4xdr: optimize low level decoding
Date: Fri, 14 Aug 2009 17:20:19 +0300
Message-ID: <1250259619-14154-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:29333
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932234AbZHNOU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:26 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

do not increment decoding ptr if not needed.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  118 +++++++++++++++++++++++++++---------------------------
 1 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2c4a56f..3ef9f9d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2437,7 +2437,7 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	*len = be32_to_cpup(p++);
+	*len = be32_to_cpup(p);
 	p = xdr_inline_decode(xdr, *len);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -2456,14 +2456,14 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	if (unlikely(!p))
 		goto out_overflow;
 	hdr->status = be32_to_cpup(p++);
-	hdr->taglen = be32_to_cpup(p++);
+	hdr->taglen = be32_to_cpup(p);
 
 	p = xdr_inline_decode(xdr, hdr->taglen + 4);
 	if (unlikely(!p))
 		goto out_overflow;
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
-	hdr->nops = be32_to_cpup(p++);
+	hdr->nops = be32_to_cpup(p);
 	if (unlikely(hdr->nops < 1))
 		return nfs4_stat_to_errno(hdr->status);
 	return 0;
@@ -2488,7 +2488,7 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 				opnum, expected);
 		return -EIO;
 	}
-	nfserr = be32_to_cpup(p++);
+	nfserr = be32_to_cpup(p);
 	if (nfserr != NFS_OK)
 		return nfs4_stat_to_errno(nfserr);
 	return 0;
@@ -2519,7 +2519,7 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	bmlen = be32_to_cpup(p++);
+	bmlen = be32_to_cpup(p);
 
 	bitmap[0] = bitmap[1] = 0;
 	p = xdr_inline_decode(xdr, (bmlen << 2));
@@ -2528,7 +2528,7 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	if (bmlen > 0) {
 		bitmap[0] = be32_to_cpup(p++);
 		if (bmlen > 1)
-			bitmap[1] = be32_to_cpup(p++);
+			bitmap[1] = be32_to_cpup(p);
 	}
 	return 0;
 out_overflow:
@@ -2543,7 +2543,7 @@ static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen,
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	*attrlen = be32_to_cpup(p++);
+	*attrlen = be32_to_cpup(p);
 	*savep = xdr->p;
 	return 0;
 out_overflow:
@@ -2574,7 +2574,7 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*type = be32_to_cpup(p++);
+		*type = be32_to_cpup(p);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
 			return -EIO;
@@ -2601,7 +2601,7 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, change);
+		xdr_decode_hyper(p, change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 		ret = NFS_ATTR_FATTR_CHANGE;
 	}
@@ -2625,7 +2625,7 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, size);
+		xdr_decode_hyper(p, size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 		ret = NFS_ATTR_FATTR_SIZE;
 	}
@@ -2647,7 +2647,7 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*res = be32_to_cpup(p++);
+		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2668,7 +2668,7 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*res = be32_to_cpup(p++);
+		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2692,7 +2692,7 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 		if (unlikely(!p))
 			goto out_overflow;
 		p = xdr_decode_hyper(p, &fsid->major);
-		p = xdr_decode_hyper(p, &fsid->minor);
+		xdr_decode_hyper(p, &fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
 		ret = NFS_ATTR_FATTR_FSID;
 	}
@@ -2716,7 +2716,7 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*res = be32_to_cpup(p++);
+		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
@@ -2737,7 +2737,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*res = be32_to_cpup(p++);
+		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
@@ -2759,7 +2759,7 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, fileid);
+		xdr_decode_hyper(p, fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
@@ -2782,7 +2782,7 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, fileid);
+		xdr_decode_hyper(p, fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 		ret = NFS_ATTR_FATTR_FILEID;
 	}
@@ -2805,7 +2805,7 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
 	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
@@ -2827,7 +2827,7 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
 	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
@@ -2849,7 +2849,7 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
 	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
@@ -2868,7 +2868,7 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	n = be32_to_cpup(p++);
+	n = be32_to_cpup(p);
 	if (n == 0)
 		goto root_path;
 	dprintk("path ");
@@ -2925,7 +2925,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	n = be32_to_cpup(p++);
+	n = be32_to_cpup(p);
 	if (n <= 0)
 		goto out_eio;
 	res->nlocations = 0;
@@ -2936,7 +2936,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		m = be32_to_cpup(p++);
+		m = be32_to_cpup(p);
 
 		loc->nservers = 0;
 		dprintk("%s: servers ", __func__);
@@ -2994,7 +2994,7 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
 	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
@@ -3016,7 +3016,7 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*maxlink = be32_to_cpup(p++);
+		*maxlink = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
@@ -3038,7 +3038,7 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*maxname = be32_to_cpup(p++);
+		*maxname = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
@@ -3061,7 +3061,7 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, &maxread);
+		xdr_decode_hyper(p, &maxread);
 		if (maxread > 0x7FFFFFFF)
 			maxread = 0x7FFFFFFF;
 		*res = (uint32_t)maxread;
@@ -3087,7 +3087,7 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, &maxwrite);
+		xdr_decode_hyper(p, &maxwrite);
 		if (maxwrite > 0x7FFFFFFF)
 			maxwrite = 0x7FFFFFFF;
 		*res = (uint32_t)maxwrite;
@@ -3113,7 +3113,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		tmp = be32_to_cpup(p++);
+		tmp = be32_to_cpup(p);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 		ret = NFS_ATTR_FATTR_MODE;
@@ -3137,7 +3137,7 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		*nlink = be32_to_cpup(p++);
+		*nlink = be32_to_cpup(p);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
@@ -3161,7 +3161,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		len = be32_to_cpup(p++);
+		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
@@ -3196,7 +3196,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		len = be32_to_cpup(p++);
+		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
@@ -3234,7 +3234,7 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 		if (unlikely(!p))
 			goto out_overflow;
 		major = be32_to_cpup(p++);
-		minor = be32_to_cpup(p++);
+		minor = be32_to_cpup(p);
 		tmp = MKDEV(major, minor);
 		if (MAJOR(tmp) == major && MINOR(tmp) == minor)
 			*rdev = tmp;
@@ -3260,7 +3260,7 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
 	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
@@ -3282,7 +3282,7 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
 	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
@@ -3304,7 +3304,7 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, res);
+		xdr_decode_hyper(p, res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
 	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
@@ -3326,7 +3326,7 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		p = xdr_inline_decode(xdr, 8);
 		if (unlikely(!p))
 			goto out_overflow;
-		p = xdr_decode_hyper(p, used);
+		xdr_decode_hyper(p, used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 		ret = NFS_ATTR_FATTR_SPACE_USED;
 	}
@@ -3348,7 +3348,7 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 	if (unlikely(!p))
 		goto out_overflow;
 	p = xdr_decode_hyper(p, &sec);
-	nsec = be32_to_cpup(p++);
+	nsec = be32_to_cpup(p);
 	time->tv_sec = (time_t)sec;
 	time->tv_nsec = (long)nsec;
 	return 0;
@@ -3437,7 +3437,7 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 		goto out_overflow;
 	cinfo->atomic = be32_to_cpup(p++);
 	p = xdr_decode_hyper(p, &cinfo->before);
-	p = xdr_decode_hyper(p, &cinfo->after);
+	xdr_decode_hyper(p, &cinfo->after);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -3457,7 +3457,7 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	if (unlikely(!p))
 		goto out_overflow;
 	supp = be32_to_cpup(p++);
-	acc = be32_to_cpup(p++);
+	acc = be32_to_cpup(p);
 	access->supported = supp;
 	access->access = acc;
 	return 0;
@@ -3525,7 +3525,7 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	bmlen = be32_to_cpup(p++);
+	bmlen = be32_to_cpup(p);
 	p = xdr_inline_decode(xdr, bmlen << 2);
 	if (likely(p))
 		return 0;
@@ -3786,7 +3786,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	len = be32_to_cpup(p++);
+	len = be32_to_cpup(p);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
@@ -3836,7 +3836,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 		fl->fl_pid = 0;
 	}
 	p = xdr_decode_hyper(p, &clientid);
-	namelen = be32_to_cpup(p++);
+	namelen = be32_to_cpup(p);
 	p = xdr_inline_decode(xdr, namelen);
 	if (likely(p))
 		return -NFS4ERR_DENIED;
@@ -3903,11 +3903,11 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
 	case 1:
-		p = xdr_decode_hyper(p, maxsize);
+		xdr_decode_hyper(p, maxsize);
 		break;
 	case 2:
 		nblocks = be32_to_cpup(p++);
-		blocksize = be32_to_cpup(p++);
+		blocksize = be32_to_cpup(p);
 		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
 	return 0;
@@ -3925,7 +3925,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	delegation_type = be32_to_cpup(p++);
+	delegation_type = be32_to_cpup(p);
 	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
 		res->delegation_type = 0;
 		return 0;
@@ -3936,7 +3936,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	res->do_recall = be32_to_cpup(p++);
+	res->do_recall = be32_to_cpup(p);
 
 	switch (delegation_type) {
 	case NFS4_OPEN_DELEGATE_READ:
@@ -3973,7 +3973,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	if (unlikely(!p))
 		goto out_overflow;
 	res->rflags = be32_to_cpup(p++);
-	bmlen = be32_to_cpup(p++);
+	bmlen = be32_to_cpup(p);
 	if (bmlen > 10)
 		goto xdr_error;
 
@@ -4043,7 +4043,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	if (unlikely(!p))
 		goto out_overflow;
 	eof = be32_to_cpup(p++);
-	count = be32_to_cpup(p++);
+	count = be32_to_cpup(p);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
@@ -4174,7 +4174,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	len = be32_to_cpup(p++);
+	len = be32_to_cpup(p);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
@@ -4301,7 +4301,7 @@ static int decode_setattr(struct xdr_stream *xdr)
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-	bmlen = be32_to_cpup(p++);
+	bmlen = be32_to_cpup(p);
 	p = xdr_inline_decode(xdr, bmlen << 2);
 	if (likely(p))
 		return 0;
@@ -4325,7 +4325,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 			" %d\n", opnum);
 		return -EIO;
 	}
-	nfserr = be32_to_cpup(p++);
+	nfserr = be32_to_cpup(p);
 	if (nfserr == NFS_OK) {
 		p = xdr_inline_decode(xdr, 8 + NFS4_VERIFIER_SIZE);
 		if (unlikely(!p))
@@ -4339,7 +4339,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		len = be32_to_cpup(p++);
+		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
@@ -4348,7 +4348,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
-		len = be32_to_cpup(p++);
+		len = be32_to_cpup(p);
 		p = xdr_inline_decode(xdr, len);
 		if (unlikely(!p))
 			goto out_overflow;
@@ -4410,7 +4410,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, 8);
 	if (unlikely(!p))
 		goto out_overflow;
-	p = xdr_decode_hyper(p, &clp->cl_ex_clid);
+	xdr_decode_hyper(p, &clp->cl_ex_clid);
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -4418,7 +4418,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	clp->cl_exchange_flags = be32_to_cpup(p++);
 
 	/* We ask for SP4_NONE */
-	dummy = be32_to_cpup(p++);
+	dummy = be32_to_cpup(p);
 	if (dummy != SP4_NONE)
 		return -EIO;
 
@@ -4463,7 +4463,7 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	attrs->max_resp_sz_cached = be32_to_cpup(p++);
 	attrs->max_ops = be32_to_cpup(p++);
 	attrs->max_reqs = be32_to_cpup(p++);
-	nr_attrs = be32_to_cpup(p++);
+	nr_attrs = be32_to_cpup(p);
 	if (unlikely(nr_attrs > 1)) {
 		printk(KERN_WARNING "%s: Invalid rdma channel attrs count %u\n",
 			__func__, nr_attrs);
@@ -4504,7 +4504,7 @@ static int decode_create_session(struct xdr_stream *xdr,
 	if (unlikely(!p))
 		goto out_overflow;
 	clp->cl_seqid = be32_to_cpup(p++);
-	session->flags = be32_to_cpup(p++);
+	session->flags = be32_to_cpup(p);
 
 	/* Channel attributes */
 	status = decode_chan_attrs(xdr, &session->fc_attrs);
@@ -4576,7 +4576,7 @@ static int decode_sequence(struct xdr_stream *xdr,
 	/* target highest slot id - currently not processed */
 	dummy = be32_to_cpup(p++);
 	/* result flags - currently not processed */
-	dummy = be32_to_cpup(p++);
+	dummy = be32_to_cpup(p);
 	status = 0;
 out_err:
 	res->sr_status = status;
-- 
1.6.4


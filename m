From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 09/13] nfs: nfs4xdr: get rid of READ32
Date: Wed, 12 Aug 2009 18:22:24 +0300
Message-ID: <1250090544-9799-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:11313
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752664AbZHLPWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:25 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

use xdr_decode_int instead.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  145 +++++++++++++++++++++++++++---------------------------
 1 files changed, 72 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7fac008..5c2b905 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2448,7 +2448,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define READ32(x)         (x) = ntohl(*p++)
 #define READ64(x)         do {			\
 	(x) = (u64)ntohl(*p++) << 32;		\
 	(x) |= ntohl(*p++);			\
@@ -2479,7 +2478,7 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(*len);
+	p = xdr_decode_int(p, len);
 	READ_BUF(*len);
 	*string = (char *)p;
 	return 0;
@@ -2490,13 +2489,13 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	READ_BUF(8);
-	READ32(hdr->status);
-	READ32(hdr->taglen);
+	p = xdr_decode_int(p, &hdr->status);
+	p = xdr_decode_int(p, &hdr->taglen);
 
 	READ_BUF(hdr->taglen + 4);
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
-	READ32(hdr->nops);
+	p = xdr_decode_int(p, &hdr->nops);
 	if (unlikely(hdr->nops < 1))
 		return nfs4_stat_to_errno(hdr->status);
 	return 0;
@@ -2509,14 +2508,14 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	int32_t nfserr;
 
 	READ_BUF(8);
-	READ32(opnum);
+	p = xdr_decode_int(p, &opnum);
 	if (opnum != expected) {
 		dprintk("nfs: Server returned operation"
 			" %d but we issued a request for %d\n",
 				opnum, expected);
 		return -EIO;
 	}
-	READ32(nfserr);
+	p = xdr_decode_int(p, &nfserr);
 	if (nfserr != NFS_OK)
 		return nfs4_stat_to_errno(nfserr);
 	return 0;
@@ -2539,14 +2538,14 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(bmlen);
+	p = xdr_decode_int(p, &bmlen);
 
 	bitmap[0] = bitmap[1] = 0;
 	READ_BUF((bmlen << 2));
 	if (bmlen > 0) {
-		READ32(bitmap[0]);
+		p = xdr_decode_int(p, &bitmap[0]);
 		if (bmlen > 1)
-			READ32(bitmap[1]);
+			p = xdr_decode_int(p, &bitmap[1]);
 	}
 	return 0;
 }
@@ -2556,7 +2555,7 @@ static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen,
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(*attrlen);
+	p = xdr_decode_int(p, attrlen);
 	*savep = xdr->p;
 	return 0;
 }
@@ -2582,7 +2581,7 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
 		READ_BUF(4);
-		READ32(*type);
+		p = xdr_decode_int(p, type);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
 			return -EIO;
@@ -2640,7 +2639,7 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2656,7 +2655,7 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2694,7 +2693,7 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
 		READ_BUF(4);
-		READ32(*res);
+		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
@@ -2710,7 +2709,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		p = xdr_decode_int(p, res);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
@@ -2811,7 +2810,7 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	int status = 0;
 
 	READ_BUF(4);
-	READ32(n);
+	p = xdr_decode_int(p, &n);
 	if (n == 0)
 		goto root_path;
 	dprintk("path ");
@@ -2863,7 +2862,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	if (unlikely(status != 0))
 		goto out;
 	READ_BUF(4);
-	READ32(n);
+	p = xdr_decode_int(p, &n);
 	if (n <= 0)
 		goto out_eio;
 	res->nlocations = 0;
@@ -2872,7 +2871,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
-		READ32(m);
+		p = xdr_decode_int(p, &m);
 
 		loc->nservers = 0;
 		dprintk("%s: servers ", __func__);
@@ -2943,7 +2942,7 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
 		READ_BUF(4);
-		READ32(*maxlink);
+		p = xdr_decode_int(p, maxlink);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
@@ -2960,7 +2959,7 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
 		READ_BUF(4);
-		READ32(*maxname);
+		p = xdr_decode_int(p, maxname);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
@@ -3020,7 +3019,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
 		READ_BUF(4);
-		READ32(tmp);
+		p = xdr_decode_int(p, &tmp);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 		ret = NFS_ATTR_FATTR_MODE;
@@ -3039,7 +3038,7 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
 		READ_BUF(4);
-		READ32(*nlink);
+		p = xdr_decode_int(p, nlink);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
@@ -3058,7 +3057,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
 		READ_BUF(4);
-		READ32(len);
+		p = xdr_decode_int(p, &len);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
@@ -3086,7 +3085,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
 		READ_BUF(4);
-		READ32(len);
+		p = xdr_decode_int(p, &len);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
@@ -3116,8 +3115,8 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 		dev_t tmp;
 
 		READ_BUF(8);
-		READ32(major);
-		READ32(minor);
+		p = xdr_decode_int(p, &major);
+		p = xdr_decode_int(p, &minor);
 		tmp = MKDEV(major, minor);
 		if (MAJOR(tmp) == major && MINOR(tmp) == minor)
 			*rdev = tmp;
@@ -3206,7 +3205,7 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 
 	READ_BUF(12);
 	READ64(sec);
-	READ32(nsec);
+	p = xdr_decode_int(p, &nsec);
 	time->tv_sec = (time_t)sec;
 	time->tv_nsec = (long)nsec;
 	return 0;
@@ -3288,7 +3287,7 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 	__be32 *p;
 
 	READ_BUF(20);
-	READ32(cinfo->atomic);
+	p = xdr_decode_int(p, &cinfo->atomic);
 	READ64(cinfo->before);
 	READ64(cinfo->after);
 	return 0;
@@ -3304,8 +3303,8 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	if (status)
 		return status;
 	READ_BUF(8);
-	READ32(supp);
-	READ32(acc);
+	p = xdr_decode_int(p, &supp);
+	p = xdr_decode_int(p, &acc);
 	access->supported = supp;
 	access->access = acc;
 	return 0;
@@ -3351,7 +3350,7 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 	if ((status = decode_change_info(xdr, cinfo)))
 		return status;
 	READ_BUF(4);
-	READ32(bmlen);
+	p = xdr_decode_int(p, &bmlen);
 	READ_BUF(bmlen << 2);
 	return 0;
 }
@@ -3606,7 +3605,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 		return status;
 
 	READ_BUF(4);
-	READ32(len);
+	p = xdr_decode_int(p, &len);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
@@ -3637,7 +3636,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	READ_BUF(32);
 	READ64(offset);
 	READ64(length);
-	READ32(type);
+	p = xdr_decode_int(p, &type);
 	if (fl != NULL) {
 		fl->fl_start = (loff_t)offset;
 		fl->fl_end = fl->fl_start + (loff_t)length - 1;
@@ -3649,7 +3648,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 		fl->fl_pid = 0;
 	}
 	READ64(clientid);
-	READ32(namelen);
+	p = xdr_decode_int(p, &namelen);
 	READ_BUF(namelen);
 	return -NFS4ERR_DENIED;
 }
@@ -3710,14 +3709,14 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	uint32_t limit_type, nblocks, blocksize;
 
 	READ_BUF(12);
-	READ32(limit_type);
+	p = xdr_decode_int(p, &limit_type);
 	switch (limit_type) {
 	case 1:
 		READ64(*maxsize);
 		break;
 	case 2:
-		READ32(nblocks);
-		READ32(blocksize);
+		p = xdr_decode_int(p, &nblocks);
+		p = xdr_decode_int(p, &blocksize);
 		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
 	return 0;
@@ -3729,14 +3728,14 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	uint32_t delegation_type;
 
 	READ_BUF(4);
-	READ32(delegation_type);
+	p = xdr_decode_int(p, &delegation_type);
 	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
 		res->delegation_type = 0;
 		return 0;
 	}
 	READ_BUF(NFS4_STATEID_SIZE+4);
 	COPYMEM(res->delegation.data, NFS4_STATEID_SIZE);
-	READ32(res->do_recall);
+	p = xdr_decode_int(p, &res->do_recall);
 
 	switch (delegation_type) {
 	case NFS4_OPEN_DELEGATE_READ:
@@ -3767,15 +3766,15 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	decode_change_info(xdr, &res->cinfo);
 
 	READ_BUF(8);
-	READ32(res->rflags);
-	READ32(bmlen);
+	p = xdr_decode_int(p, &res->rflags);
+	p = xdr_decode_int(p, &bmlen);
 	if (bmlen > 10)
 		goto xdr_error;
 
 	READ_BUF(bmlen << 2);
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
-		READ32(res->attrset[i]);
+		p = xdr_decode_int(p, &res->attrset[i]);
 	for (; i < NFS4_BITMAP_SIZE; i++)
 		res->attrset[i] = 0;
 
@@ -3836,8 +3835,8 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	if (status)
 		return status;
 	READ_BUF(8);
-	READ32(eof);
-	READ32(count);
+	p = xdr_decode_int(p, &eof);
+	p = xdr_decode_int(p, &count);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
@@ -3963,7 +3962,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 
 	/* Convert length of symlink */
 	READ_BUF(4);
-	READ32(len);
+	p = xdr_decode_int(p, &len);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
@@ -4085,7 +4084,7 @@ static int decode_setattr(struct xdr_stream *xdr)
 	if (status)
 		return status;
 	READ_BUF(4);
-	READ32(bmlen);
+	p = xdr_decode_int(p, &bmlen);
 	READ_BUF(bmlen << 2);
 	return 0;
 }
@@ -4097,13 +4096,13 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	int32_t nfserr;
 
 	READ_BUF(8);
-	READ32(opnum);
+	p = xdr_decode_int(p, &opnum);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
 			" %d\n", opnum);
 		return -EIO;
 	}
-	READ32(nfserr);
+	p = xdr_decode_int(p, &nfserr);
 	if (nfserr == NFS_OK) {
 		READ_BUF(8 + NFS4_VERIFIER_SIZE);
 		READ64(clp->cl_clientid);
@@ -4113,12 +4112,12 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 
 		/* skip netid string */
 		READ_BUF(4);
-		READ32(len);
+		p = xdr_decode_int(p, &len);
 		READ_BUF(len);
 
 		/* skip uaddr string */
 		READ_BUF(4);
-		READ32(len);
+		p = xdr_decode_int(p, &len);
 		READ_BUF(len);
 		return -NFSERR_CLID_INUSE;
 	} else
@@ -4142,8 +4141,8 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 		return status;
 
 	READ_BUF(16);
-	READ32(res->count);
-	READ32(res->verf->committed);
+	p = xdr_decode_int(p, &res->count);
+	p = xdr_decode_int(p, &res->verf->committed);
 	COPYMEM(res->verf->verifier, 8);
 	return 0;
 }
@@ -4169,11 +4168,11 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	READ_BUF(8);
 	READ64(clp->cl_ex_clid);
 	READ_BUF(12);
-	READ32(clp->cl_seqid);
-	READ32(clp->cl_exchange_flags);
+	p = xdr_decode_int(p, &clp->cl_seqid);
+	p = xdr_decode_int(p, &clp->cl_exchange_flags);
 
 	/* We ask for SP4_NONE */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	if (dummy != SP4_NONE)
 		return -EIO;
 
@@ -4182,17 +4181,17 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 
 	/* Throw away Major id */
 	READ_BUF(4);
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	READ_BUF(dummy);
 
 	/* Throw away server_scope */
 	READ_BUF(4);
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	READ_BUF(dummy);
 
 	/* Throw away Implementation id array */
 	READ_BUF(4);
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	READ_BUF(dummy);
 
 	return 0;
@@ -4205,13 +4204,13 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	u32 nr_attrs;
 
 	READ_BUF(28);
-	READ32(attrs->headerpadsz);
-	READ32(attrs->max_rqst_sz);
-	READ32(attrs->max_resp_sz);
-	READ32(attrs->max_resp_sz_cached);
-	READ32(attrs->max_ops);
-	READ32(attrs->max_reqs);
-	READ32(nr_attrs);
+	p = xdr_decode_int(p, &attrs->headerpadsz);
+	p = xdr_decode_int(p, &attrs->max_rqst_sz);
+	p = xdr_decode_int(p, &attrs->max_resp_sz);
+	p = xdr_decode_int(p, &attrs->max_resp_sz_cached);
+	p = xdr_decode_int(p, &attrs->max_ops);
+	p = xdr_decode_int(p, &attrs->max_reqs);
+	p = xdr_decode_int(p, &nr_attrs);
 	if (unlikely(nr_attrs > 1)) {
 		printk(KERN_WARNING "%s: Invalid rdma channel attrs count %u\n",
 			__func__, nr_attrs);
@@ -4241,8 +4240,8 @@ static int decode_create_session(struct xdr_stream *xdr,
 
 	/* seqid, flags */
 	READ_BUF(8);
-	READ32(clp->cl_seqid);
-	READ32(session->flags);
+	p = xdr_decode_int(p, &clp->cl_seqid);
+	p = xdr_decode_int(p, &session->flags);
 
 	/* Channel attributes */
 	status = decode_chan_attrs(xdr, &session->fc_attrs);
@@ -4290,23 +4289,23 @@ static int decode_sequence(struct xdr_stream *xdr,
 		goto out_err;
 	}
 	/* seqid */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	if (dummy != slot->seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out_err;
 	}
 	/* slot id */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	if (dummy != res->sr_slotid) {
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
 	/* highest slot id - currently not processed */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	/* target highest slot id - currently not processed */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	/* result flags - currently not processed */
-	READ32(dummy);
+	p = xdr_decode_int(p, &dummy);
 	status = 0;
 out_err:
 	res->sr_status = status;
-- 
1.6.4


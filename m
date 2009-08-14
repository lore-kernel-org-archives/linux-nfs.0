From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 11/21] nfs: nfs4xdr: get rid of READ32
Date: Fri, 14 Aug 2009 17:19:37 +0300
Message-ID: <1250259577-13833-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27316
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756887AbZHNOTn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:19:43 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

s/READ32\((.*)\)/\1 = be32_to_cpup(p++)/

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |  145 +++++++++++++++++++++++++++---------------------------
 1 files changed, 72 insertions(+), 73 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index efa78ad..5f6b46f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2433,7 +2433,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define READ32(x)         (x) = ntohl(*p++)
 #define READ64(x)         do {			\
 	(x) = (u64)ntohl(*p++) << 32;		\
 	(x) |= ntohl(*p++);			\
@@ -2464,7 +2463,7 @@ static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(*len);
+	*len = be32_to_cpup(p++);
 	READ_BUF(*len);
 	*string = (char *)p;
 	return 0;
@@ -2475,13 +2474,13 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	__be32 *p;
 
 	READ_BUF(8);
-	READ32(hdr->status);
-	READ32(hdr->taglen);
+	hdr->status = be32_to_cpup(p++);
+	hdr->taglen = be32_to_cpup(p++);
 
 	READ_BUF(hdr->taglen + 4);
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
-	READ32(hdr->nops);
+	hdr->nops = be32_to_cpup(p++);
 	if (unlikely(hdr->nops < 1))
 		return nfs4_stat_to_errno(hdr->status);
 	return 0;
@@ -2494,14 +2493,14 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	int32_t nfserr;
 
 	READ_BUF(8);
-	READ32(opnum);
+	opnum = be32_to_cpup(p++);
 	if (opnum != expected) {
 		dprintk("nfs: Server returned operation"
 			" %d but we issued a request for %d\n",
 				opnum, expected);
 		return -EIO;
 	}
-	READ32(nfserr);
+	nfserr = be32_to_cpup(p++);
 	if (nfserr != NFS_OK)
 		return nfs4_stat_to_errno(nfserr);
 	return 0;
@@ -2524,14 +2523,14 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(bmlen);
+	bmlen = be32_to_cpup(p++);
 
 	bitmap[0] = bitmap[1] = 0;
 	READ_BUF((bmlen << 2));
 	if (bmlen > 0) {
-		READ32(bitmap[0]);
+		bitmap[0] = be32_to_cpup(p++);
 		if (bmlen > 1)
-			READ32(bitmap[1]);
+			bitmap[1] = be32_to_cpup(p++);
 	}
 	return 0;
 }
@@ -2541,7 +2540,7 @@ static inline int decode_attr_length(struct xdr_stream *xdr, uint32_t *attrlen,
 	__be32 *p;
 
 	READ_BUF(4);
-	READ32(*attrlen);
+	*attrlen = be32_to_cpup(p++);
 	*savep = xdr->p;
 	return 0;
 }
@@ -2567,7 +2566,7 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_TYPE)) {
 		READ_BUF(4);
-		READ32(*type);
+		*type = be32_to_cpup(p++);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
 			dprintk("%s: bad type %d\n", __func__, *type);
 			return -EIO;
@@ -2625,7 +2624,7 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LINK_SUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
 	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2641,7 +2640,7 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_SYMLINK_SUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
 	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
@@ -2679,7 +2678,7 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_LEASE_TIME)) {
 		READ_BUF(4);
-		READ32(*res);
+		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
 	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
@@ -2695,7 +2694,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACLSUPPORT)) {
 		READ_BUF(4);
-		READ32(*res);
+		*res = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
 	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
@@ -2796,7 +2795,7 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
 	int status = 0;
 
 	READ_BUF(4);
-	READ32(n);
+	n = be32_to_cpup(p++);
 	if (n == 0)
 		goto root_path;
 	dprintk("path ");
@@ -2848,7 +2847,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	if (unlikely(status != 0))
 		goto out;
 	READ_BUF(4);
-	READ32(n);
+	n = be32_to_cpup(p++);
 	if (n <= 0)
 		goto out_eio;
 	res->nlocations = 0;
@@ -2857,7 +2856,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
-		READ32(m);
+		m = be32_to_cpup(p++);
 
 		loc->nservers = 0;
 		dprintk("%s: servers ", __func__);
@@ -2928,7 +2927,7 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXLINK)) {
 		READ_BUF(4);
-		READ32(*maxlink);
+		*maxlink = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
 	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
@@ -2945,7 +2944,7 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_MAXNAME)) {
 		READ_BUF(4);
-		READ32(*maxname);
+		*maxname = be32_to_cpup(p++);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
 	dprintk("%s: maxname=%u\n", __func__, *maxname);
@@ -3005,7 +3004,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, umode_t *m
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_MODE)) {
 		READ_BUF(4);
-		READ32(tmp);
+		tmp = be32_to_cpup(p++);
 		*mode = tmp & ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 		ret = NFS_ATTR_FATTR_MODE;
@@ -3024,7 +3023,7 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_NUMLINKS)) {
 		READ_BUF(4);
-		READ32(*nlink);
+		*nlink = be32_to_cpup(p++);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 		ret = NFS_ATTR_FATTR_NLINK;
 	}
@@ -3043,7 +3042,7 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER)) {
 		READ_BUF(4);
-		READ32(len);
+		len = be32_to_cpup(p++);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) == 0)
@@ -3071,7 +3070,7 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		return -EIO;
 	if (likely(bitmap[1] & FATTR4_WORD1_OWNER_GROUP)) {
 		READ_BUF(4);
-		READ32(len);
+		len = be32_to_cpup(p++);
 		READ_BUF(len);
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) == 0)
@@ -3101,8 +3100,8 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 		dev_t tmp;
 
 		READ_BUF(8);
-		READ32(major);
-		READ32(minor);
+		major = be32_to_cpup(p++);
+		minor = be32_to_cpup(p++);
 		tmp = MKDEV(major, minor);
 		if (MAJOR(tmp) == major && MINOR(tmp) == minor)
 			*rdev = tmp;
@@ -3191,7 +3190,7 @@ static int decode_attr_time(struct xdr_stream *xdr, struct timespec *time)
 
 	READ_BUF(12);
 	READ64(sec);
-	READ32(nsec);
+	nsec = be32_to_cpup(p++);
 	time->tv_sec = (time_t)sec;
 	time->tv_nsec = (long)nsec;
 	return 0;
@@ -3273,7 +3272,7 @@ static int decode_change_info(struct xdr_stream *xdr, struct nfs4_change_info *c
 	__be32 *p;
 
 	READ_BUF(20);
-	READ32(cinfo->atomic);
+	cinfo->atomic = be32_to_cpup(p++);
 	READ64(cinfo->before);
 	READ64(cinfo->after);
 	return 0;
@@ -3289,8 +3288,8 @@ static int decode_access(struct xdr_stream *xdr, struct nfs4_accessres *access)
 	if (status)
 		return status;
 	READ_BUF(8);
-	READ32(supp);
-	READ32(acc);
+	supp = be32_to_cpup(p++);
+	acc = be32_to_cpup(p++);
 	access->supported = supp;
 	access->access = acc;
 	return 0;
@@ -3336,7 +3335,7 @@ static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
 	if ((status = decode_change_info(xdr, cinfo)))
 		return status;
 	READ_BUF(4);
-	READ32(bmlen);
+	bmlen = be32_to_cpup(p++);
 	READ_BUF(bmlen << 2);
 	return 0;
 }
@@ -3591,7 +3590,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 		return status;
 
 	READ_BUF(4);
-	READ32(len);
+	len = be32_to_cpup(p++);
 	if (len > NFS4_FHSIZE)
 		return -EIO;
 	fh->size = len;
@@ -3622,7 +3621,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	READ_BUF(32);
 	READ64(offset);
 	READ64(length);
-	READ32(type);
+	type = be32_to_cpup(p++);
 	if (fl != NULL) {
 		fl->fl_start = (loff_t)offset;
 		fl->fl_end = fl->fl_start + (loff_t)length - 1;
@@ -3634,7 +3633,7 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 		fl->fl_pid = 0;
 	}
 	READ64(clientid);
-	READ32(namelen);
+	namelen = be32_to_cpup(p++);
 	READ_BUF(namelen);
 	return -NFS4ERR_DENIED;
 }
@@ -3695,14 +3694,14 @@ static int decode_space_limit(struct xdr_stream *xdr, u64 *maxsize)
 	uint32_t limit_type, nblocks, blocksize;
 
 	READ_BUF(12);
-	READ32(limit_type);
+	limit_type = be32_to_cpup(p++);
 	switch (limit_type) {
 	case 1:
 		READ64(*maxsize);
 		break;
 	case 2:
-		READ32(nblocks);
-		READ32(blocksize);
+		nblocks = be32_to_cpup(p++);
+		blocksize = be32_to_cpup(p++);
 		*maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
 	return 0;
@@ -3714,14 +3713,14 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 	uint32_t delegation_type;
 
 	READ_BUF(4);
-	READ32(delegation_type);
+	delegation_type = be32_to_cpup(p++);
 	if (delegation_type == NFS4_OPEN_DELEGATE_NONE) {
 		res->delegation_type = 0;
 		return 0;
 	}
 	READ_BUF(NFS4_STATEID_SIZE+4);
 	COPYMEM(res->delegation.data, NFS4_STATEID_SIZE);
-	READ32(res->do_recall);
+	res->do_recall = be32_to_cpup(p++);
 
 	switch (delegation_type) {
 	case NFS4_OPEN_DELEGATE_READ:
@@ -3752,15 +3751,15 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	decode_change_info(xdr, &res->cinfo);
 
 	READ_BUF(8);
-	READ32(res->rflags);
-	READ32(bmlen);
+	res->rflags = be32_to_cpup(p++);
+	bmlen = be32_to_cpup(p++);
 	if (bmlen > 10)
 		goto xdr_error;
 
 	READ_BUF(bmlen << 2);
 	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
 	for (i = 0; i < savewords; ++i)
-		READ32(res->attrset[i]);
+		res->attrset[i] = be32_to_cpup(p++);
 	for (; i < NFS4_BITMAP_SIZE; i++)
 		res->attrset[i] = 0;
 
@@ -3821,8 +3820,8 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 	if (status)
 		return status;
 	READ_BUF(8);
-	READ32(eof);
-	READ32(count);
+	eof = be32_to_cpup(p++);
+	count = be32_to_cpup(p++);
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
@@ -3948,7 +3947,7 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 
 	/* Convert length of symlink */
 	READ_BUF(4);
-	READ32(len);
+	len = be32_to_cpup(p++);
 	if (len >= rcvbuf->page_len || len <= 0) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
@@ -4070,7 +4069,7 @@ static int decode_setattr(struct xdr_stream *xdr)
 	if (status)
 		return status;
 	READ_BUF(4);
-	READ32(bmlen);
+	bmlen = be32_to_cpup(p++);
 	READ_BUF(bmlen << 2);
 	return 0;
 }
@@ -4082,13 +4081,13 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	int32_t nfserr;
 
 	READ_BUF(8);
-	READ32(opnum);
+	opnum = be32_to_cpup(p++);
 	if (opnum != OP_SETCLIENTID) {
 		dprintk("nfs: decode_setclientid: Server returned operation"
 			" %d\n", opnum);
 		return -EIO;
 	}
-	READ32(nfserr);
+	nfserr = be32_to_cpup(p++);
 	if (nfserr == NFS_OK) {
 		READ_BUF(8 + NFS4_VERIFIER_SIZE);
 		READ64(clp->cl_clientid);
@@ -4098,12 +4097,12 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 
 		/* skip netid string */
 		READ_BUF(4);
-		READ32(len);
+		len = be32_to_cpup(p++);
 		READ_BUF(len);
 
 		/* skip uaddr string */
 		READ_BUF(4);
-		READ32(len);
+		len = be32_to_cpup(p++);
 		READ_BUF(len);
 		return -NFSERR_CLID_INUSE;
 	} else
@@ -4127,8 +4126,8 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 		return status;
 
 	READ_BUF(16);
-	READ32(res->count);
-	READ32(res->verf->committed);
+	res->count = be32_to_cpup(p++);
+	res->verf->committed = be32_to_cpup(p++);
 	COPYMEM(res->verf->verifier, 8);
 	return 0;
 }
@@ -4154,11 +4153,11 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	READ_BUF(8);
 	READ64(clp->cl_ex_clid);
 	READ_BUF(12);
-	READ32(clp->cl_seqid);
-	READ32(clp->cl_exchange_flags);
+	clp->cl_seqid = be32_to_cpup(p++);
+	clp->cl_exchange_flags = be32_to_cpup(p++);
 
 	/* We ask for SP4_NONE */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	if (dummy != SP4_NONE)
 		return -EIO;
 
@@ -4167,17 +4166,17 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 
 	/* Throw away Major id */
 	READ_BUF(4);
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	READ_BUF(dummy);
 
 	/* Throw away server_scope */
 	READ_BUF(4);
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	READ_BUF(dummy);
 
 	/* Throw away Implementation id array */
 	READ_BUF(4);
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	READ_BUF(dummy);
 
 	return 0;
@@ -4190,13 +4189,13 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	u32 nr_attrs;
 
 	READ_BUF(28);
-	READ32(attrs->headerpadsz);
-	READ32(attrs->max_rqst_sz);
-	READ32(attrs->max_resp_sz);
-	READ32(attrs->max_resp_sz_cached);
-	READ32(attrs->max_ops);
-	READ32(attrs->max_reqs);
-	READ32(nr_attrs);
+	attrs->headerpadsz = be32_to_cpup(p++);
+	attrs->max_rqst_sz = be32_to_cpup(p++);
+	attrs->max_resp_sz = be32_to_cpup(p++);
+	attrs->max_resp_sz_cached = be32_to_cpup(p++);
+	attrs->max_ops = be32_to_cpup(p++);
+	attrs->max_reqs = be32_to_cpup(p++);
+	nr_attrs = be32_to_cpup(p++);
 	if (unlikely(nr_attrs > 1)) {
 		printk(KERN_WARNING "%s: Invalid rdma channel attrs count %u\n",
 			__func__, nr_attrs);
@@ -4226,8 +4225,8 @@ static int decode_create_session(struct xdr_stream *xdr,
 
 	/* seqid, flags */
 	READ_BUF(8);
-	READ32(clp->cl_seqid);
-	READ32(session->flags);
+	clp->cl_seqid = be32_to_cpup(p++);
+	session->flags = be32_to_cpup(p++);
 
 	/* Channel attributes */
 	status = decode_chan_attrs(xdr, &session->fc_attrs);
@@ -4275,23 +4274,23 @@ static int decode_sequence(struct xdr_stream *xdr,
 		goto out_err;
 	}
 	/* seqid */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	if (dummy != slot->seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out_err;
 	}
 	/* slot id */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	if (dummy != res->sr_slotid) {
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
 	/* highest slot id - currently not processed */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	/* target highest slot id - currently not processed */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	/* result flags - currently not processed */
-	READ32(dummy);
+	dummy = be32_to_cpup(p++);
 	status = 0;
 out_err:
 	res->sr_status = status;
-- 
1.6.4


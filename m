From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 24/24] NFS: Replace old NFSv2 decoder functions with
	xdr_stream-based ones
Date: Sun, 16 May 2010 22:49:09 -0400
Message-ID: <20100517024909.20258.18824.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973Ab0EQCtL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:49:11 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:49:10 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |  297 ------------------------------------------------------
 1 files changed, 1 insertions(+), 296 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 3d373d1..0ed18b1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -404,55 +404,6 @@ static int decode_diropok(struct xdr_stream *xdr, struct nfs_fh *fh,
 
 
 /*
- * Common NFS XDR functions as inlines
- */
-static inline __be32 *
-xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
-{
-	/* NFSv2 handles have a fixed length */
-	fhandle->size = NFS2_FHSIZE;
-	memcpy(fhandle->data, p, NFS2_FHSIZE);
-	return p + XDR_QUADLEN(NFS2_FHSIZE);
-}
-
-static inline __be32*
-xdr_decode_time(__be32 *p, struct timespec *timep)
-{
-	timep->tv_sec = ntohl(*p++);
-	/* Convert microseconds into nanoseconds */
-	timep->tv_nsec = ntohl(*p++) * 1000;
-	return p;
-}
-
-static __be32 *
-xdr_decode_fattr(__be32 *p, struct nfs_fattr *fattr)
-{
-	u32 rdev, type;
-	type = ntohl(*p++);
-	fattr->mode = ntohl(*p++);
-	fattr->nlink = ntohl(*p++);
-	fattr->uid = ntohl(*p++);
-	fattr->gid = ntohl(*p++);
-	fattr->size = ntohl(*p++);
-	fattr->du.nfs2.blocksize = ntohl(*p++);
-	rdev = ntohl(*p++);
-	fattr->du.nfs2.blocks = ntohl(*p++);
-	fattr->fsid.major = ntohl(*p++);
-	fattr->fsid.minor = 0;
-	fattr->fileid = ntohl(*p++);
-	p = xdr_decode_time(p, &fattr->atime);
-	p = xdr_decode_time(p, &fattr->mtime);
-	p = xdr_decode_time(p, &fattr->ctime);
-	fattr->valid |= NFS_ATTR_FATTR_V2;
-	fattr->rdev = new_decode_dev(rdev);
-	if (type == NFCHR && rdev == NFS2_FIFO_DEV) {
-		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
-		fattr->rdev = 0;
-	}
-	return p;
-}
-
-/*
  * NFS encode functions
  */
 
@@ -558,48 +509,6 @@ static int nfs2_xdr_enc_readargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode READ reply
- */
-static int
-nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
-{
-	struct kvec *iov = req->rq_rcv_buf.head;
-	size_t hdrlen;
-	u32 count, recvd;
-	int status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	p = xdr_decode_fattr(p, res->fattr);
-
-	count = ntohl(*p++);
-	res->eof = 0;
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READ reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READ header is short. iovec will be shifted.\n");
-		xdr_shift_buf(&req->rq_rcv_buf, iov->iov_len - hdrlen);
-	}
-
-	recvd = req->rq_rcv_buf.len - hdrlen;
-	if (count > recvd) {
-		dprintk("NFS: server cheating in read reply: "
-			"count %u > recvd %u\n", count, recvd);
-		count = recvd;
-	}
-
-	dprintk("RPC:      readres OK count %u\n", count);
-	if (count < res->count)
-		res->count = count;
-
-	return count;
-}
-
-
-/*
  * 2.2.9.  writeargs
  *
  *	struct writeargs {
@@ -743,112 +652,8 @@ static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode the result of a readdir call.
- * We're not really decoding anymore, we just leave the buffer untouched
- * and only check that it is syntactically correct.
- * The real decoding happens in nfs_decode_entry below, called directly
- * from nfs_readdir for each entry.
- */
-static int
-nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	struct page **page;
-	size_t hdrlen;
-	unsigned int pglen, recvd;
-	u32 len;
-	int status, nr = 0;
-	__be32 *end, *entry, *kaddr;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READDIR reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
-		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
-	}
-
-	pglen = rcvbuf->page_len;
-	recvd = rcvbuf->len - hdrlen;
-	if (pglen > recvd)
-		pglen = recvd;
-	page = rcvbuf->pages;
-	kaddr = p = kmap_atomic(*page, KM_USER0);
-	end = (__be32 *)((char *)p + pglen);
-	entry = p;
-
-	/* Make sure the packet actually has a value_follows and EOF entry */
-	if ((entry + 1) > end)
-		goto short_pkt;
-
-	for (; *p++; nr++) {
-		if (p + 2 > end)
-			goto short_pkt;
-		p++; /* fileid */
-		len = ntohl(*p++);
-		p += XDR_QUADLEN(len) + 1;	/* name plus cookie */
-		if (len > NFS2_MAXNAMLEN) {
-			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
-						len);
-			goto err_unmap;
-		}
-		if (p + 2 > end)
-			goto short_pkt;
-		entry = p;
-	}
-
-	/*
-	 * Apparently some server sends responses that are a valid size, but
-	 * contain no entries, and have value_follows==0 and EOF==0. For
-	 * those, just set the EOF marker.
-	 */
-	if (!nr && entry[1] == 0) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
- out:
-	kunmap_atomic(kaddr, KM_USER0);
-	return nr;
- short_pkt:
-	/*
-	 * When we get a short packet there are 2 possibilities. We can
-	 * return an error, or fix up the response to look like a valid
-	 * response and return what we have so far. If there are no
-	 * entries and the packet was short, then return -EIO. If there
-	 * are valid entries in the response, return them and pretend that
-	 * the call was successful, but incomplete. The caller can retry the
-	 * readdir starting at the last cookie.
-	 */
-	entry[0] = entry[1] = 0;
-	if (!nr)
-		nr = -errno_NFSERR_IO;
-	goto out;
-err_unmap:
-	nr = -errno_NFSERR_IO;
-	goto out;
-}
-
-/*
  * NFS XDR decode functions
  */
-/*
- * Decode simple status reply
- */
-static int
-nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)) != 0)
-		status = nfs_stat_to_errno(status);
-	return status;
-}
 
 static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
 			     void *__unused)
@@ -865,21 +670,6 @@ static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode attrstat reply
- * GETATTR, SETATTR, WRITE
- */
-static int
-nfs_xdr_attrstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	xdr_decode_fattr(p, fattr);
-	return 0;
-}
-
-/*
  * 2.3.9.  attrstat
  *
  *	union attrstat switch (stat status) {
@@ -904,22 +694,6 @@ static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode diropres reply
- * LOOKUP, CREATE, MKDIR
- */
-static int
-nfs_xdr_diropres(struct rpc_rqst *req, __be32 *p, struct nfs_diropok *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	p = xdr_decode_fhandle(p, res->fh);
-	xdr_decode_fattr(p, res->fattr);
-	return 0;
-}
-
-/*
  * 2.3.11.  diropres
  *
  *	union diropres switch (stat status) {
@@ -947,46 +721,6 @@ static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
- * Decode READLINK reply
- */
-static int
-nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
-{
-	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
-	struct kvec *iov = rcvbuf->head;
-	size_t hdrlen;
-	u32 len, recvd;
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-	/* Convert length of symlink */
-	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len) {
-		dprintk("nfs: server returned giant symlink!\n");
-		return -ENAMETOOLONG;
-	}
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
-	if (iov->iov_len < hdrlen) {
-		dprintk("NFS: READLINK reply header overflowed:"
-				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
-		return -errno_NFSERR_IO;
-	} else if (iov->iov_len != hdrlen) {
-		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");
-		xdr_shift_buf(rcvbuf, iov->iov_len - hdrlen);
-	}
-	recvd = req->rq_rcv_buf.len - hdrlen;
-	if (recvd < len) {
-		dprintk("NFS: server cheating in readlink reply: "
-				"count %u > recvd %u\n", len, recvd);
-		return -EIO;
-	}
-
-	xdr_terminate_string(rcvbuf, len);
-	return 0;
-}
-
-/*
  * 2.2.6.  readlinkres
  *
  *	union readlinkres switch (stat status) {
@@ -1059,16 +793,6 @@ static int nfs2_xdr_dec_readres(struct rpc_rqst *req, __be32 *p,
 	return count;
 }
 
-/*
- * Decode WRITE reply
- */
-static int
-nfs_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
-{
-	res->verf->committed = NFS_FILE_SYNC;
-	return nfs_xdr_attrstat(req, p, res->fattr);
-}
-
 static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
 				 struct nfs_writeres *result)
 {
@@ -1241,25 +965,6 @@ __be32 *nfs_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
 }
 
 /*
- * Decode STATFS reply
- */
-static int
-nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
-{
-	int	status;
-
-	if ((status = ntohl(*p++)))
-		return nfs_stat_to_errno(status);
-
-	res->tsize  = ntohl(*p++);
-	res->bsize  = ntohl(*p++);
-	res->blocks = ntohl(*p++);
-	res->bfree  = ntohl(*p++);
-	res->bavail = ntohl(*p++);
-	return 0;
-}
-
-/*
  * 2.2.18.  statfsres
  *
  *	union statfsres (stat status) {
@@ -1367,7 +1072,7 @@ int nfs_stat_to_errno(enum nfs_stat status)
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  (kxdrproc_t) nfs2_xdr_enc_##argtype,		\
-	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
+	.p_decode   =  (kxdrproc_t) nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\


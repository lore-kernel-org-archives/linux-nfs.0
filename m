Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3926 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757165Ab0JVOOl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:41 -0400
Message-ID: <4CC19C4D.7020509@netapp.com>
Date: Fri, 22 Oct 2010 10:14:37 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/10] NFS: remove page size checking code
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Remove the page size checking code for a readdir decode.  This is now done
by decode_dirent with xdr_streams.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs2xdr.c |   54 -------------------------------------
 fs/nfs/nfs3xdr.c |   78 +-----------------------------------------------------
 fs/nfs/nfs4xdr.c |   68 +----------------------------------------------
 3 files changed, 2 insertions(+), 198 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 0210c75..82f0264 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -423,9 +423,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	struct page **page;
 	size_t hdrlen;
 	unsigned int pglen, recvd;
-	u32 len;
 	int status, nr = 0;
-	__be32 *end, *entry, *kaddr;
 
 	if ((status = ntohl(*p++)))
 		return nfs_stat_to_errno(status);
@@ -445,59 +443,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	if (pglen > recvd)
 		pglen = recvd;
 	page = rcvbuf->pages;
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
 	return nr;
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
 }
 
 static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index d562c8d..dc98eb7 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -554,9 +554,8 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	struct kvec *iov = rcvbuf->head;
 	struct page **page;
 	size_t hdrlen;
-	u32 len, recvd, pglen;
+	u32 recvd, pglen;
 	int status, nr = 0;
-	__be32 *entry, *end, *kaddr;
 
 	status = ntohl(*p++);
 	/* Decode post_op_attrs */
@@ -586,83 +585,8 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	if (pglen > recvd)
 		pglen = recvd;
 	page = rcvbuf->pages;
-	kaddr = p = kmap_atomic(*page, KM_USER0);
-	end = (__be32 *)((char *)p + pglen);
-	entry = p;
-
-	/* Make sure the packet actually has a value_follows and EOF entry */
-	if ((entry + 1) > end)
-		goto short_pkt;
-
-	for (; *p++; nr++) {
-		if (p + 3 > end)
-			goto short_pkt;
-		p += 2;				/* inode # */
-		len = ntohl(*p++);		/* string length */
-		p += XDR_QUADLEN(len) + 2;	/* name + cookie */
-		if (len > NFS3_MAXNAMLEN) {
-			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
-						len);
-			goto err_unmap;
-		}
-
-		if (res->plus) {
-			/* post_op_attr */
-			if (p + 2 > end)
-				goto short_pkt;
-			if (*p++) {
-				p += 21;
-				if (p + 1 > end)
-					goto short_pkt;
-			}
-			/* post_op_fh3 */
-			if (*p++) {
-				if (p + 1 > end)
-					goto short_pkt;
-				len = ntohl(*p++);
-				if (len > NFS3_FHSIZE) {
-					dprintk("NFS: giant filehandle in "
-						"readdir (len 0x%x)!\n", len);
-					goto err_unmap;
-				}
-				p += XDR_QUADLEN(len);
-			}
-		}
-
-		if (p + 2 > end)
-			goto short_pkt;
-		entry = p;
-	}
 
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
 	return nr;
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
 }
 
 __be32 *
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a4919e9..8346e97 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4200,12 +4200,9 @@ out_overflow:
 static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs4_readdir_res *readdir)
 {
 	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
-	struct page	*page = *rcvbuf->pages;
 	struct kvec	*iov = rcvbuf->head;
 	size_t		hdrlen;
 	u32		recvd, pglen = rcvbuf->page_len;
-	__be32		*end, *entry, *p, *kaddr;
-	unsigned int	nr = 0;
 	int		status;
 
 	status = decode_op_hdr(xdr, OP_READDIR);
@@ -4225,71 +4222,8 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		pglen = recvd;
 	xdr_read_pages(xdr, pglen);
 
-	BUG_ON(pglen + readdir->pgbase > PAGE_CACHE_SIZE);
-	kaddr = p = kmap_atomic(page, KM_USER0);
-	end = p + ((pglen + readdir->pgbase) >> 2);
-	entry = p;
-
-	/* Make sure the packet actually has a value_follows and EOF entry */
-	if ((entry + 1) > end)
-		goto short_pkt;
-
-	for (; *p++; nr++) {
-		u32 len, attrlen, xlen;
-		if (end - p < 3)
-			goto short_pkt;
-		dprintk("cookie = %Lu, ", *((unsigned long long *)p));
-		p += 2;			/* cookie */
-		len = ntohl(*p++);	/* filename length */
-		if (len > NFS4_MAXNAMLEN) {
-			dprintk("NFS: giant filename in readdir (len 0x%x)\n",
-					len);
-			goto err_unmap;
-		}
-		xlen = XDR_QUADLEN(len);
-		if (end - p < xlen + 1)
-			goto short_pkt;
-		dprintk("filename = %*s\n", len, (char *)p);
-		p += xlen;
-		len = ntohl(*p++);	/* bitmap length */
-		if (end - p < len + 1)
-			goto short_pkt;
-		p += len;
-		attrlen = XDR_QUADLEN(ntohl(*p++));
-		if (end - p < attrlen + 2)
-			goto short_pkt;
-		p += attrlen;		/* attributes */
-		entry = p;
-	}
-	/*
-	 * Apparently some server sends responses that are a valid size, but
-	 * contain no entries, and have value_follows==0 and EOF==0. For
-	 * those, just set the EOF marker.
-	 */
-	if (!nr && entry[1] == 0) {
-		dprintk("NFS: readdir reply truncated!\n");
-		entry[1] = 1;
-	}
-out:
-	kunmap_atomic(kaddr, KM_USER0);
+
 	return 0;
-short_pkt:
-	/*
-	 * When we get a short packet there are 2 possibilities. We can
-	 * return an error, or fix up the response to look like a valid
-	 * response and return what we have so far. If there are no
-	 * entries and the packet was short, then return -EIO. If there
-	 * are valid entries in the response, return them and pretend that
-	 * the call was successful, but incomplete. The caller can retry the
-	 * readdir starting at the last cookie.
-	 */
-	dprintk("%s: short packet at entry %d\n", __func__, nr);
-	entry[0] = entry[1] = 0;
-	if (nr)
-		goto out;
-err_unmap:
-	kunmap_atomic(kaddr, KM_USER0);
-	return -errno_NFSERR_IO;
 }
 
 static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 037/112] NFS: Use unsigned intermediates for manipulating
	header lengths (NFSv2 XDR)
Date: Fri, 25 Jan 2008 11:37:34 -0500
Message-ID: <20080125163733.31887.78660.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14406 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755200AbYAYRAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:21 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Ht010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:20 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: prevent length underflow and mixed sign comparisons when
unmarshalling NFS version 2 read, readdir, and readlink replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs2xdr.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 668ab96..1f7ea67 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -262,7 +262,9 @@ static int
 nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 {
 	struct kvec *iov = req->rq_rcv_buf.head;
-	int	status, count, recvd, hdrlen;
+	size_t hdrlen;
+	u32 count, recvd;
+	int status;
 
 	if ((status = ntohl(*p++)))
 		return -nfs_stat_to_errno(status);
@@ -273,7 +275,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READ reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READ header is short. iovec will be shifted.\n");
@@ -283,11 +285,11 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "
-			"count %d > recvd %d\n", count, recvd);
+			"count %u > recvd %u\n", count, recvd);
 		count = recvd;
 	}
 
-	dprintk("RPC:      readres OK count %d\n", count);
+	dprintk("RPC:      readres OK count %u\n", count);
 	if (count < res->count)
 		res->count = count;
 
@@ -423,9 +425,10 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
 	struct page **page;
-	int hdrlen, recvd;
+	size_t hdrlen;
+	unsigned int pglen, recvd;
+	u32 len;
 	int status, nr;
-	unsigned int len, pglen;
 	__be32 *end, *entry, *kaddr;
 
 	if ((status = ntohl(*p++)))
@@ -434,7 +437,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READDIR reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
@@ -576,7 +579,8 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
-	int hdrlen, len, recvd;
+	size_t hdrlen;
+	u32 len, recvd;
 	char	*kaddr;
 	int	status;
 
@@ -584,14 +588,14 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 		return -nfs_stat_to_errno(status);
 	/* Convert length of symlink */
 	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len || len <= 0) {
+	if (len >= rcvbuf->page_len) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READLINK reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");

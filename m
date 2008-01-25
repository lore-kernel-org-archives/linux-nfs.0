From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 039/112] NFS: Use unsigned intermediates for manipulating
	header lengths (NFSv4 XDR)
Date: Fri, 25 Jan 2008 11:37:35 -0500
Message-ID: <20080125163734.31887.68065.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55343 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757086AbYAYRCG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:06 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Zb7020525
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:51 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: prevent length underflow and mixed sign comparison when
unmarshalling NFS version 4 getacl, readdir, and readlink replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 51dd380..2e1fe17 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3476,10 +3476,11 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
 	struct page	*page = *rcvbuf->pages;
 	struct kvec	*iov = rcvbuf->head;
-	unsigned int	nr, pglen = rcvbuf->page_len;
+	size_t		hdrlen;
+	u32		recvd, pglen = rcvbuf->page_len;
 	__be32		*end, *entry, *p, *kaddr;
-	uint32_t	len, attrlen, xlen;
-	int 		hdrlen, recvd, status;
+	unsigned int	nr;
+	int		status;
 
 	status = decode_op_hdr(xdr, OP_READDIR);
 	if (status)
@@ -3503,6 +3504,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	end = p + ((pglen + readdir->pgbase) >> 2);
 	entry = p;
 	for (nr = 0; *p++; nr++) {
+		u32 len, attrlen, xlen;
 		if (end - p < 3)
 			goto short_pkt;
 		dprintk("cookie = %Lu, ", *((unsigned long long *)p));
@@ -3551,7 +3553,8 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
-	int hdrlen, len, recvd;
+	size_t hdrlen;
+	u32 len, recvd;
 	__be32 *p;
 	char *kaddr;
 	int status;
@@ -3646,7 +3649,8 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
-		int hdrlen, recvd;
+		size_t hdrlen;
+		u32 recvd;
 
 		/* We ignore &savep and don't do consistency checks on
 		 * the attr length.  Let userspace figure it out.... */

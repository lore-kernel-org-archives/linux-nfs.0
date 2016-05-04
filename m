Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36062 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcEDOxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 10:53:00 -0400
Subject: [PATCH v2 2/9] svcrdma: Do not add XDR padding to xdr_buf page
 vector
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 04 May 2016 10:52:55 -0400
Message-ID: <20160504145255.6602.10528.stgit@klimt.1015granger.net>
In-Reply-To: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
References: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An xdr_buf has a head, a vector of pages, and a tail. Each
RPC request is presented to the NFS server contained in an
xdr_buf.

The RDMA transport would like to supply the NFS server with only
the NFS WRITE payload bytes in the page vector. In some common
cases, that would allow the NFS server to swap those pages right
into the target file's page cache.

Have the transport's RDMA Read logic put XDR pad bytes in the tail
iovec, and not in the pages that hold the data payload.

The NFSv3 WRITE XDR decoder is finicky about the lengths involved,
so make sure it is looking in the correct places when computing
the total length of the incoming NFS WRITE request.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3xdr.c                       |    2 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2246454..c5eff5f 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -379,7 +379,7 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 */
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
 	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
-		- hdr;
+		+ rqstp->rq_arg.tail[0].iov_len - hdr;
 	/*
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 3b24a64..234be9d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -488,7 +488,7 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	if (page_offset & 3) {
 		u32 pad = 4 - (page_offset & 3);
 
-		head->arg.page_len += pad;
+		head->arg.tail[0].iov_len += pad;
 		head->arg.len += pad;
 		head->arg.buflen += pad;
 		page_offset += pad;


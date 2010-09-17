Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36298 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab0IQQaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 12:30:01 -0400
Received: by gyd8 with SMTP id 8so778993gyd.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 09:30:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/22] NFS: Fix hdrlen calculation in NFSv4's decode_read()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 17 Sep 2010 12:29:58 -0400
Message-ID: <20100917162958.19761.85898.stgit@seurat.1015granger.net>
In-Reply-To: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
References: <20100917162204.19761.58249.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When computing the length of the header, be sure to include the
four octets consumed by "count".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e1ed89e..011f144 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4180,7 +4180,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 		goto out_overflow;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p);
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
+	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/22] NFS: Fix hdrlen calculation in NFSv4's decode_read()
Date: Fri, 02 Jul 2010 13:21:50 -0400
Message-ID: <20100702172150.8761.4945.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759365Ab0GBRVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:21:52 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:21:52 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When computing the length of the header, be sure to include the
four octets consumed by "count".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e38e43b..375af90 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4131,7 +4131,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 		goto out_overflow;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p);
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
+	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "


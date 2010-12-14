Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55072 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758612Ab0LNO6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:58:04 -0500
Received: by mail-gy0-f174.google.com with SMTP id 11so374133gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:58:04 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/31] NFS: Fix hdrlen calculation in NFSv4's decode_read()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:58:01 -0500
Message-ID: <20101214145801.2293.98571.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When computing the length of the header, be sure to include the
four octets consumed by "count".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a48a43c..868815c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4475,7 +4475,7 @@ static int decode_read(struct xdr_stream *xdr, struct rpc_rqst *req, struct nfs_
 		goto out_overflow;
 	eof = be32_to_cpup(p++);
 	count = be32_to_cpup(p);
-	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
+	hdrlen = (u8 *) xdr->p - (u8 *) iov->iov_base;
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "


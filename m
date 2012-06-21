Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55816 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab2FUVvd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFSv2/v3: Remove incorrect dprintks from the readdir reply code
Date: Thu, 21 Jun 2012 17:51:20 -0400
Message-Id: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The actual size of the directory is unknown to the client, so it is
always requesting the maximum number it can handle. If the server
is replying with fewer entries than was requested, then that will
usually reflect the fact that we've hit the end of the directory.
Flagging it as an error is therefore incorrect.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs2xdr.c |   10 ++--------
 fs/nfs/nfs3xdr.c |   10 ++--------
 2 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index baf759b..db81166 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -978,16 +978,10 @@ static int decode_readdirok(struct xdr_stream *xdr)
 	pglen = xdr->buf->page_len;
 	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
 	recvd = xdr->buf->len - hdrlen;
-	if (unlikely(pglen > recvd))
-		goto out_cheating;
-out:
+	if (pglen > recvd)
+		pglen = recvd;
 	xdr_read_pages(xdr, pglen);
 	return pglen;
-out_cheating:
-	dprintk("NFS: server cheating in readdir result: "
-		"pglen %u > recvd %u\n", pglen, recvd);
-	pglen = recvd;
-	goto out;
 }
 
 static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 902de48..3c61c7f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2045,16 +2045,10 @@ static int decode_dirlist3(struct xdr_stream *xdr)
 	pglen = xdr->buf->page_len;
 	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
 	recvd = xdr->buf->len - hdrlen;
-	if (unlikely(pglen > recvd))
-		goto out_cheating;
-out:
+	if (pglen > recvd)
+		pglen = recvd;
 	xdr_read_pages(xdr, pglen);
 	return pglen;
-out_cheating:
-	dprintk("NFS: server cheating in readdir result: "
-		"pglen %u > recvd %u\n", pglen, recvd);
-	pglen = recvd;
-	goto out;
 }
 
 static int decode_readdir3resok(struct xdr_stream *xdr,
-- 
1.7.10.2


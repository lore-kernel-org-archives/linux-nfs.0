Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:53166 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbaHGDKq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 23:10:46 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so4561289pad.37
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 20:10:45 -0700 (PDT)
Message-ID: <53E2EE27.5010603@gmail.com>
Date: Thu, 07 Aug 2014 11:10:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 1/2] NFSD: Treat rq_reserved when initializing xdr_buf
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After calling svc_reserve() with a small length,
nfsd does't treat it in svcxdr_init_encode().

So, when testing conflock, got message as,

[  970.127216] RPC request reserved 88 but used 116

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5e0dc52..084e46e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1245,17 +1245,20 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = &rqstp->rq_res;
 	struct kvec *head = buf->head;
+	int tlen = 0;
 
 	xdr->buf = buf;
 	xdr->iov = head;
 	xdr->p   = head->iov_base + head->iov_len;
-	xdr->end = head->iov_base + PAGE_SIZE - rqstp->rq_auth_slack;
+	tlen = PAGE_SIZE - rqstp->rq_auth_slack;
+	xdr->end = head->iov_base + min(tlen, rqstp->rq_reserved);
 	/* Tail and page_len should be zero at this point: */
 	buf->len = buf->head[0].iov_len;
 	xdr->scratch.iov_len = 0;
 	xdr->page_ptr = buf->pages - 1;
-	buf->buflen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
+	tlen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
 		- rqstp->rq_auth_slack;
+	buf->buflen = min(tlen, rqstp->rq_reserved);
 }
 
 /*
-- 
1.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35804 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752045AbcITSdt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 14:33:49 -0400
Received: by mail-qk0-f194.google.com with SMTP id w204so1596264qka.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 11:33:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Fix setting of buffer length in xdr_set_next_buffer()
Date: Tue, 20 Sep 2016 14:33:43 -0400
Message-Id: <1474396423-19543-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474396423-19543-1-git-send-email-trond.myklebust@primarydata.com>
References: <1474396423-19543-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use xdr->nwords to tell us how much buffer remains.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index b8444860edf5..7f1071e103ca 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -767,7 +767,7 @@ static void xdr_set_next_page(struct xdr_stream *xdr)
 	newbase -= xdr->buf->page_base;
 
 	if (xdr_set_page_base(xdr, newbase, PAGE_SIZE) < 0)
-		xdr_set_iov(xdr, xdr->buf->tail, xdr->buf->len);
+		xdr_set_iov(xdr, xdr->buf->tail, xdr->nwords << 2);
 }
 
 static bool xdr_set_next_buffer(struct xdr_stream *xdr)
@@ -776,7 +776,7 @@ static bool xdr_set_next_buffer(struct xdr_stream *xdr)
 		xdr_set_next_page(xdr);
 	else if (xdr->iov == xdr->buf->head) {
 		if (xdr_set_page_base(xdr, 0, PAGE_SIZE) < 0)
-			xdr_set_iov(xdr, xdr->buf->tail, xdr->buf->len);
+			xdr_set_iov(xdr, xdr->buf->tail, xdr->nwords << 2);
 	}
 	return xdr->p != xdr->end;
 }
-- 
2.7.4


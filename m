Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47407 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbcDFPcz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2016 11:32:55 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: init xdr_stream for zero iov_len, page_len
Date: Wed,  6 Apr 2016 11:32:52 -0400
Message-Id: <7420eefd5fefb52fb902a8ae1c861671f14fcc51.1459956651.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An xdr_buf with head[0].iov_len = 0 and page_len = 0 will cause
xdr_init_decode() to incorrectly setup the xdr_stream.  Specifically,
xdr->end is never initialized.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 net/sunrpc/xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4..4f29e30 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -797,6 +797,8 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 		xdr_set_iov(xdr, buf->head, buf->len);
 	else if (buf->page_len != 0)
 		xdr_set_page_base(xdr, 0, buf->len);
+	else
+		xdr_set_iov(xdr, buf->head, buf->len);
 	if (p != NULL && p > xdr->p && xdr->end >= p) {
 		xdr->nwords -= p - xdr->p;
 		xdr->p = p;
-- 
1.7.1


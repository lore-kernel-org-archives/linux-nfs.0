Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:52782 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDTHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 15:07:54 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v1 1/5] SUNRPC: Split out a function for setting current page
Date: Fri, 4 Sep 2015 15:07:45 -0400
Message-ID: <1441393669-30280-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1441393669-30280-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1441393669-30280-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm going to need this bit of code in a few places for READ_PLUS
decoding, so let's make it a helper function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 net/sunrpc/xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4..b1c4ffb 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -759,6 +759,12 @@ static int xdr_set_page_base(struct xdr_stream *xdr,
 	return 0;
 }
 
+static void xdr_set_page(struct xdr_stream *xdr, unsigned int base)
+{
+	if (xdr_set_page_base(xdr, base, PAGE_SIZE) < 0)
+		xdr_set_iov(xdr, xdr->buf->tail, xdr->buf->len);
+}
+
 static void xdr_set_next_page(struct xdr_stream *xdr)
 {
 	unsigned int newbase;
@@ -766,8 +772,7 @@ static void xdr_set_next_page(struct xdr_stream *xdr)
 	newbase = (1 + xdr->page_ptr - xdr->buf->pages) << PAGE_SHIFT;
 	newbase -= xdr->buf->page_base;
 
-	if (xdr_set_page_base(xdr, newbase, PAGE_SIZE) < 0)
-		xdr_set_iov(xdr, xdr->buf->tail, xdr->buf->len);
+	xdr_set_page(xdr, newbase);
 }
 
 static bool xdr_set_next_buffer(struct xdr_stream *xdr)
-- 
2.5.1


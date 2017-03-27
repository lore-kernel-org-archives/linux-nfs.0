Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35556 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753175AbdC0OH5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:07:57 -0400
Subject: [PATCH v2 12/13] sunrpc: Fix xdr_init_decode_pages() documenting
 comment
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:07:12 -0400
Message-ID: <20170327140712.20813.24246.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 1f70821..e34f4ee 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -807,7 +807,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 EXPORT_SYMBOL_GPL(xdr_init_decode);
 
 /**
- * xdr_init_decode - Initialize an xdr_stream for decoding data.
+ * xdr_init_decode_pages - Initialize an xdr_stream for decoding into pages
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer from which to decode data
  * @pages: list of pages to decode into


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3926 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757176Ab0JVOOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:40 -0400
Message-ID: <4CC19C46.2030203@netapp.com>
Date: Fri, 22 Oct 2010 10:14:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/10] SUNRPC: Add a helper function xdr_inline_peek
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We sometimes need to be able to read ahead in an xdr_stream without
incrementing the current pointer position.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 8c1dcbb..ab91d86 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -201,6 +201,7 @@ extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
+extern __be32 *xdr_inline_peek(struct xdr_stream *xdr, size_t nbytes);
 extern __be32 *xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index e0725d9..cd9e841 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -573,6 +573,27 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 EXPORT_SYMBOL_GPL(xdr_init_decode);
 
 /**
+ * xdr_inline_peek - Allow read-ahead in the XDR data stream
+ * @xdr: pointer to xdr_stream struct
+ * @nbytes: number of bytes of data to decode
+ *
+ * Check if the input buffer is long enough to enable us to decode
+ * 'nbytes' more bytes of data starting at the current position.
+ * If so return the current pointer without updating the current
+ * pointer position.
+ */
+__be32 * xdr_inline_peek(struct xdr_stream *xdr, size_t nbytes)
+{
+	__be32 *p = xdr->p;
+	__be32 *q = p + XDR_QUADLEN(nbytes);
+
+	if (unlikely(q > xdr->end || q < p))
+		return NULL;
+	return p;
+}
+EXPORT_SYMBOL_GPL(xdr_inline_peek);
+
+/**
  * xdr_inline_decode - Retrieve non-page XDR data to decode
  * @xdr: pointer to xdr_stream struct
  * @nbytes: number of bytes of data to decode

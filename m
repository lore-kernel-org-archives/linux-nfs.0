Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55816 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932779Ab2FUVvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jun 2012 17:51:35 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/8] SUNRPC: Add the helper xdr_stream_pos
Date: Thu, 21 Jun 2012 17:51:24 -0400
Message-Id: <1340315487-18309-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1340315487-18309-1-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-2-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-3-git-send-email-Trond.Myklebust@netapp.com>
 <1340315487-18309-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper to report the current offset from the start of the
xdr_stream.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xdr.h |    1 +
 net/sunrpc/xdr.c           |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 2489bce1..647faf2 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -218,6 +218,7 @@ extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 		unsigned int base, unsigned int len);
+extern unsigned int xdr_stream_pos(const struct xdr_stream *xdr);
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
 		struct page **pages, unsigned int len);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 05d0920..9e21927 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -455,6 +455,16 @@ xdr_shift_buf(struct xdr_buf *buf, size_t len)
 EXPORT_SYMBOL_GPL(xdr_shift_buf);
 
 /**
+ * xdr_stream_pos - Return the current offset from the start of the xdr_stream
+ * @xdr: pointer to struct xdr_stream
+ */
+unsigned int xdr_stream_pos(const struct xdr_stream *xdr)
+{
+	return (unsigned int)(XDR_QUADLEN(xdr->buf->len) - xdr->nwords) << 2;
+}
+EXPORT_SYMBOL_GPL(xdr_stream_pos);
+
+/**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer in which to encode data
-- 
1.7.10.2


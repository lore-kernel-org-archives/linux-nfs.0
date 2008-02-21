From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 17/19] xdr: add a new utility function to shift the head data
	of an xdr buffer
Date: Thu, 21 Feb 2008 13:45:13 -0500
Message-ID: <20080221184513.19195.87833.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:28558 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbYBUSpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:45:13 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 16CDB4610
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:45:13 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new xdr helper function that shifts the data in an xdr
buffer's head to make room for new data.

Also add an export for the helper function  write_bytes_to_xdr_buf().

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/xdr.h |    2 ++
 net/sunrpc/xdr.c           |   29 +++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index e4057d7..518d47c 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -164,6 +164,8 @@ extern int xdr_buf_subsegment(struct xdr_buf *, struct xdr_buf *, unsigned int,
 extern int xdr_buf_read_netobj(struct xdr_buf *, struct xdr_netobj *, unsigned int);
 extern int read_bytes_from_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
 extern int write_bytes_to_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
+extern int xdr_shift_head_data(struct xdr_buf *, int, unsigned int);
+
 
 /*
  * Helper structure for copying from an sk_buff.
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 995c3fd..de2c986 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -428,6 +428,34 @@ xdr_shift_buf(struct xdr_buf *buf, size_t len)
 EXPORT_SYMBOL(xdr_shift_buf);
 
 /**
+ * xdr_xdr_shift_head_data - Make room for new data within buf->head
+ * @buf: pointer to XDR buffer
+ * @offset: offset within the head to start moving data
+ * @shiftlen: number of bytes to shift the data
+ */
+int
+xdr_shift_head_data(struct xdr_buf *buf, int offset, unsigned int shiftlen)
+{
+	u8 *p;
+
+	if (shiftlen == 0)
+		return 0;
+	/* make sure there is room (assuming head has a page) */
+	if (buf->head[0].iov_len + shiftlen + offset > PAGE_CACHE_SIZE)
+		return 1;
+
+	p = buf->head[0].iov_base + offset;
+
+	memmove(p + shiftlen, p, buf->head[0].iov_len - offset);
+
+	buf->head[0].iov_len += shiftlen;
+	buf->len += shiftlen;
+
+	return 0;
+}
+EXPORT_SYMBOL(xdr_shift_head_data);
+
+/**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
  * @xdr: pointer to xdr_stream struct
  * @buf: pointer to XDR buffer in which to encode data
@@ -758,6 +786,7 @@ int write_bytes_to_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, un
 	__write_bytes_to_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL(write_bytes_to_xdr_buf);
 
 int
 xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)


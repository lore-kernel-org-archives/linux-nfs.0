Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47840 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbaCWBMY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/50] rpc: Allow xdr_buf_subsegment to operate in-place
Date: Sat, 22 Mar 2014 21:11:32 -0400
Message-Id: <1395537141-10389-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Allow

	xdr_buf_subsegment(&buf, &buf, base, len)

to modify an xdr_buf in-place.

Also, none of the callers need the iov_base of head or tail to be zeroed
out.

Also add documentation.

(As it turns out, I"m not really using this, but it seems a simple way
to make this function a bit more robust.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xdr.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 1504bb1..dd97ba3 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -833,8 +833,20 @@ xdr_buf_from_iov(struct kvec *iov, struct xdr_buf *buf)
 }
 EXPORT_SYMBOL_GPL(xdr_buf_from_iov);
 
-/* Sets subbuf to the portion of buf of length len beginning base bytes
- * from the start of buf. Returns -1 if base of length are out of bounds. */
+/**
+ * xdr_buf_subsegment - set subbuf to a portion of buf
+ * @buf: an xdr buffer
+ * @subbuf: the result buffer
+ * @base: beginning of range in bytes
+ * @len: length of range in bytes
+ *
+ * sets @subbuf to an xdr buffer representing the portion of @buf of
+ * length @len starting at offset @base.
+ *
+ * @buf and @subbuf may be pointers to the same struct xdr_buf.
+ *
+ * Returns -1 if base of length are out of bounds.
+ */
 int
 xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 			unsigned int base, unsigned int len)
@@ -847,9 +859,8 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 		len -= subbuf->head[0].iov_len;
 		base = 0;
 	} else {
-		subbuf->head[0].iov_base = NULL;
-		subbuf->head[0].iov_len = 0;
 		base -= buf->head[0].iov_len;
+		subbuf->head[0].iov_len = 0;
 	}
 
 	if (base < buf->page_len) {
@@ -871,9 +882,8 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 		len -= subbuf->tail[0].iov_len;
 		base = 0;
 	} else {
-		subbuf->tail[0].iov_base = NULL;
-		subbuf->tail[0].iov_len = 0;
 		base -= buf->tail[0].iov_len;
+		subbuf->tail[0].iov_len = 0;
 	}
 
 	if (base || len)
-- 
1.8.5.3


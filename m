Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34553 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdBSVIq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 16:08:46 -0500
Received: by mail-it0-f67.google.com with SMTP id r141so8890498ita.1
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 13:08:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 7/8] SUNRPC: Add a helper function xdr_stream_decode_string_dup()
Date: Sun, 19 Feb 2017 16:08:31 -0500
Message-Id: <20170219210832.61213-8-trond.myklebust@primarydata.com>
In-Reply-To: <20170219210832.61213-7-trond.myklebust@primarydata.com>
References: <20170219210832.61213-1-trond.myklebust@primarydata.com>
 <20170219210832.61213-2-trond.myklebust@primarydata.com>
 <20170219210832.61213-3-trond.myklebust@primarydata.com>
 <20170219210832.61213-4-trond.myklebust@primarydata.com>
 <20170219210832.61213-5-trond.myklebust@primarydata.com>
 <20170219210832.61213-6-trond.myklebust@primarydata.com>
 <20170219210832.61213-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a helper function that decodes a xdr string object, allocates a memory
buffer and then store it as a NUL terminated string.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xdr.h |  2 ++
 net/sunrpc/xdr.c           | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index dc7e51a769ac..054c8cde18f3 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -242,6 +242,8 @@ extern unsigned int xdr_read_pages(struct xdr_stream *xdr, unsigned int len);
 extern void xdr_enter_page(struct xdr_stream *xdr, unsigned int len);
 extern int xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len, int (*actor)(struct scatterlist *, void *), void *data);
 
+ssize_t xdr_stream_decode_string_dup(struct xdr_stream *xdr, char **str,
+		size_t maxlen, gfp_t gfp_flags);
 /**
  * xdr_align_size - Calculate padded size of an object
  * @n: Size of an object being XDR encoded (in bytes)
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 7f1071e103ca..1f7082144e01 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1518,3 +1518,37 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 }
 EXPORT_SYMBOL_GPL(xdr_process_buf);
 
+/**
+ * xdr_stream_decode_string_dup - Decode and duplicate variable length string
+ * @xdr: pointer to xdr_stream
+ * @str: location to store pointer to string
+ * @maxlen: maximum acceptable string length
+ * @gfp_flags: GFP mask to use
+ *
+ * Return values:
+ *   On success, returns length of NUL-terminated string stored in *@ptr
+ *   %-EBADMSG on XDR buffer overflow
+ *   %-EMSGSIZE if the size of the string would exceed @maxlen
+ *   %-ENOMEM on memory allocation failure
+ */
+ssize_t xdr_stream_decode_string_dup(struct xdr_stream *xdr, char **str,
+		size_t maxlen, gfp_t gfp_flags)
+{
+	void *p;
+	ssize_t ret;
+
+	ret = xdr_stream_decode_opaque_inline(xdr, &p, maxlen);
+	if (ret > 0) {
+		char *s = kmalloc(ret + 1, gfp_flags);
+		if (s != NULL) {
+			memcpy(s, p, ret);
+			s[ret] = '\0';
+			*str = s;
+			return strlen(s);
+		}
+		ret = -ENOMEM;
+	}
+	*str = NULL;
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xdr_stream_decode_string_dup);
-- 
2.9.3


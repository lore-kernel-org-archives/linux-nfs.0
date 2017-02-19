Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36804 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbdBSS7W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 13:59:22 -0500
Received: by mail-it0-f68.google.com with SMTP id w185so2677049ita.3
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 10:59:16 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 7/8] SUNRPC: Add a helper function xdr_stream_decode_string_dup()
Date: Sun, 19 Feb 2017 13:59:02 -0500
Message-Id: <20170219185903.42043-8-trond.myklebust@primarydata.com>
In-Reply-To: <20170219185903.42043-7-trond.myklebust@primarydata.com>
References: <20170219185903.42043-1-trond.myklebust@primarydata.com>
 <20170219185903.42043-2-trond.myklebust@primarydata.com>
 <20170219185903.42043-3-trond.myklebust@primarydata.com>
 <20170219185903.42043-4-trond.myklebust@primarydata.com>
 <20170219185903.42043-5-trond.myklebust@primarydata.com>
 <20170219185903.42043-6-trond.myklebust@primarydata.com>
 <20170219185903.42043-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Create a helper function that decodes a xdr string object, allocates a memory
buffer and then store it as a NUL terminated string.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xdr.h |  2 ++
 net/sunrpc/xdr.c           | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index af41484212e5..51d937466645 100644
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
index 7f1071e103ca..6a7caab1c4a5 100644
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
+ *   %-ENOBUFS on XDR buffer overflow
+ *   %-ENOMEM on memory allocation failure
+ *   %-E2BIG if the size of the string would exceed @maxlen
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


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46129 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbeCTVDm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:42 -0400
Received: by mail-io0-f196.google.com with SMTP id g14so4065320iob.13
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] SUNRPC: Add helpers for decoding opaque and string types
Date: Tue, 20 Mar 2018 17:03:05 -0400
Message-Id: <20180320210313.94429-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-1-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xdr.h |  6 ++++
 net/sunrpc/xdr.c           | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index d950223c64b1..7e609de34d85 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -253,6 +253,12 @@ xdr_stream_remaining(const struct xdr_stream *xdr)
 	return xdr->nwords << 2;
 }
 
+ssize_t xdr_stream_decode_opaque(struct xdr_stream *xdr, void *ptr,
+		size_t size);
+ssize_t xdr_stream_decode_opaque_dup(struct xdr_stream *xdr, void **ptr,
+		size_t maxlen, gfp_t gfp_flags);
+ssize_t xdr_stream_decode_string(struct xdr_stream *xdr, char *str,
+		size_t size);
 ssize_t xdr_stream_decode_string_dup(struct xdr_stream *xdr, char **str,
 		size_t maxlen, gfp_t gfp_flags);
 /**
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index e34f4ee7f2b6..30afbd236656 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1518,6 +1518,88 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 }
 EXPORT_SYMBOL_GPL(xdr_process_buf);
 
+/**
+ * xdr_stream_decode_opaque - Decode variable length opaque
+ * @xdr: pointer to xdr_stream
+ * @ptr: location to store opaque data
+ * @size: size of storage buffer @ptr
+ *
+ * Return values:
+ *   On success, returns size of object stored in *@ptr
+ *   %-EBADMSG on XDR buffer overflow
+ *   %-EMSGSIZE on overflow of storage buffer @ptr
+ */
+ssize_t xdr_stream_decode_opaque(struct xdr_stream *xdr, void *ptr, size_t size)
+{
+	ssize_t ret;
+	void *p;
+
+	ret = xdr_stream_decode_opaque_inline(xdr, &p, size);
+	if (ret <= 0)
+		return ret;
+	memcpy(ptr, p, ret);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xdr_stream_decode_opaque);
+
+/**
+ * xdr_stream_decode_opaque_dup - Decode and duplicate variable length opaque
+ * @xdr: pointer to xdr_stream
+ * @ptr: location to store pointer to opaque data
+ * @maxlen: maximum acceptable object size
+ * @gfp_flags: GFP mask to use
+ *
+ * Return values:
+ *   On success, returns size of object stored in *@ptr
+ *   %-EBADMSG on XDR buffer overflow
+ *   %-EMSGSIZE if the size of the object would exceed @maxlen
+ *   %-ENOMEM on memory allocation failure
+ */
+ssize_t xdr_stream_decode_opaque_dup(struct xdr_stream *xdr, void **ptr,
+		size_t maxlen, gfp_t gfp_flags)
+{
+	ssize_t ret;
+	void *p;
+
+	ret = xdr_stream_decode_opaque_inline(xdr, &p, maxlen);
+	if (ret > 0) {
+		*ptr = kmemdup(p, ret, gfp_flags);
+		if (*ptr != NULL)
+			return ret;
+		ret = -ENOMEM;
+	}
+	*ptr = NULL;
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xdr_stream_decode_opaque_dup);
+
+/**
+ * xdr_stream_decode_string - Decode variable length string
+ * @xdr: pointer to xdr_stream
+ * @str: location to store string
+ * @size: size of storage buffer @str
+ *
+ * Return values:
+ *   On success, returns length of NUL-terminated string stored in *@str
+ *   %-EBADMSG on XDR buffer overflow
+ *   %-EMSGSIZE on overflow of storage buffer @str
+ */
+ssize_t xdr_stream_decode_string(struct xdr_stream *xdr, char *str, size_t size)
+{
+	ssize_t ret;
+	void *p;
+
+	ret = xdr_stream_decode_opaque_inline(xdr, &p, size);
+	if (ret > 0) {
+		memcpy(str, p, ret);
+		str[ret] = '\0';
+		return strlen(str);
+	}
+	*str = '\0';
+	return ret;
+}
+EXPORT_SYMBOL_GPL(xdr_stream_decode_string);
+
 /**
  * xdr_stream_decode_string_dup - Decode and duplicate variable length string
  * @xdr: pointer to xdr_stream
-- 
2.14.3


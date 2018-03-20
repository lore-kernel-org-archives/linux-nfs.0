Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:50696 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbeCTVDn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 17:03:43 -0400
Received: by mail-it0-f68.google.com with SMTP id d13-v6so4270002itf.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 14:03:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] SUNRPC: Add a helper for encoding opaque data inline
Date: Tue, 20 Mar 2018 17:03:06 -0400
Message-Id: <20180320210313.94429-3-trond.myklebust@primarydata.com>
In-Reply-To: <20180320210313.94429-2-trond.myklebust@primarydata.com>
References: <20180320210313.94429-1-trond.myklebust@primarydata.com>
 <20180320210313.94429-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xdr.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 7e609de34d85..a43c3b6455b6 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -318,6 +318,31 @@ xdr_stream_encode_u64(struct xdr_stream *xdr, __u64 n)
 	return len;
 }
 
+/**
+ * xdr_stream_encode_opaque_inline - Encode opaque xdr data
+ * @xdr: pointer to xdr_stream
+ * @ptr: pointer to void pointer
+ * @len: size of object
+ *
+ * Return values:
+ *   On success, returns length in bytes of XDR buffer consumed
+ *   %-EMSGSIZE on XDR buffer overflow
+ */
+static inline ssize_t
+xdr_stream_encode_opaque_inline(struct xdr_stream *xdr, void **ptr, size_t len)
+{
+	size_t count = sizeof(__u32) + xdr_align_size(len);
+	__be32 *p = xdr_reserve_space(xdr, count);
+
+	if (unlikely(!p)) {
+		*ptr = NULL;
+		return -EMSGSIZE;
+	}
+	xdr_encode_opaque(p, NULL, len);
+	*ptr = ++p;
+	return count;
+}
+
 /**
  * xdr_stream_encode_opaque_fixed - Encode fixed length opaque xdr data
  * @xdr: pointer to xdr_stream
-- 
2.14.3


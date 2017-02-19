Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36566 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbdBSS7W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 13:59:22 -0500
Received: by mail-io0-f193.google.com with SMTP id q20so3076038ioi.3
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 10:59:22 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 4/8] NFSv4: Replace callback string decode function with a generic
Date: Sun, 19 Feb 2017 13:58:59 -0500
Message-Id: <20170219185903.42043-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170219185903.42043-4-trond.myklebust@primarydata.com>
References: <20170219185903.42043-1-trond.myklebust@primarydata.com>
 <20170219185903.42043-2-trond.myklebust@primarydata.com>
 <20170219185903.42043-3-trond.myklebust@primarydata.com>
 <20170219185903.42043-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c | 30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e732a65db546..2ade5cb52b8e 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -83,23 +83,15 @@ static __be32 *read_buf(struct xdr_stream *xdr, size_t nbytes)
 	return p;
 }
 
-static __be32 decode_string(struct xdr_stream *xdr, unsigned int *len, const char **str)
+static __be32 decode_string(struct xdr_stream *xdr, unsigned int *len,
+		const char **str, size_t maxlen)
 {
-	__be32 *p;
-
-	p = read_buf(xdr, 4);
-	if (unlikely(p == NULL))
-		return htonl(NFS4ERR_RESOURCE);
-	*len = ntohl(*p);
-
-	if (*len != 0) {
-		p = read_buf(xdr, *len);
-		if (unlikely(p == NULL))
-			return htonl(NFS4ERR_RESOURCE);
-		*str = (const char *)p;
-	} else
-		*str = NULL;
+	ssize_t err;
 
+	err = xdr_stream_decode_opaque_inline(xdr, (void **)str, maxlen);
+	if (err < 0)
+		return cpu_to_be32(NFS4ERR_RESOURCE);
+	*len = err;
 	return 0;
 }
 
@@ -162,15 +154,9 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	__be32 *p;
 	__be32 status;
 
-	status = decode_string(xdr, &hdr->taglen, &hdr->tag);
+	status = decode_string(xdr, &hdr->taglen, &hdr->tag, CB_OP_TAGLEN_MAXSZ);
 	if (unlikely(status != 0))
 		return status;
-	/* We do not like overly long tags! */
-	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ) {
-		printk("NFS: NFSv4 CALLBACK %s: client sent tag of length %u\n",
-				__func__, hdr->taglen);
-		return htonl(NFS4ERR_RESOURCE);
-	}
 	p = read_buf(xdr, 12);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-- 
2.9.3


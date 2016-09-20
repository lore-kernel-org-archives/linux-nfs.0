Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33896 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752045AbcITSds (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 14:33:48 -0400
Received: by mail-qk0-f193.google.com with SMTP id b204so1605662qkc.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2016 11:33:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Fix corruption of xdr->nwords in xdr_copy_to_scratch
Date: Tue, 20 Sep 2016 14:33:42 -0400
Message-Id: <1474396423-19543-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we copy the first part of the data, we need to ensure that value
of xdr->nwords is updated as well. Do so by calling __xdr_inline_decode()

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xdr.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index c4f3cc0c0775..b8444860edf5 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -859,12 +859,15 @@ EXPORT_SYMBOL_GPL(xdr_set_scratch_buffer);
 static __be32 *xdr_copy_to_scratch(struct xdr_stream *xdr, size_t nbytes)
 {
 	__be32 *p;
-	void *cpdest = xdr->scratch.iov_base;
+	char *cpdest = xdr->scratch.iov_base;
 	size_t cplen = (char *)xdr->end - (char *)xdr->p;
 
 	if (nbytes > xdr->scratch.iov_len)
 		return NULL;
-	memcpy(cpdest, xdr->p, cplen);
+	p = __xdr_inline_decode(xdr, cplen);
+	if (p == NULL)
+		return NULL;
+	memcpy(cpdest, p, cplen);
 	cpdest += cplen;
 	nbytes -= cplen;
 	if (!xdr_set_next_buffer(xdr))
-- 
2.7.4


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:55929 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbaGLWBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jul 2014 18:01:11 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so2173937qge.11
        for <linux-nfs@vger.kernel.org>; Sat, 12 Jul 2014 15:01:10 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: xdr_get_next_encode_buffer should be declared static
Date: Sat, 12 Jul 2014 18:01:02 -0400
Message-Id: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quell another sparse warning.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 23fb4e75e245..290af97bf6f9 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -509,7 +509,8 @@ void xdr_commit_encode(struct xdr_stream *xdr)
 }
 EXPORT_SYMBOL_GPL(xdr_commit_encode);
 
-__be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
+static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
+		size_t nbytes)
 {
 	static __be32 *p;
 	int space_left;
-- 
1.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:29420 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753277Ab0HRUnH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:43:07 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/4] sunrpc: simplify xdr_shrijk_pagelen use of "copy"
Date: Wed, 18 Aug 2010 23:43:03 +0300
Message-Id: <1282164183-20389-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C6C4565.1070603@panasas.com>
References: <4C6C4565.1070603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The "copy" variable value can be computed using the existing
logic rather than repeating it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 42a7ebf..2ab59c3 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -402,14 +402,14 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 
 	/* Shift the tail first */
 	if (tail->iov_len != 0) {
+		copy = len;
 		if (tail->iov_len > len) {
 			char *p = (char *)tail->iov_base + len;
 			memmove(p, tail->iov_base, tail->iov_len - len);
+		} else {
+			copy = tail->iov_len;
 		}
 		/* Copy from the inlined pages into the tail */
-		copy = len;
-		if (copy > tail->iov_len)
-			copy = tail->iov_len;
 		_copy_from_pages((char *)tail->iov_base,
 				buf->pages, buf->page_base + pglen - len,
 				copy);
-- 
1.7.2.1


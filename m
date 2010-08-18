Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48587 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753277Ab0HRUmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:42:51 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/4] sunrpc: clean up xdr_shrink_pagelen use of temporary pointer
Date: Wed, 18 Aug 2010 23:42:48 +0300
Message-Id: <1282164168-20318-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C6C4565.1070603@panasas.com>
References: <4C6C4565.1070603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

char *p is used only as a shorthand for tail->iov_base + len in a nested
block.  Move it there.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 91f0de9..41be21f 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -395,7 +395,6 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 {
 	struct kvec *tail;
 	size_t copy;
-	char *p;
 	unsigned int pglen = buf->page_len;
 
 	tail = buf->tail;
@@ -403,8 +402,8 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 
 	/* Shift the tail first */
 	if (tail->iov_len != 0) {
-		p = (char *)tail->iov_base + len;
 		if (tail->iov_len > len) {
+			char *p = (char *)tail->iov_base + len;
 			copy = tail->iov_len - len;
 			memmove(p, tail->iov_base, copy);
 		}
-- 
1.7.2.1


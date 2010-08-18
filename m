Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6282 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753277Ab0HRUm6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:42:58 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/4] sunrpc: don't use the copy variable in nested block
Date: Wed, 18 Aug 2010 23:42:56 +0300
Message-Id: <1282164176-20354-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C6C4565.1070603@panasas.com>
References: <4C6C4565.1070603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

to clean up the code "copy" will be set prior to the block
hence it mustn't be used there.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 41be21f..42a7ebf 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -404,8 +404,7 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 	if (tail->iov_len != 0) {
 		if (tail->iov_len > len) {
 			char *p = (char *)tail->iov_base + len;
-			copy = tail->iov_len - len;
-			memmove(p, tail->iov_base, copy);
+			memmove(p, tail->iov_base, tail->iov_len - len);
 		}
 		/* Copy from the inlined pages into the tail */
 		copy = len;
-- 
1.7.2.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38358 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946429AbcBRRaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:30:13 -0500
Subject: [PATCH v2 02/12] xprtrdma: Clean up unused
 RPCRDMA_INLINE_PAD_THRESH macro
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:30:11 -0500
Message-ID: <20160218173011.14009.4267.stgit@manet.1015granger.net>
In-Reply-To: <20160218172449.14009.47311.stgit@manet.1015granger.net>
References: <20160218172449.14009.47311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes: b3221d6a53c4 ('xprtrdma: Remove logic that constructs...')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index b7b279b..767190b 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -54,8 +54,6 @@
 
 #define RPCRDMA_DEF_INLINE  (1024)	/* default inline max */
 
-#define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
-
 /* Memory registration strategies, by number.
  * This is part of a kernel / user space API. Do not remove. */
 enum rpcrdma_memreg {


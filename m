Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36437 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760151AbcCDQ13 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 11:27:29 -0500
Subject: [PATCH v3 01/11] xprtrdma: Clean up unused
 RPCRDMA_INLINE_PAD_THRESH macro
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 Mar 2016 11:27:26 -0500
Message-ID: <20160304162726.13590.39290.stgit@oracle120-ib.cthon.org>
In-Reply-To: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
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


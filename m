Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:33953 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaEFRfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2014 13:35:04 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] nfsd: remove <linux/nfsd/debug.h>
Date: Tue,  6 May 2014 19:37:16 +0200
Message-Id: <1399397836-31948-5-git-send-email-hch@lst.de>
In-Reply-To: <1399397836-31948-1-git-send-email-hch@lst.de>
References: <1399397836-31948-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is almost nothing left it in, just merge it into the only file
that includes it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfsd.h             |    9 ++++++++-
 include/linux/nfsd/debug.h |   19 -------------------
 2 files changed, 8 insertions(+), 20 deletions(-)
 delete mode 100644 include/linux/nfsd/debug.h

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7a07f9c..e9f2fd4 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -18,11 +18,18 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/msg_prot.h>
 
-#include <linux/nfsd/debug.h>
+#include <uapi/linux/nfsd/debug.h>
 
 #include "stats.h"
 #include "export.h"
 
+#undef ifdebug
+#ifdef NFSD_DEBUG
+# define ifdebug(flag)		if (nfsd_debug & NFSDDBG_##flag)
+#else
+# define ifdebug(flag)		if (0)
+#endif
+
 /*
  * nfsd version
  */
diff --git a/include/linux/nfsd/debug.h b/include/linux/nfsd/debug.h
deleted file mode 100644
index 19ef837..0000000
--- a/include/linux/nfsd/debug.h
+++ /dev/null
@@ -1,19 +0,0 @@
-/*
- * linux/include/linux/nfsd/debug.h
- *
- * Debugging-related stuff for nfsd
- *
- * Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
- */
-#ifndef LINUX_NFSD_DEBUG_H
-#define LINUX_NFSD_DEBUG_H
-
-#include <uapi/linux/nfsd/debug.h>
-
-# undef ifdebug
-# ifdef NFSD_DEBUG
-#  define ifdebug(flag)		if (nfsd_debug & NFSDDBG_##flag)
-# else
-#  define ifdebug(flag)		if (0)
-# endif
-#endif /* LINUX_NFSD_DEBUG_H */
-- 
1.7.10.4


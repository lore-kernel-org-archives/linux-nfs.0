Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53238 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/15] nfsd: remove unused defines
Date: Fri, 26 Aug 2011 18:28:22 -0400
Message-Id: <1314397716-18602-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

At least one of these is actually wrong anyway.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/nfsd/const.h |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/include/linux/nfsd/const.h b/include/linux/nfsd/const.h
index 323f8cf..feb3764 100644
--- a/include/linux/nfsd/const.h
+++ b/include/linux/nfsd/const.h
@@ -15,11 +15,6 @@
 #include <linux/nfs4.h>
 
 /*
- * Maximum protocol version supported by knfsd
- */
-#define NFSSVC_MAXVERS		3
-
-/*
  * Maximum blocksizes supported by daemon under various circumstances.
  */
 #define NFSSVC_MAXBLKSIZE	RPCSVC_MAXPAYLOAD
@@ -42,14 +37,6 @@
  */
 #define NFSD_BUFSIZE		((RPC_MAX_HEADER_WITH_AUTH+26)*XDR_UNIT + NFSSVC_MAXBLKSIZE)
 
-#ifdef CONFIG_NFSD_V4
-# define NFSSVC_XDRSIZE		NFS4_SVC_XDRSIZE
-#elif defined(CONFIG_NFSD_V3)
-# define NFSSVC_XDRSIZE		NFS3_SVC_XDRSIZE
-#else
-# define NFSSVC_XDRSIZE		NFS2_SVC_XDRSIZE
-#endif
-
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_NFSD_CONST_H */
-- 
1.7.4.1


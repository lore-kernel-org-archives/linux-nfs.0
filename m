From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 32/47] nfsd41: provide support for minor version 1 at rpc level
Date: Sat, 28 Mar 2009 11:33:52 +0300
Message-ID: <1238229232-11267-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:14169 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753209AbZC1IeE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:34:04 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/nfsd.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 3bccec3..d0fe9b4 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -23,7 +23,11 @@
 /*
  * nfsd version
  */
+#if defined(CONFIG_NFSD_V4_1)
+#define NFSD_SUPPORTED_MINOR_VERSION	1
+#else /* CONFIG_NFSD_V4_1 */
 #define NFSD_SUPPORTED_MINOR_VERSION	0
+#endif /* CONFIG_NFSD_V4_1 */
 
 /*
  * Flags for nfsd_permission
-- 
1.6.2.1


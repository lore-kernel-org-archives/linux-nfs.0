From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 12/51] nfsd41: provide support for minor version 1 at rpc level
Date: Mon, 10 Nov 2008 22:44:43 +0200
Message-ID: <1226349883-10543-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57216 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbYKJUo4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:44:56 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/nfsd.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 9703540..ffb7897 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -24,7 +24,11 @@
  * nfsd version
  */
 #define NFSD_VERSION		"0.5"
+#if defined(CONFIG_NFSD_V4_1)
+#define NFSD_SUPPORTED_MINOR_VERSION	1
+#else /* CONFIG_NFSD_V4_1 */
 #define NFSD_SUPPORTED_MINOR_VERSION	0
+#endif /* CONFIG_NFSD_V4_1 */
 
 /*
  * Flags for nfsd_permission
-- 
1.6.0.2


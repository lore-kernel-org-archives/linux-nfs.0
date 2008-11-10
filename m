From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 11/51] FIXME: nfsd41: reduce server lease time for nfs41
Date: Mon, 10 Nov 2008 22:44:23 +0200
Message-ID: <1226349863-10506-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57212 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbYKJUof (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:44:35 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

FIXME: bhalevy: find out why this is needed.  Is this only for debugging?

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0e1bc72..dcb075d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -59,8 +59,13 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
+#if defined(CONFIG_NFSD_V4_1)
+static time_t lease_time = 20;     /* default lease time */
+static time_t user_lease_time = 20;
+#else /* CONFIG_NFSD_V4_1 */
 static time_t lease_time = 90;     /* default lease time */
 static time_t user_lease_time = 90;
+#endif /* CONFIG_NFSD_V4_1 */
 static time_t boot_time;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
-- 
1.6.0.2


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 27/44] nfsd41: support 16 slots per session
Date: Tue, 16 Jun 2009 04:20:30 +0300
Message-ID: <1245115230-7692-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2494
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751875AbZFPBU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

128 slots is a bit much without proof that they are needed.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/state.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 644a54b..aea8137 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -92,8 +92,7 @@ struct nfs4_cb_conn {
 	struct rpc_cred	*	cb_cred;
 };
 
-/* Maximum number of slots per session. 128 is useful for long haul TCP */
-#define NFSD_MAX_SLOTS_PER_SESSION	128
+#define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
-- 
1.6.3


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 28/44] nfsd41: use the maximum operations per compound in nfsd4_compoundargs
Date: Tue, 16 Jun 2009 04:20:33 +0300
Message-ID: <1245115233-7725-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2565
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757104AbZFPBUc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The size of the nfsd4_op array in nfsd4_compoundargs determines the
supported maximum number of operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/state.h |    3 +--
 include/linux/nfsd/xdr4.h  |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index aea8137..093f165 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -94,8 +94,7 @@ struct nfs4_cb_conn {
 
 #define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
-/* Maximum number of operations per session compound */
-#define NFSD_MAX_OPS_PER_COMPOUND	16
+#define NFSD_MAX_OPS_PER_COMPOUND	8
 
 struct nfsd4_slot {
 	bool	sl_inuse;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 84ac4bb..d99c8fe 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -446,7 +446,7 @@ struct nfsd4_compoundargs {
 	u32				minorversion;
 	u32				opcnt;
 	struct nfsd4_op			*ops;
-	struct nfsd4_op			iops[8];
+	struct nfsd4_op			iops[NFSD_MAX_OPS_PER_COMPOUND];
 };
 
 struct nfsd4_compoundres {
-- 
1.6.3


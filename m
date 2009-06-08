From: andros@netapp.com
Subject: [PATCH 26/30] nfsd41: use the maximum operations per compound in nfsd4_compoundargs
Date: Mon,  8 Jun 2009 14:21:07 -0400
Message-ID: <1244485271-7461-27-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
 <1244485271-7461-24-git-send-email-andros@netapp.com>
 <1244485271-7461-25-git-send-email-andros@netapp.com>
 <1244485271-7461-26-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499AbZFHSVj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:39 -0400
In-Reply-To: <1244485271-7461-26-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The size of the nfsd4_op array in nfsd4_compoundargs determines the
supported maximum number of operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    3 +--
 include/linux/nfsd/xdr4.h  |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f2ccb64..7dfd01a 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -101,8 +101,7 @@ struct nfs4_callback {
 
 #define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
-/* Maximum number of operations per session compound */
-#define NFSD_MAX_OPS_PER_COMPOUND	16
+#define NFSD_MAX_OPS_PER_COMPOUND	8
 
 struct nfsd4_slot {
 	bool	sl_inuse;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 505e3e3..026d3a5 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -443,7 +443,7 @@ struct nfsd4_compoundargs {
 	u32				minorversion;
 	u32				opcnt;
 	struct nfsd4_op			*ops;
-	struct nfsd4_op			iops[8];
+	struct nfsd4_op			iops[NFSD_MAX_OPS_PER_COMPOUND];
 };
 
 struct nfsd4_compoundres {
-- 
1.5.4.3


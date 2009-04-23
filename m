From: andros@netapp.com
Subject: [PATCH 25/29] nfsd41: use the maximum operations per compound in nfsd4_compoundargs
Date: Thu, 23 Apr 2009 12:43:04 -0400
Message-ID: <1240504988-9572-26-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
 <1240504988-9572-20-git-send-email-andros@netapp.com>
 <1240504988-9572-21-git-send-email-andros@netapp.com>
 <1240504988-9572-22-git-send-email-andros@netapp.com>
 <1240504988-9572-23-git-send-email-andros@netapp.com>
 <1240504988-9572-24-git-send-email-andros@netapp.com>
 <1240504988-9572-25-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757389AbZDWQne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:34 -0400
In-Reply-To: <1240504988-9572-25-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The size of the nfsd4_op array in nfsd4_compoundargs determines the
supported maximum number of operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |    2 +-
 include/linux/nfsd/xdr4.h  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 0dfdb6e..d65ce6f 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -112,7 +112,7 @@ struct nfs4_callback {
 /* Size of each slot cache entry */
 #define NFSD_SLOT_CACHE_SIZE           1024
 /* Maximum number of operations per session compound */
-#define NFSD_MAX_OPS_PER_COMPOUND	16
+#define NFSD_MAX_OPS_PER_COMPOUND	8
 
 struct nfsd4_cache_entry {
 	__be32		ce_status;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 45ccbc3..e312601 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -455,7 +455,7 @@ struct nfsd4_compoundargs {
 	u32				minorversion;
 	u32				opcnt;
 	struct nfsd4_op			*ops;
-	struct nfsd4_op			iops[8];
+	struct nfsd4_op			iops[NFSD_MAX_OPS_PER_COMPOUND];
 };
 
 struct nfsd4_compoundres {
-- 
1.5.4.3


From: andros@netapp.com
Subject: [PATCH 27/31] nfsd41: use the maximum operations per compound in nfsd4_compoundargs
Date: Tue, 28 Apr 2009 13:00:01 -0400
Message-ID: <1240938005-23778-27-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
 <1240938005-23778-18-git-send-email-andros@netapp.com>
 <1240938005-23778-19-git-send-email-andros@netapp.com>
 <1240938005-23778-20-git-send-email-andros@netapp.com>
 <1240938005-23778-21-git-send-email-andros@netapp.com>
 <1240938005-23778-22-git-send-email-andros@netapp.com>
 <1240938005-23778-23-git-send-email-andros@netapp.com>
 <1240938005-23778-24-git-send-email-andros@netapp.com>
 <1240938005-23778-25-git-send-email-andros@netapp.com>
 <1240938005-23778-26-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760446AbZD1RA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:59 -0400
In-Reply-To: <1240938005-23778-26-git-send-email-andros@netapp.com>
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
index 0b07d40..49e3f60 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -107,8 +107,7 @@ struct nfs4_callback {
 
 #define NFSD_MAX_SLOTS_PER_SESSION	16
 #define NFSD_SLOT_CACHE_SIZE		512
-/* Maximum number of operations per session compound */
-#define NFSD_MAX_OPS_PER_COMPOUND	16
+#define NFSD_MAX_OPS_PER_COMPOUND	8
 
 struct nfsd4_slot {
 	bool	sl_inuse;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index cd51fa8..bc8fab3 100644
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


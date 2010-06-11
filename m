From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 08/26] pnfs-submit: remove PNFS_LAYOUTGET_ON_OPEN
Date: Fri, 11 Jun 2010 03:31:35 -0400
Message-ID: <1276241513-17942-9-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140Ab0FKHcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:21 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3u1024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:12 -0700 (PDT)
In-Reply-To: <1276241513-17942-8-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is not used anywhere.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |    3 +--
 include/linux/nfs4_pnfs.h |   14 --------------
 2 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c15b90a..7fc93e6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -710,8 +710,7 @@ struct layoutdriver_io_operations filelayout_io_operations = {
 };
 
 struct layoutdriver_policy_operations filelayout_policy_operations = {
-	.flags                 = PNFS_USE_RPC_CODE |
-	                         PNFS_LAYOUTGET_ON_OPEN,
+	.flags                 = PNFS_USE_RPC_CODE,
 	.get_stripesize        = filelayout_get_stripesize,
 	.pg_test               = filelayout_pg_test,
 };
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 9b8dd26..f6e97c8 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -179,11 +179,6 @@ enum layoutdriver_policy_flags {
 	/* Should the NFS req. gather algorithm cross stripe boundaries? */
 	PNFS_GATHER_ACROSS_STRIPES	= 1 << 1,
 
-	/* Should the pNFS client issue a layoutget call in the
-	 * same compound as the OPEN operation?
-	 */
-	PNFS_LAYOUTGET_ON_OPEN		= 1 << 2,
-
 	/* Should the pNFS client commit and return the layout upon a setattr */
 	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 3,
 };
@@ -212,15 +207,6 @@ pnfs_ld_gather_across_stripes(struct pnfs_layoutdriver_type *ld)
 	return ld->ld_policy_ops->flags & PNFS_GATHER_ACROSS_STRIPES;
 }
 
-/* Should the pNFS client issue a layoutget call in the
- * same compound as the OPEN operation?
- */
-static inline int
-pnfs_ld_layoutget_on_open(struct pnfs_layoutdriver_type *ld)
-{
-	return ld->ld_policy_ops->flags & PNFS_LAYOUTGET_ON_OPEN;
-}
-
 /* Should the pNFS client commit and return the layout upon a setattr
  */
 static inline int
-- 
1.6.6.1


From: andros@netapp.com
Subject: [PATCH 6/6] pnfsd: fix compile errors when CONFIG_PNFSD is not set
Date: Tue,  9 Feb 2010 12:42:37 -0500
Message-ID: <1265737357-9405-7-git-send-email-andros@netapp.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>
 <1265737357-9405-2-git-send-email-andros@netapp.com>
 <1265737357-9405-3-git-send-email-andros@netapp.com>
 <1265737357-9405-4-git-send-email-andros@netapp.com>
 <1265737357-9405-5-git-send-email-andros@netapp.com>
 <1265737357-9405-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345Ab0BIRnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 12:43:00 -0500
In-Reply-To: <1265737357-9405-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4pnfsd.c   |    4 ++++
 fs/nfsd/nfs4pnfsdlm.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 75bddd8..44a1edd 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -21,6 +21,8 @@
  *
  *****************************************************************************/
 
+#if defined(CONFIG_PNFSD)
+
 #include "pnfsd.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
@@ -1676,3 +1678,5 @@ int nfsd_device_notify_cb(struct super_block *sb,
 		__func__, status, notify_num);
 	return status;
 }
+
+#endif /* CONFIG_PNFSD */
diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 83c4698..8e8a5a8 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -21,6 +21,8 @@
  *
  ******************************************************************************/
 
+#if defined(CONFIG_PNFSD)
+
 #include <linux/nfs4.h>
 #include <linux/nfsd/const.h>
 #include <linux/nfsd/debug.h>
@@ -402,3 +404,5 @@ const struct pnfs_export_operations pnfs_dlm_export_ops = {
 	.layout_get = nfsd4_pnfs_dlm_layoutget,
 };
 EXPORT_SYMBOL(pnfs_dlm_export_ops);
+
+#endif /* CONFIG_PNFSD */
-- 
1.6.6


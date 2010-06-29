From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd-files: nfsd4_pnfs_dlm_shutdown should use list_for_each_entry_safe
Date: Tue, 29 Jun 2010 15:57:26 +0300
Message-ID: <1277816246-15577-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22515 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754966Ab0F2M53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:57:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 18d4c0d..006ded5 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -209,12 +209,13 @@ out_free:
 
 void nfsd4_pnfs_dlm_shutdown(void)
 {
-	struct dlm_device_entry *dlm_pdev;
+	struct dlm_device_entry *dlm_pdev, *next;
 
 	dprintk("--> %s\n", __func__);
 
 	spin_lock(&dlm_device_list_lock);
-	list_for_each_entry(dlm_pdev, &dlm_device_list, dlm_dev_list) {
+	list_for_each_entry_safe (dlm_pdev, next, &dlm_device_list,
+				  dlm_dev_list) {
 		list_del(&dlm_pdev->dlm_dev_list);
 		kfree(dlm_pdev);
 	}
-- 
1.6.6.1


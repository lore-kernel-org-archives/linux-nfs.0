From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd-files: prevent NULL deref in nfsd4_pnfs_dlm_getdevinfo
Date: Tue, 29 Jun 2010 15:35:34 +0300
Message-ID: <1277814934-13945-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44309 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753326Ab0F2Mfh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 08:35:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If allocation failed and fl_device_list is NULL then fl_device_length
must be set to zero to prevent freeing its contents on exit at out:

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index ffe1c32..18d4c0d 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -291,6 +291,7 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 	if (!fdev.fl_device_list) {
 		printk(KERN_ERR "%s: ERROR: unable to kmalloc a device list "
 			"buffer for %d DSes.\n", __func__, i);
+		fdev.fl_device_length = 0;
 		goto out;
 	}
 
-- 
1.6.6.1


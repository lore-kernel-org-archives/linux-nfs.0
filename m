Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:39585 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab3ADLAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 06:00:08 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so9210792pad.31
        for <linux-nfs@vger.kernel.org>; Fri, 04 Jan 2013 03:00:07 -0800 (PST)
From: ycnian@gmail.com
To: bhalevy@tonian.com
Cc: linux-nfs@vger.kernel.org, Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] pnfsd: Correct the buffer size of ds_list in dlm_device_entry
Date: Fri,  4 Jan 2013 18:43:43 +0800
Message-Id: <1357296223-5796-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

In nfsd4_set_pnfs_dlm_device(), if there is a device with the same disk_name as
the new device, pnfsd will clear the memory of ds_list, and then update it with
ds list from the new device. The size of ds_list in struct dlm_device_entry is
NFSD_DLM_DS_LIST_MAX, but not DISK_NAME_LEN.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index e8423e0..c138d41 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -187,7 +187,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
 		dprintk("%s pnfs_dlm_device %s:%s already in cache "
 			" replace ds_list with new ds_list %s\n", __func__,
 			found->disk_name, found->ds_list, new->ds_list);
-		memset(found->ds_list, 0, DISK_NAME_LEN);
+		memset(found->ds_list, 0, NFSD_DLM_DS_LIST_MAX);
 		memcpy(found->ds_list, new->ds_list, strlen(new->ds_list));
 		found->num_ds = new->num_ds;
 		kfree(new);
-- 
1.7.4.4


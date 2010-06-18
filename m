From: Eric Anderle <eanderle@umich.edu>
Subject: [PATCH 1/1] pnfs: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()
Date: Fri, 18 Jun 2010 11:55:58 -0400
Message-ID: <1276876558.1796.19.camel@Berlin>
Reply-To: eanderle@umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: bhalevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:56099 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab0FRP4F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 11:56:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From cd18db8401e1df4ee031e6a6c53e0f3353080dca Mon Sep 17 00:00:00 2001
From: Eric Anderle <eanderle@umich.edu>
Date: Fri, 18 Jun 2010 10:09:46 -0400
Subject: [PATCH 1/1] pnfs: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()

Previously, when updating the DS list of an existing pnfs dlm device,
the number of ds's was not updated. Fixed.

Signed-off-by: Eric Anderle <eanderle@umich.edu>
---
 fs/nfsd/nfs4pnfsdlm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 40f9b84..ffe1c32 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -189,6 +189,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
 			found->disk_name, found->ds_list, new->ds_list);
 		memset(found->ds_list, 0, DISK_NAME_LEN);
 		memcpy(found->ds_list, new->ds_list, strlen(new->ds_list));
+		found->num_ds = new->num_ds;
 		kfree(new);
 	} else {
 		dprintk("%s Adding pnfs_dlm_device %s:%s\n", __func__,
-- 
1.7.0.4




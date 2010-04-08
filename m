From: andros@netapp.com
Subject: [PATCH 14/14] SQUASHME pnfs_submit: remove kfree from under spinlock
Date: Thu,  8 Apr 2010 15:54:10 -0400
Message-ID: <1270756450-5570-15-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
 <1270756450-5570-7-git-send-email-andros@netapp.com>
 <1270756450-5570-8-git-send-email-andros@netapp.com>
 <1270756450-5570-9-git-send-email-andros@netapp.com>
 <1270756450-5570-10-git-send-email-andros@netapp.com>
 <1270756450-5570-11-git-send-email-andros@netapp.com>
 <1270756450-5570-12-git-send-email-andros@netapp.com>
 <1270756450-5570-13-git-send-email-andros@netapp.com>
 <1270756450-5570-14-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933353Ab0DHTy7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:59 -0400
In-Reply-To: <1270756450-5570-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 50e2865..5c13dc5 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -410,9 +410,7 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 				ds->ds_ip_addr);
 		list_add(&ds->ds_node, &nfs4_data_server_cache);
 		*dsp = ds;
-	}
-	if (tmp_ds != NULL) {
-		destroy_ds(ds);
+	} else {
 		atomic_inc(&tmp_ds->ds_count);
 		dprintk("%s data server found ip 0x%x, inc'ed ds_count to %d\n",
 				__func__, tmp_ds->ds_ip_addr,
@@ -420,6 +418,8 @@ nfs4_pnfs_ds_add(struct inode *inode, struct nfs4_pnfs_ds **dsp,
 		*dsp = tmp_ds;
 	}
 	spin_unlock(&nfs4_ds_cache_lock);
+	if (tmp_ds != NULL)
+		destroy_ds(ds);
 }
 
 static struct nfs4_pnfs_ds *
-- 
1.6.6


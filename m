From: andros@netapp.com
Subject: [PATCH 6/7] SQUASHME pnfs-submit consolidate commit parameters
Date: Thu, 15 Jul 2010 12:13:53 -0400
Message-ID: <1279210434-2772-7-git-send-email-andros@netapp.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
 <1279210434-2772-2-git-send-email-andros@netapp.com>
 <1279210434-2772-3-git-send-email-andros@netapp.com>
 <1279210434-2772-4-git-send-email-andros@netapp.com>
 <1279210434-2772-5-git-send-email-andros@netapp.com>
 <1279210434-2772-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933647Ab0GOQNq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:46 -0400
In-Reply-To: <1279210434-2772-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NOTE: API change

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    3 +--
 include/linux/nfs4_pnfs.h |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 51bd66f..7327cb2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1362,8 +1362,7 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	data->pdata.call_ops = call_ops;
 	data->pdata.how = sync;
 	data->pdata.lseg = NULL;
-	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(NFS_I(inode)->layout,
-							sync, data);
+	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(data, sync);
 	if (trypnfs == PNFS_NOT_ATTEMPTED)
 		_pnfs_clear_lseg_from_pages(&data->pages);
 	else
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 13f71ad..5782156 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -138,8 +138,7 @@ struct layoutdriver_io_operations {
 	 * 2) currently the NFS code doesn't create a page array (as it does with read/write)
 	 */
 	enum pnfs_try_status
-	(*commit) (struct pnfs_layout_type *layoutid,
-		   int sync, struct nfs_write_data *nfs_data);
+	(*commit) (struct nfs_write_data *nfs_data, int how);
 
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
-- 
1.6.6


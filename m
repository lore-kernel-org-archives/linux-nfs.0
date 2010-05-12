From: andros@netapp.com
Subject: [PATCH 06/10] SQUASHME pnfs_submit: remove pg_threshold
Date: Wed, 12 May 2010 10:44:18 -0400
Message-ID: <1273675462-15758-7-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
 <1273675462-15758-6-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3866 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237Ab0ELOpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:03 -0400
In-Reply-To: <1273675462-15758-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into: "pnfs:initialize pnfs_pageio for write"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c            |    3 ---
 include/linux/nfs_page.h |    1 -
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c48bcd7..226ab4f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1402,7 +1402,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	loff_t loff;
 	int status = 0;
 
-	pgio->pg_threshold = 0;
 	pgio->pg_iswrite = 0;
 	pgio->pg_boundary = 0;
 	pgio->pg_test = NULL;
@@ -1433,12 +1432,10 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 
 	pgio->pg_iswrite = 1;
 	if (!pnfs_enabled_sb(server)) {
-		pgio->pg_threshold = 0;
 		pgio->pg_boundary = 0;
 		pgio->pg_test = NULL;
 		return;
 	}
-	pgio->pg_threshold = pnfs_getthreshold(inode, 1);
 	pgio->pg_boundary = pnfs_getboundary(inode);
 	pnfs_set_pg_test(inode, pgio);
 }
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index df93480..d04ebb2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -62,7 +62,6 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 #ifdef CONFIG_NFS_V4_1
-	size_t			pg_threshold;
 	int			pg_iswrite;
 	int			pg_boundary;
 	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
-- 
1.6.6


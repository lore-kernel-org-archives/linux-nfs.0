From: andros@netapp.com
Subject: [PATCH 07/10] SQUASHME pnfs_submit: don't use below_threshold in read
Date: Wed, 12 May 2010 10:44:19 -0400
Message-ID: <1273675462-15758-8-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
 <1273675462-15758-6-git-send-email-andros@netapp.com>
 <1273675462-15758-7-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242Ab0ELOpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:03 -0400
In-Reply-To: <1273675462-15758-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into: "pnfs:initialize pageio for read"

Signed-off-by: Andy Adamon <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 226ab4f..19cc193 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1412,7 +1412,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	/* Calculate the total read-ahead count */
 	readahead_range(inode, pages, &loff, &count);
 
-	if (count > 0 && !below_threshold(inode, count, 0)) {
+	if (count > 0) {
 		status = pnfs_update_layout(inode, ctx, count,
 						loff, IOMODE_READ, NULL);
 		dprintk("%s virt update returned %d\n", __func__, status);
-- 
1.6.6


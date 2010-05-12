From: andros@netapp.com
Subject: [PATCH 10/10] SQUASHME pnfs_submit: cleanup filelayout pg_test
Date: Wed, 12 May 2010 10:44:22 -0400
Message-ID: <1273675462-15758-11-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
 <1273675462-15758-6-git-send-email-andros@netapp.com>
 <1273675462-15758-7-git-send-email-andros@netapp.com>
 <1273675462-15758-8-git-send-email-andros@netapp.com>
 <1273675462-15758-9-git-send-email-andros@netapp.com>
 <1273675462-15758-10-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755414Ab0ELOpE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:04 -0400
In-Reply-To: <1273675462-15758-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

pg_bsize is set in nfs_pageio_init.
Squash into: "pnfs:filelayout:pg_test"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index dfc5149..200bbc2 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -697,9 +697,6 @@ filelayout_get_stripesize(struct pnfs_layout_type *layoutid)
 /*
  * filelayout_pg_test(). Called by nfs_can_coalesce_requests()
  *
- * For writes which come from the flush daemon, set the bsize on the fly.
- * reads set the bsize in pnfs_pageio_init_read.
- *
  * return 1 :  coalesce page
  * return 0 :  don't coalesce page
  */
@@ -709,13 +706,6 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 {
 	u64 p_stripe, r_stripe;
 
-	if (!pgio->pg_iswrite)
-		goto boundary;
-
-	if (pgio->pg_bsize != NFS_SERVER(pgio->pg_inode)->wsize)
-		pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
-
-boundary:
 	if (pgio->pg_boundary == 0)
 		return 1;
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
-- 
1.6.6


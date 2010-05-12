From: andros@netapp.com
Subject: [PATCH 01/10] SQUASHME pnfs_submit: remove filelayout get threshold
Date: Wed, 12 May 2010 10:44:13 -0400
Message-ID: <1273675462-15758-2-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab0ELOpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:00 -0400
In-Reply-To: <1273675462-15758-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused threshold calculations
Squash into "pnfs:filelayout:policy ops"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9d1274d..c2dda25 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -737,13 +737,6 @@ boundary:
 	return (p_stripe == r_stripe);
 }
 
-ssize_t
-filelayout_get_io_threshold(struct pnfs_layout_type *layoutid,
-			    struct inode *inode)
-{
-	return -1;
-}
-
 struct layoutdriver_io_operations filelayout_io_operations = {
 	.commit                  = filelayout_commit,
 	.read_pagelist           = filelayout_read_pagelist,
@@ -761,8 +754,6 @@ struct layoutdriver_policy_operations filelayout_policy_operations = {
 	                         PNFS_LAYOUTGET_ON_OPEN,
 	.get_stripesize        = filelayout_get_stripesize,
 	.pg_test               = filelayout_pg_test,
-	.get_read_threshold    = filelayout_get_io_threshold,
-	.get_write_threshold   = filelayout_get_io_threshold,
 };
 
 struct pnfs_layoutdriver_type filelayout_type = {
-- 
1.6.6


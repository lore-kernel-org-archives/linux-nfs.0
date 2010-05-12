From: andros@netapp.com
Subject: [PATCH 05/10] SQUASHME pnfs_submit: don't use pg_threshold
Date: Wed, 12 May 2010 10:44:17 -0400
Message-ID: <1273675462-15758-6-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754989Ab0ELOpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:01 -0400
In-Reply-To: <1273675462-15758-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to remove unused get_read_threshold io operation.
Squash into: "pnfs:filelayout:pg_test"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c2dda25..dfc5149 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -712,8 +712,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	if (!pgio->pg_iswrite)
 		goto boundary;
 
-	if (pgio->pg_bsize != NFS_SERVER(pgio->pg_inode)->wsize &&
-	    pgio->pg_count > pgio->pg_threshold)
+	if (pgio->pg_bsize != NFS_SERVER(pgio->pg_inode)->wsize)
 		pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
 
 boundary:
-- 
1.6.6


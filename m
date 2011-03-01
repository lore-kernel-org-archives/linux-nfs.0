Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551Ab1CATZw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 14:25:52 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH pnfs-submit-wave3 update 1/5] wave3: SQUASHME: remove comment to pnfs_pageio_init_read
Date: Tue,  1 Mar 2011 14:25:30 -0500
Message-Id: <1299007534-4105-2-git-send-email-andros@netapp.com>
In-Reply-To: <1299007534-4105-1-git-send-email-andros@netapp.com>
References: <1299007534-4105-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

Benny points out this comment is confusing and out of place
for the write code, remove it from read code too.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e17cebd..3e54514 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -864,9 +864,6 @@ static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
-/*
- * rsize is already set by caller to MDS rsize.
- */
 void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
-- 
1.6.2.5


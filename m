Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47382 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965046Ab2CVTTn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:19:43 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 06/11] NFSv4.1: send filelayout DS commits to the MDS on invalid deviceid
Date: Thu, 22 Mar 2012 15:19:34 -0400
Message-Id: <1332443979-2302-7-git-send-email-andros@netapp.com>
In-Reply-To: <1332443979-2302-1-git-send-email-andros@netapp.com>
References: <1332443979-2302-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 869ce26..04d9445 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -848,10 +848,11 @@ filelayout_choose_commit_list(struct nfs_page *req,
 			      struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	u32 i, j;
 	struct list_head *list;
 
-	if (fl->commit_through_mds)
+	if (fl->commit_through_mds || filelayout_test_devid_invalid(devid))
 		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
 
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
-- 
1.7.6.4


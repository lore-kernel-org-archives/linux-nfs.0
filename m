Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5492 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074Ab2FLOOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jun 2012 10:14:20 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1: Use session max response size for GETDEVICEINFO gdia_maxcount
Date: Wed,  6 Jun 2012 23:57:13 -0400
Message-Id: <1339041433-2261-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We prepare for the largest possible GETDEVICEINFO response, which
can not be greater than the negotiated session maximum response size.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index a1fab8d..f81231f 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -728,7 +728,7 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_fla
 	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
 	pdev->pages = pages;
 	pdev->pgbase = 0;
-	pdev->pglen = PAGE_SIZE * max_pages;
+	pdev->pglen = max_resp_sz;
 	pdev->mincount = 0;
 
 	rc = nfs4_proc_getdeviceinfo(server, pdev);
-- 
1.7.6.4


From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 05/24] SQUASHME: ensure pnfs_update_lseg clears lsegp on error
Date: Tue,  8 Jun 2010 00:19:02 -0400
Message-ID: <1275970761-31806-6-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab0FHETq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:46 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOPu014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:28 -0700 (PDT)
In-Reply-To: <1275970761-31806-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should be squashed into my (or alexandros's)submission patches for
version 2. Compensate for Alexandros returning error but assigning lseg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2f8fa3c..b990471 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1064,6 +1064,8 @@ pnfs_update_layout(struct inode *ino,
 	DEFINE_WAIT(__wait);
 	int result = 0;
 
+	if (take_ref)
+		*lsegpp = NULL;
 	lo = get_lock_alloc_layout(ino);
 	if (IS_ERR(lo)) {
 		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
@@ -1078,6 +1080,7 @@ pnfs_update_layout(struct inode *ino,
 			put_lseg(lseg);
 
 		/* someone is cleaning the layout */
+		lseg = NULL;
 		result = -EAGAIN;
 		goto out_put;
 	}
-- 
1.6.6.1


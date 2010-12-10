Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab0LJGI6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:58 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLx023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:57 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 22/22] pnfs-submit: Turn off layoutcommits
Date: Thu,  9 Dec 2010 20:22:57 -0500
Message-Id: <1291944177-7819-23-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Recent changes to close can delay pending layoutcommit until umount,
when the async layoutcommits can come tricklng in after we have destroyed
the session.  Since file does not need them, just turn them off for
the moment.  Non-file layouts will probably have to trigger them in
some fashion at close.

A better solution is to just push all the layoutcommit code outside
of the pnfs-submit branch.  This is really just a stop gap until code
is rearranged to make that easier.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9b15535..224bdfe 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3098,7 +3098,6 @@ static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_dat
 {
 #ifdef CONFIG_NFS_V4_1
 	pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
-	pnfs_need_layoutcommit(nfsi, data->args.context);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
-- 
1.7.2.1


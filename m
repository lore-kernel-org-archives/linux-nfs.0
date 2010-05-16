From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 01/22] Revert "pnfs-nonfilelayout: Prelim support for non-file layout O_DIRECT"
Date: Sat, 15 May 2010 21:22:52 -0400
Message-ID: <1273972993-15369-2-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0ETKa2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:28 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQbp022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:27 -0700 (PDT)
In-Reply-To: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 05277f5f5236462a11e7a20ebe9009449f8a463d.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e111e9f..02e5918 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -191,22 +191,12 @@ static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
 {
 	ssize_t result = -EIOCBQUEUED;
 
-	if (!pnfs_use_rpc(NFS_SERVER(dreq->inode))) {
-		/* FIXME: Right now non-rpc layout types must perform
-		 * syncronous direct i/o.
-		 * New pNFS callback to wait on outstanding requests?
-		 */
-		result = 0;
-		goto set_result;
-	}
-
 	/* Async requests don't wait here */
 	if (dreq->iocb)
 		goto out;
 
 	result = wait_for_completion_killable(&dreq->completion);
 
-set_result:
 	if (!result)
 		result = dreq->error;
 	if (!result)
-- 
1.6.6.1


From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 01/26] pnfs-submit: Revert "pnfs-nonfilelayout: Prelim support for non-file layout O_DIRECT"
Date: Fri, 11 Jun 2010 03:31:28 -0400
Message-ID: <1276241513-17942-2-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30552 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab0FKHcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:20 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3ts024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:04 -0700 (PDT)
In-Reply-To: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
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


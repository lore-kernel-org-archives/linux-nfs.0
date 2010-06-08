From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 01/24] Revert "pnfs-nonfilelayout: Prelim support for non-file layout O_DIRECT"
Date: Tue,  8 Jun 2010 00:18:58 -0400
Message-ID: <1275970761-31806-2-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab0FHETp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:45 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOPq014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:25 -0700 (PDT)
In-Reply-To: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
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


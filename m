Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757802Ab1BKSAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 07/17] SQUASHME remove reset mds_offset from filelayout_rpc_call_done
Date: Thu, 10 Feb 2011 20:52:40 -0500
Message-Id: <1297389170-26702-8-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-7-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 36a797a..083f541 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -201,11 +201,6 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
-	if (rdata->mds_offset) {
-		dprintk("%s new off %llu orig offset %llu\n", __func__,
-			rdata->args.offset, rdata->mds_offset);
-		rdata->args.offset = rdata->mds_offset;
-	}
 
 	/* Note this may cause RPC to be resent */
 	rdata->mds_ops->rpc_call_done(task, data);
-- 
1.6.6


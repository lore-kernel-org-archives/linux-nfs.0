Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51331 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757733Ab1BKSAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 06/17] SQUASHME rename nfs_read_data call_ops THREE
Date: Thu, 10 Feb 2011 20:52:39 -0500
Message-Id: <1297389170-26702-7-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-6-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-filelayout-read

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 61f21b6..36a797a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -208,14 +208,14 @@ static void filelayout_read_call_done(struct rpc_task *task, void *data)
 	}
 
 	/* Note this may cause RPC to be resent */
-	rdata->call_ops->rpc_call_done(task, data);
+	rdata->mds_ops->rpc_call_done(task, data);
 }
 
 static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
-	rdata->call_ops->rpc_release(data);
+	rdata->mds_ops->rpc_release(data);
 }
 
 struct rpc_call_ops filelayout_read_call_ops = {
-- 
1.6.6


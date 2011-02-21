Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47179 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1BUWaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:30:21 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/9] pnfs: fix missing unlock in nfs_client_return_layouts
Date: Mon, 21 Feb 2011 14:30:16 -0800
Message-Id: <1298327416-7890-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 48c61c2..9547c34 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -209,6 +209,7 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 		list_del(&cb_info->pcl_list);
 		clp->cl_cb_lrecall_count--;
 		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
+		spin_unlock(&clp->cl_lock);
 		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		kfree(cb_info);
 	}
-- 
1.7.3.4


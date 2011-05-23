Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43565 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab1EWABS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 20:01:18 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 30/38] SQUASHME: initialize data->task on the non-rpc io done success paths
Date: Mon, 23 May 2011 03:01:06 +0300
Message-Id: <1306108866-29053-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f59802..d39fcca 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1064,6 +1064,7 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 
 	if (!data->pnfs_error) {
 		pnfs_set_layoutcommit(data);
+		memset(&data->task, 0, sizeof(data->task));
 		data->mds_ops->rpc_call_done(&data->task, data);
 		data->mds_ops->rpc_release(data);
 		return 0;
@@ -1113,6 +1114,7 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 
 	if (!data->pnfs_error) {
 		__nfs4_read_done_cb(data);
+		memset(&data->task, 0, sizeof(data->task));
 		data->mds_ops->rpc_call_done(&data->task, data);
 		data->mds_ops->rpc_release(data);
 		return 0;
-- 
1.7.3.4


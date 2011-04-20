Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57147 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296Ab1DTR1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:27:44 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 11/27] pnfs: per mount layout driver private data
Date: Wed, 20 Apr 2011 20:27:41 +0300
Message-Id: <1303320461-21369-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_fs_sb.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 216cea5..c5b3fd0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -142,6 +142,9 @@ struct nfs_server {
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct rpc_wait_queue	roc_rpcwaitq;
+	void			       *pnfs_ld_data; /* Per-mount data */
+	unsigned int			ds_rsize;  /* Data server read size */
+	unsigned int			ds_wsize;  /* Data server write size */
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
-- 
1.7.3.4


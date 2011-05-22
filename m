Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43522 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab1EVX5m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:57:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 20/38] pnfs: per mount layout driver private data
Date: Mon, 23 May 2011 02:57:29 +0300
Message-Id: <1306108649-28644-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

With the objects layout security model we have object capabilities
that are associated with the layout ad we anticipate that the server
will issue a cb_layoutrecall for any setattr that changes security
related attributes (user/group/mode/acl) or truncates the file.
Therefore, the client returns the layout in advance to avoid the
extra layout recall.

[get rid of ds_[rw]size]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_fs_sb.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..66e031f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -143,6 +143,7 @@ struct nfs_server {
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct rpc_wait_queue	roc_rpcwaitq;
+	void			       *pnfs_ld_data; /* Per-mount data */
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
-- 
1.7.3.4


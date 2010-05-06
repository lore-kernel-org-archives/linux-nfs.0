From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/5] FIXME: pnfs-post-submit: per mount layout driver private data
Date: Thu,  6 May 2010 22:23:52 +0300
Message-ID: <1273173832-27786-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48673 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756909Ab0EFTYE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:24:04 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Temporary relief until we convert to use generic device cache.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_fs_sb.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index cad56a7..00a4e7e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -164,6 +164,7 @@ struct nfs_server {
 
 #ifdef CONFIG_NFS_V4_1
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+	void			       *pnfs_ld_data; /* Per-mount data */
 	unsigned int			ds_rsize;  /* Data server read size */
 	unsigned int			ds_wsize;  /* Data server write size */
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.5.1


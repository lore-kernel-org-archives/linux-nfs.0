Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47220 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab0LOSbM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:31:12 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] Revert "pnfs-submit: Turn off layoutcommits"
Date: Wed, 15 Dec 2010 20:31:10 +0200
Message-Id: <1292437870-21692-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 1120c1ee8209679aa187248917875665dd8521a0.
---
 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 68111ef..176449f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3098,6 +3098,7 @@ static void pnfs4_update_write_done(struct nfs_inode *nfsi, struct nfs_write_dat
 {
 #ifdef CONFIG_NFS_V4_1
 	pnfs_update_last_write(nfsi, data->args.offset, data->res.count);
+	pnfs_need_layoutcommit(nfsi, data->args.context);
 #endif /* CONFIG_NFS_V4_1 */
 }
 
-- 
1.7.2.3


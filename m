From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-submit: check for NULL nfs_client in nfs4_init_pnfs
Date: Mon, 17 May 2010 23:06:18 +0300
Message-ID: <1274126778-32281-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46591 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751560Ab0EQUGV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:06:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

server->nfs_client may be NULL on entry if nfs4_init_client() failed

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1979831..8c27a91 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -888,7 +888,7 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
 static void nfs4_uninit_pnfs(struct nfs_server *server)
 {
 #if defined(CONFIG_NFS_V4_1)
-	if (nfs4_has_session(server->nfs_client))
+	if (server->nfs_client && nfs4_has_session(server->nfs_client))
 		unmount_pnfs_layoutdriver(server);
 #endif /* CONFIG_NFS_V4_1 */
 }
-- 
1.6.6.1


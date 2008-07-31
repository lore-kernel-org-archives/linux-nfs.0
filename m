From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] nfs: ERR_PTR is expected on failure from nfs_do_clone_mount
Date: Thu, 31 Jul 2008 09:38:55 +0400
Message-ID: <1217482735-2336-1-git-send-email-den@openvz.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44480 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbYGaFii (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2008 01:38:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace NULL with ERR_PTR(-EINVAL).

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 fs/nfs/namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 2f285ef..99d527e 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -189,7 +189,7 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 					   struct nfs_clone_mount *mountdata)
 {
 #ifdef CONFIG_NFS_V4
-	struct vfsmount *mnt = NULL;
+	struct vfsmount *mnt = ERR_PTR(-EINVAL);
 	switch (server->nfs_client->rpc_ops->version) {
 		case 2:
 		case 3:
-- 
1.5.4.5


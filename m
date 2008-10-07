From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/30] nfs: ERR_PTR is expected on failure from
	nfs_do_clone_mount
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.19766.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "Denis V. Lunev" <den@openvz.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381AbYJGWcq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:46 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Denis V. Lunev <den@openvz.org>

Replace NULL with ERR_PTR(-EINVAL).

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 66df08d..d398775 100644
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


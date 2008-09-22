From: akpm@linux-foundation.org
Subject: [patch 1/3] nfs: ERR_PTR is expected on failure from nfs_do_clone_mount
Date: Mon, 22 Sep 2008 14:54:33 -0700
Message-ID: <200809222154.m8MLsXvV032095@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, den@openvz.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48048 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753772AbYIVVzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 17:55:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>

Replace NULL with ERR_PTR(-EINVAL).

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/namespace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/nfs/namespace.c~nfs-err_ptr-is-expected-on-failure-from-nfs_do_clone_mount fs/nfs/namespace.c
--- a/fs/nfs/namespace.c~nfs-err_ptr-is-expected-on-failure-from-nfs_do_clone_mount
+++ a/fs/nfs/namespace.c
@@ -189,7 +189,7 @@ static struct vfsmount *nfs_do_clone_mou
 					   struct nfs_clone_mount *mountdata)
 {
 #ifdef CONFIG_NFS_V4
-	struct vfsmount *mnt = NULL;
+	struct vfsmount *mnt = ERR_PTR(-EINVAL);
 	switch (server->nfs_client->rpc_ops->version) {
 		case 2:
 		case 3:
_

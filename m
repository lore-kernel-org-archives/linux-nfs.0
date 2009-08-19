From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/32] SUNRPC: Clean up rpc_pipefs lookup code...
Date: Wed, 19 Aug 2009 19:38:32 -0400
Message-ID: <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754114AbZHSXk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:56 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNehbt001920
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:44 -0700 (PDT)
In-Reply-To: <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8fa7182..2940b92 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -484,12 +484,12 @@ static const struct dentry_operations rpc_dentry_operations = {
 	.d_delete = rpc_delete_dentry,
 };
 
-static int
-rpc_lookup_parent(char *path, struct nameidata *nd)
+static int __rpc_lookup_path(const char *pathname, unsigned flags,
+			     struct nameidata *nd)
 {
 	struct vfsmount *mnt;
 
-	if (path[0] == '\0')
+	if (pathname[0] == '\0')
 		return -ENOENT;
 
 	mnt = rpc_get_mount();
@@ -499,15 +499,20 @@ rpc_lookup_parent(char *path, struct nameidata *nd)
 		return PTR_ERR(mnt);
 	}
 
-	if (vfs_path_lookup(mnt->mnt_root, mnt, path, LOOKUP_PARENT, nd)) {
+	if (vfs_path_lookup(mnt->mnt_root, mnt, pathname, flags, nd)) {
 		printk(KERN_WARNING "%s: %s failed to find path %s\n",
-				__FILE__, __func__, path);
+				__FILE__, __func__, pathname);
 		rpc_put_mount();
 		return -ENOENT;
 	}
 	return 0;
 }
 
+static int rpc_lookup_parent(const char *pathname, struct nameidata *nd)
+{
+	return __rpc_lookup_path(pathname, LOOKUP_PARENT, nd);
+}
+
 static void
 rpc_release_path(struct nameidata *nd)
 {
-- 
1.6.0.4

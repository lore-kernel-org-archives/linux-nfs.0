Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:64609 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145Ab3JNM2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 08:28:31 -0400
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: John McCutchan <john@johnmccutchan.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Paris <eparis@redhat.com>, Robert Love <rlove@rlove.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] fs: use path_equal() and path_put() to simplify code
Date: Mon, 14 Oct 2013 20:26:00 +0800
Message-ID: <1381753562-47884-2-git-send-email-wangkefeng.wang@huawei.com>
In-Reply-To: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
References: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 fs/namei.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 645268f..1a6c139 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -918,9 +918,8 @@ int follow_up(struct path *path)
 	mntget(&parent->mnt);
 	mountpoint = dget(mnt->mnt_mountpoint);
 	br_read_unlock(&vfsmount_lock);
-	dput(path->dentry);
+	path_put(path);
 	path->dentry = mountpoint;
-	mntput(path->mnt);
 	path->mnt = &parent->mnt;
 	return 1;
 }
@@ -1077,8 +1076,7 @@ int follow_down_one(struct path *path)
 
 	mounted = lookup_mnt(path);
 	if (mounted) {
-		dput(path->dentry);
-		mntput(path->mnt);
+		path_put(path);
 		path->mnt = mounted;
 		path->dentry = dget(mounted->mnt_root);
 		return 1;
@@ -1146,10 +1144,8 @@ static int follow_dotdot_rcu(struct nameidata *nd)
 	set_root_rcu(nd);
 
 	while (1) {
-		if (nd->path.dentry == nd->root.dentry &&
-		    nd->path.mnt == nd->root.mnt) {
+		if (path_equal(&nd->path, &nd->root))
 			break;
-		}
 		if (nd->path.dentry != nd->path.mnt->mnt_root) {
 			struct dentry *old = nd->path.dentry;
 			struct dentry *parent = old->d_parent;
@@ -1214,8 +1210,7 @@ int follow_down(struct path *path)
 			struct vfsmount *mounted = lookup_mnt(path);
 			if (!mounted)
 				break;
-			dput(path->dentry);
-			mntput(path->mnt);
+			path_put(path);
 			path->mnt = mounted;
 			path->dentry = dget(mounted->mnt_root);
 			continue;
@@ -1236,8 +1231,7 @@ static void follow_mount(struct path *path)
 		struct vfsmount *mounted = lookup_mnt(path);
 		if (!mounted)
 			break;
-		dput(path->dentry);
-		mntput(path->mnt);
+		path_put(path);
 		path->mnt = mounted;
 		path->dentry = dget(mounted->mnt_root);
 	}
@@ -1250,10 +1244,8 @@ static void follow_dotdot(struct nameidata *nd)
 	while(1) {
 		struct dentry *old = nd->path.dentry;
 
-		if (nd->path.dentry == nd->root.dentry &&
-		    nd->path.mnt == nd->root.mnt) {
+		if (path_equal(&nd->path, &nd->root))
 			break;
-		}
 		if (nd->path.dentry != nd->path.mnt->mnt_root) {
 			/* rare case of legitimate dget_parent()... */
 			nd->path.dentry = dget_parent(nd->path.dentry);
-- 
1.8.2.1



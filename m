Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41007 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752691AbdFNPTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:19:19 -0400
Subject: [PATCH 26/27] cpuset: Use fs_context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, Tejun Heo <tj@kernel.org>
Date: Wed, 14 Jun 2017 16:19:10 +0100
Message-ID: <149745355086.10897.9077122129781326197.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the cpuset filesystem use the filesystem context.  This is potentially
tricky as the cpuset fs is almost an alias for the cgroup filesystem, but
with some special parameters.

This can, however, be handled by setting up an appropriate cgroup
filesystem and returning the root directory of that as the root dir of this
one.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Tejun Heo <tj@kernel.org>
---

 kernel/cgroup/cpuset.c |   58 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 45 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index ae643412948a..c25914a4e41a 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -38,7 +38,7 @@
 #include <linux/mm.h>
 #include <linux/memory.h>
 #include <linux/export.h>
-#include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/namei.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
@@ -303,25 +303,57 @@ static DECLARE_WAIT_QUEUE_HEAD(cpuset_attach_wq);
  * users. If someone tries to mount the "cpuset" filesystem, we
  * silently switch it to mount "cgroup" instead
  */
-static struct dentry *cpuset_mount(struct file_system_type *fs_type,
-			 int flags, const char *unused_dev_name, void *data)
+static int cpuset_get_tree(struct fs_context *fc)
 {
-	struct file_system_type *cgroup_fs = get_fs_type("cgroup");
-	struct dentry *ret = ERR_PTR(-ENODEV);
+	struct file_system_type *cgroup_fs;
+	struct fs_context *cg_fc;
+	int ret = -ENODEV;
+
+	cgroup_fs = get_fs_type("cgroup");
 	if (cgroup_fs) {
-		char mountopts[] =
-			"cpuset,noprefix,"
-			"release_agent=/sbin/cpuset_release_agent";
-		ret = cgroup_fs->mount(cgroup_fs, flags,
-					   unused_dev_name, mountopts);
-		put_filesystem(cgroup_fs);
+		ret = PTR_ERR(cgroup_fs);
+		goto out;
+	}
+
+	cg_fc = vfs_new_fs_context(cgroup_fs, NULL, 0, FS_CONTEXT_FOR_NEW);
+	put_filesystem(cgroup_fs);
+	if (IS_ERR(cg_fc)) {
+		ret = PTR_ERR(cg_fc);
+		goto out;
 	}
+
+	ret = generic_monolithic_mount_data(
+		fc, "cpuset,noprefix,release_agent=/sbin/cpuset_release_agent");
+	if (ret < 0)
+		goto out_fc;
+
+	ret = vfs_get_tree(cg_fc);
+	if (ret < 0)
+		goto out_fc;
+
+	fc->root = dget(cg_fc->root);
+	ret = 0;
+
+out_fc:
+	put_fs_context(cg_fc);
+out:
 	return ret;
 }
 
+static const struct fs_context_operations cpuset_fs_context_ops = {
+	.get_tree	= cpuset_get_tree,
+};
+
+static int cpuset_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	fc->ops = &cpuset_fs_context_ops;
+	return 0;
+}
+
 static struct file_system_type cpuset_fs_type = {
-	.name = "cpuset",
-	.mount = cpuset_mount,
+	.name			= "cpuset",
+	.fs_context_size	= sizeof(struct fs_context),
+	.init_fs_context	= cpuset_init_fs_context,
 };
 
 /*


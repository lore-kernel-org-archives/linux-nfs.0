Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752376AbdFNWbl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 18:31:41 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk>
References: <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org,
        fenghua.yu@intel.com
Subject: Re: [PATCH 27/27] ... and the intel_rdt driver
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 14 Jun 2017 23:31:36 +0100
Message-ID: <10464.1497479496@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also needs the attached addition to fix the intel_rdt driver.

David
---
diff --git a/arch/x86/kernel/cpu/intel_rdt_rdtgroup.c b/arch/x86/kernel/cpu/intel_rdt_rdtgroup.c
index f5af0cc7eb0d..d026701894fd 100644
--- a/arch/x86/kernel/cpu/intel_rdt_rdtgroup.c
+++ b/arch/x86/kernel/cpu/intel_rdt_rdtgroup.c
@@ -35,6 +35,11 @@
 #include <asm/intel_rdt.h>
 #include <asm/intel_rdt_common.h>
 
+struct rdt_fs_context {
+	struct kernfs_fs_context kfc;
+	bool	enable_cdp;
+};
+
 DEFINE_STATIC_KEY_FALSE(rdt_enable_key);
 struct kernfs_root *rdt_root;
 struct rdtgroup rdtgroup_default;
@@ -743,22 +748,6 @@ static void cdp_disable(void)
 	}
 }
 
-static int parse_rdtgroupfs_options(char *data)
-{
-	char *token, *o = data;
-	int ret = 0;
-
-	while ((token = strsep(&o, ",")) != NULL) {
-		if (!*token)
-			return -EINVAL;
-
-		if (!strcmp(token, "cdp"))
-			ret = cdp_enable();
-	}
-
-	return ret;
-}
-
 /*
  * We don't allow rdtgroup directories to be created anywhere
  * except the root directory. Thus when looking for the rdtgroup
@@ -823,11 +812,9 @@ void rdtgroup_kn_unlock(struct kernfs_node *kn)
 	}
 }
 
-static struct dentry *rdt_mount(struct file_system_type *fs_type,
-				int flags, const char *unused_dev_name,
-				void *data)
+static int rdt_get_tree(struct fs_context *fc)
 {
-	struct dentry *dentry;
+	struct rdt_fs_context *ctx = container_of(fc, struct rdt_fs_context, kfc.fc);
 	int ret;
 
 	mutex_lock(&rdtgroup_mutex);
@@ -835,27 +822,25 @@ static struct dentry *rdt_mount(struct file_system_type *fs_type,
 	 * resctrl file system can only be mounted once.
 	 */
 	if (static_branch_unlikely(&rdt_enable_key)) {
-		dentry = ERR_PTR(-EBUSY);
+		errorf("intel_rdt: Can only mount once");
+		ret = -EBUSY;
 		goto out;
 	}
 
-	ret = parse_rdtgroupfs_options(data);
-	if (ret) {
-		dentry = ERR_PTR(ret);
-		goto out_cdp;
+	if (ctx->enable_cdp) {
+		ret = cdp_enable();
+		if (ret < 0)
+			goto out_cdp;
 	}
 
 	closid_init();
 
 	ret = rdtgroup_create_info_dir(rdtgroup_default.kn);
-	if (ret) {
-		dentry = ERR_PTR(ret);
+	if (ret < 0)
 		goto out_cdp;
-	}
 
-	dentry = kernfs_mount(fs_type, flags, rdt_root,
-			      RDTGROUP_SUPER_MAGIC, NULL);
-	if (IS_ERR(dentry))
+	ret = kernfs_get_tree(&ctx->kfc);
+	if (ret < 0)
 		goto out_cdp;
 
 	static_branch_enable(&rdt_enable_key);
@@ -865,8 +850,42 @@ static struct dentry *rdt_mount(struct file_system_type *fs_type,
 	cdp_disable();
 out:
 	mutex_unlock(&rdtgroup_mutex);
+	return ret;
+}
+
+static int rdt_parse_option(struct fs_context *fc, char *p)
+{
+	struct rdt_fs_context *ctx = container_of(fc, struct rdt_fs_context, kfc.fc);
 
-	return dentry;
+	if (strcmp(p, "cdp") == 0) {
+		ctx->enable_cdp = true;
+		return 0;
+	}
+
+	return invalf("intel_rdt: Unknown option");
+}
+
+static void rdt_fs_context_free(struct fs_context *fc)
+{
+	struct rdt_fs_context *ctx = container_of(fc, struct rdt_fs_context, kfc.fc);
+
+	kernfs_free_fs_context(&ctx->kfc);
+}
+
+static const struct fs_context_operations rdt_fs_context_ops = {
+	.free		= rdt_fs_context_free,
+	.parse_option	= rdt_parse_option,
+	.get_tree	= rdt_get_tree,
+};
+
+static int rdt_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct rdt_fs_context *ctx = container_of(fc, struct rdt_fs_context, kfc.fc);
+
+	ctx->kfc.root = rdt_root;
+	ctx->kfc.magic = RDTGROUP_SUPER_MAGIC;
+	ctx->kfc.fc.ops = &rdt_fs_context_ops;
+	return 0;
 }
 
 static int reset_all_ctrls(struct rdt_resource *r)
@@ -994,9 +1013,10 @@ static void rdt_kill_sb(struct super_block *sb)
 }
 
 static struct file_system_type rdt_fs_type = {
-	.name    = "resctrl",
-	.mount   = rdt_mount,
-	.kill_sb = rdt_kill_sb,
+	.name			= "resctrl",
+	.fs_context_size	= sizeof(struct rdt_fs_context),
+	.init_fs_context	= rdt_init_fs_context,
+	.kill_sb		= rdt_kill_sb,
 };
 
 static int rdtgroup_mkdir(struct kernfs_node *parent_kn, const char *name,

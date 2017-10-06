Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35356 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751487AbdJFPux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Oct 2017 11:50:53 -0400
Subject: [PATCH 13/14] hugetlbfs: Convert to fs_context [ver #6]
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Fri, 06 Oct 2017 16:50:50 +0100
Message-ID: <150730505065.6182.4712100306323295989.stgit@warthog.procyon.org.uk>
In-Reply-To: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert the hugetlbfs to use the fs_context during mount.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/hugetlbfs/inode.c |  327 ++++++++++++++++++++++++++++----------------------
 1 file changed, 184 insertions(+), 143 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 59073e9f01a4..56bb851f0641 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -45,11 +45,18 @@ const struct file_operations hugetlbfs_file_operations;
 static const struct inode_operations hugetlbfs_dir_inode_operations;
 static const struct inode_operations hugetlbfs_inode_operations;
 
-struct hugetlbfs_config {
+enum hugetlbfs_size_type { NO_SIZE, SIZE_STD, SIZE_PERCENT };
+
+struct hugetlbfs_fs_context {
+	struct fs_context	fc;
 	struct hstate		*hstate;
+	unsigned long long	max_size_opt;
+	unsigned long long	min_size_opt;
 	long			max_hpages;
 	long			nr_inodes;
 	long			min_hpages;
+	enum hugetlbfs_size_type max_val_type;
+	enum hugetlbfs_size_type min_val_type;
 	kuid_t			uid;
 	kgid_t			gid;
 	umode_t			mode;
@@ -682,16 +689,16 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 }
 
 static struct inode *hugetlbfs_get_root(struct super_block *sb,
-					struct hugetlbfs_config *config)
+					struct hugetlbfs_fs_context *ctx)
 {
 	struct inode *inode;
 
 	inode = new_inode(sb);
 	if (inode) {
 		inode->i_ino = get_next_ino();
-		inode->i_mode = S_IFDIR | config->mode;
-		inode->i_uid = config->uid;
-		inode->i_gid = config->gid;
+		inode->i_mode = S_IFDIR | ctx->mode;
+		inode->i_uid = ctx->uid;
+		inode->i_gid = ctx->gid;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = current_time(inode);
 		inode->i_op = &hugetlbfs_dir_inode_operations;
 		inode->i_fop = &simple_dir_operations;
@@ -1049,8 +1056,6 @@ static const struct super_operations hugetlbfs_ops = {
 	.show_options	= hugetlbfs_show_options,
 };
 
-enum hugetlbfs_size_type { NO_SIZE, SIZE_STD, SIZE_PERCENT };
-
 /*
  * Convert size option passed from command line to number of huge pages
  * in the pool specified by hstate.  Size option could be in bytes
@@ -1073,170 +1078,156 @@ hugetlbfs_size_to_hpages(struct hstate *h, unsigned long long size_opt,
 	return size_opt;
 }
 
-static int
-hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
+/*
+ * Parse one mount option.
+ */
+static int hugetlbfs_parse_option(struct fs_context *fc, char *p)
 {
-	char *p, *rest;
+	struct hugetlbfs_fs_context *ctx = container_of(fc, struct hugetlbfs_fs_context, fc);
+	char *rest;
+	unsigned long ps;
 	substring_t args[MAX_OPT_ARGS];
-	int option;
-	unsigned long long max_size_opt = 0, min_size_opt = 0;
-	enum hugetlbfs_size_type max_val_type = NO_SIZE, min_val_type = NO_SIZE;
-
-	if (!options)
+	int token, option;
+
+	token = match_token(p, tokens, args);
+	switch (token) {
+	case Opt_uid:
+		if (match_int(&args[0], &option))
+			goto bad_val;
+		ctx->uid = make_kuid(current_user_ns(), option);
+		if (!uid_valid(ctx->uid))
+			goto bad_val;
 		return 0;
 
-	while ((p = strsep(&options, ",")) != NULL) {
-		int token;
-		if (!*p)
-			continue;
+	case Opt_gid:
+		if (match_int(&args[0], &option))
+			goto bad_val;
+		ctx->gid = make_kgid(current_user_ns(), option);
+		if (!gid_valid(ctx->gid))
+			goto bad_val;
+		return 0;
 
-		token = match_token(p, tokens, args);
-		switch (token) {
-		case Opt_uid:
-			if (match_int(&args[0], &option))
- 				goto bad_val;
-			pconfig->uid = make_kuid(current_user_ns(), option);
-			if (!uid_valid(pconfig->uid))
-				goto bad_val;
-			break;
+	case Opt_mode:
+		if (match_octal(&args[0], &option))
+			goto bad_val;
+		ctx->mode = option & 01777U;
+		return 0;
 
-		case Opt_gid:
-			if (match_int(&args[0], &option))
- 				goto bad_val;
-			pconfig->gid = make_kgid(current_user_ns(), option);
-			if (!gid_valid(pconfig->gid))
-				goto bad_val;
-			break;
+	case Opt_size:
+		/* memparse() will accept a K/M/G without a digit */
+		if (!isdigit(*args[0].from))
+			goto bad_val;
+		ctx->max_size_opt = memparse(args[0].from, &rest);
+		ctx->max_val_type = SIZE_STD;
+		if (*rest == '%')
+			ctx->max_val_type = SIZE_PERCENT;
+		return 0;
 
-		case Opt_mode:
-			if (match_octal(&args[0], &option))
- 				goto bad_val;
-			pconfig->mode = option & 01777U;
-			break;
+	case Opt_nr_inodes:
+		/* memparse() will accept a K/M/G without a digit */
+		if (!isdigit(*args[0].from))
+			goto bad_val;
+		ctx->nr_inodes = memparse(args[0].from, &rest);
+		return 0;
 
-		case Opt_size: {
-			/* memparse() will accept a K/M/G without a digit */
-			if (!isdigit(*args[0].from))
-				goto bad_val;
-			max_size_opt = memparse(args[0].from, &rest);
-			max_val_type = SIZE_STD;
-			if (*rest == '%')
-				max_val_type = SIZE_PERCENT;
-			break;
+	case Opt_pagesize:
+		ps = memparse(args[0].from, &rest);
+		ctx->hstate = size_to_hstate(ps);
+		if (!ctx->hstate) {
+			pr_err("Unsupported page size %lu MB\n", ps >> 20);
+			return -EINVAL;
 		}
+		return 0;
 
-		case Opt_nr_inodes:
-			/* memparse() will accept a K/M/G without a digit */
-			if (!isdigit(*args[0].from))
-				goto bad_val;
-			pconfig->nr_inodes = memparse(args[0].from, &rest);
-			break;
+	case Opt_min_size:
+		/* memparse() will accept a K/M/G without a digit */
+		if (!isdigit(*args[0].from))
+			goto bad_val;
+		ctx->min_size_opt = memparse(args[0].from, &rest);
+		ctx->min_val_type = SIZE_STD;
+		if (*rest == '%')
+			ctx->min_val_type = SIZE_PERCENT;
+		return 0;
 
-		case Opt_pagesize: {
-			unsigned long ps;
-			ps = memparse(args[0].from, &rest);
-			pconfig->hstate = size_to_hstate(ps);
-			if (!pconfig->hstate) {
-				pr_err("Unsupported page size %lu MB\n",
-					ps >> 20);
-				return -EINVAL;
-			}
-			break;
-		}
+	default:
+		pr_err("Bad mount option: \"%s\"\n", p);
+		return -EINVAL;
+	}
 
-		case Opt_min_size: {
-			/* memparse() will accept a K/M/G without a digit */
-			if (!isdigit(*args[0].from))
-				goto bad_val;
-			min_size_opt = memparse(args[0].from, &rest);
-			min_val_type = SIZE_STD;
-			if (*rest == '%')
-				min_val_type = SIZE_PERCENT;
-			break;
-		}
+bad_val:
+	pr_err("Bad value '%s' for mount option '%s'\n", args[0].from, p);
+	return -EINVAL;
+}
 
-		default:
-			pr_err("Bad mount option: \"%s\"\n", p);
-			return -EINVAL;
-			break;
-		}
-	}
+/*
+ * Validate the parsed options.
+ */
+static int hugetlbfs_validate(struct fs_context *fc)
+{
+	struct hugetlbfs_fs_context *ctx = container_of(fc, struct hugetlbfs_fs_context, fc);
 
 	/*
 	 * Use huge page pool size (in hstate) to convert the size
 	 * options to number of huge pages.  If NO_SIZE, -1 is returned.
 	 */
-	pconfig->max_hpages = hugetlbfs_size_to_hpages(pconfig->hstate,
-						max_size_opt, max_val_type);
-	pconfig->min_hpages = hugetlbfs_size_to_hpages(pconfig->hstate,
-						min_size_opt, min_val_type);
+	ctx->max_hpages = hugetlbfs_size_to_hpages(ctx->hstate,
+						   ctx->max_size_opt,
+						   ctx->max_val_type);
+	ctx->min_hpages = hugetlbfs_size_to_hpages(ctx->hstate,
+						   ctx->min_size_opt,
+						   ctx->min_val_type);
 
 	/*
 	 * If max_size was specified, then min_size must be smaller
 	 */
-	if (max_val_type > NO_SIZE &&
-	    pconfig->min_hpages > pconfig->max_hpages) {
-		pr_err("minimum size can not be greater than maximum size\n");
+	if (ctx->max_val_type > NO_SIZE &&
+	    ctx->min_hpages > ctx->max_hpages) {
+		pr_err("Minimum size can not be greater than maximum size\n");
 		return -EINVAL;
 	}
 
 	return 0;
-
-bad_val:
-	pr_err("Bad value '%s' for mount option '%s'\n", args[0].from, p);
- 	return -EINVAL;
 }
 
 static int
-hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
+hugetlbfs_fill_super(struct super_block *sb, struct fs_context *fc)
 {
-	int ret;
-	struct hugetlbfs_config config;
+	struct hugetlbfs_fs_context *ctx =
+		container_of(fc, struct hugetlbfs_fs_context, fc);
 	struct hugetlbfs_sb_info *sbinfo;
 
-	config.max_hpages = -1; /* No limit on size by default */
-	config.nr_inodes = -1; /* No limit on number of inodes by default */
-	config.uid = current_fsuid();
-	config.gid = current_fsgid();
-	config.mode = 0755;
-	config.hstate = &default_hstate;
-	config.min_hpages = -1; /* No default minimum size */
-	ret = hugetlbfs_parse_options(data, &config);
-	if (ret)
-		return ret;
-
 	sbinfo = kmalloc(sizeof(struct hugetlbfs_sb_info), GFP_KERNEL);
 	if (!sbinfo)
 		return -ENOMEM;
 	sb->s_fs_info = sbinfo;
-	sbinfo->hstate = config.hstate;
 	spin_lock_init(&sbinfo->stat_lock);
-	sbinfo->max_inodes = config.nr_inodes;
-	sbinfo->free_inodes = config.nr_inodes;
-	sbinfo->spool = NULL;
-	sbinfo->uid = config.uid;
-	sbinfo->gid = config.gid;
-	sbinfo->mode = config.mode;
+	sbinfo->hstate		= ctx->hstate;
+	sbinfo->max_inodes	= ctx->nr_inodes;
+	sbinfo->free_inodes	= ctx->nr_inodes;
+	sbinfo->spool		= NULL;
+	sbinfo->uid		= ctx->uid;
+	sbinfo->gid		= ctx->gid;
+	sbinfo->mode		= ctx->mode;
 
 	/*
 	 * Allocate and initialize subpool if maximum or minimum size is
 	 * specified.  Any needed reservations (for minimim size) are taken
 	 * taken when the subpool is created.
 	 */
-	if (config.max_hpages != -1 || config.min_hpages != -1) {
-		sbinfo->spool = hugepage_new_subpool(config.hstate,
-							config.max_hpages,
-							config.min_hpages);
+	if (ctx->max_hpages != -1 || ctx->min_hpages != -1) {
+		sbinfo->spool = hugepage_new_subpool(ctx->hstate,
+						     ctx->max_hpages,
+						     ctx->min_hpages);
 		if (!sbinfo->spool)
 			goto out_free;
 	}
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = huge_page_size(config.hstate);
-	sb->s_blocksize_bits = huge_page_shift(config.hstate);
+	sb->s_blocksize = huge_page_size(ctx->hstate);
+	sb->s_blocksize_bits = huge_page_shift(ctx->hstate);
 	sb->s_magic = HUGETLBFS_MAGIC;
 	sb->s_op = &hugetlbfs_ops;
 	sb->s_time_gran = 1;
-	sb->s_root = d_make_root(hugetlbfs_get_root(sb, &config));
+	sb->s_root = d_make_root(hugetlbfs_get_root(sb, ctx));
 	if (!sb->s_root)
 		goto out_free;
 	return 0;
@@ -1246,16 +1237,39 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
 	return -ENOMEM;
 }
 
-static struct dentry *hugetlbfs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int hugetlbfs_get_tree(struct fs_context *fc)
 {
-	return mount_nodev(fs_type, flags, data, hugetlbfs_fill_super);
+	return vfs_get_super(fc, vfs_get_independent_super, hugetlbfs_fill_super);
+}
+
+static const struct fs_context_operations hugetlbfs_fs_context_ops = {
+	.parse_option	= hugetlbfs_parse_option,
+	.validate	= hugetlbfs_validate,
+	.get_tree	= hugetlbfs_get_tree,
+};
+
+static int hugetlbfs_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct hugetlbfs_fs_context *ctx = container_of(fc, struct hugetlbfs_fs_context, fc);
+
+	ctx->max_hpages	= -1; /* No limit on size by default */
+	ctx->nr_inodes	= -1; /* No limit on number of inodes by default */
+	ctx->uid	= current_fsuid();
+	ctx->gid	= current_fsgid();
+	ctx->mode	= 0755;
+	ctx->hstate	= &default_hstate;
+	ctx->min_hpages	= -1; /* No default minimum size */
+	ctx->max_val_type = NO_SIZE;
+	ctx->min_val_type = NO_SIZE;
+	ctx->fc.ops	= &hugetlbfs_fs_context_ops;
+	return 0;
 }
 
 static struct file_system_type hugetlbfs_fs_type = {
-	.name		= "hugetlbfs",
-	.mount		= hugetlbfs_mount,
-	.kill_sb	= kill_litter_super,
+	.name			= "hugetlbfs",
+	.fs_context_size	= sizeof(struct hugetlbfs_fs_context),
+	.init_fs_context	= hugetlbfs_init_fs_context,
+	.kill_sb		= kill_litter_super,
 };
 
 static struct vfsmount *hugetlbfs_vfsmount[HUGE_MAX_HSTATE];
@@ -1362,8 +1376,47 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
 	return file;
 }
 
+static struct vfsmount *__init mount_one_hugetlbfs(struct hstate *h)
+{
+	struct hugetlbfs_fs_context *ctx;
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	int ret;
+
+	fc = vfs_new_fs_context(&hugetlbfs_fs_type, NULL, 0,
+				FS_CONTEXT_FOR_KERNEL_MOUNT);
+	if (IS_ERR(fc)) {
+		ret = PTR_ERR(fc);
+		goto err;
+	}
+
+	ctx = container_of(fc, struct hugetlbfs_fs_context, fc);
+	ctx->hstate = h;
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto err_fc;
+
+	mnt = vfs_create_mount(fc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto err_fc;
+	}
+
+	put_fs_context(fc);
+	return mnt;
+
+err_fc:
+	put_fs_context(fc);
+err:
+	pr_err("Cannot mount internal hugetlbfs for page size %uK",
+	       1U << (h->order + PAGE_SHIFT - 10));
+	return ERR_PTR(ret);
+}
+
 static int __init init_hugetlbfs_fs(void)
 {
+	struct vfsmount *mnt;
 	struct hstate *h;
 	int error;
 	int i;
@@ -1386,24 +1439,12 @@ static int __init init_hugetlbfs_fs(void)
 
 	i = 0;
 	for_each_hstate(h) {
-		char buf[50];
-		unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
-
-		snprintf(buf, sizeof(buf), "pagesize=%uK", ps_kb);
-		hugetlbfs_vfsmount[i] = kern_mount_data(&hugetlbfs_fs_type,
-							buf);
-
-		if (IS_ERR(hugetlbfs_vfsmount[i])) {
-			pr_err("Cannot mount internal hugetlbfs for "
-				"page size %uK", ps_kb);
-			error = PTR_ERR(hugetlbfs_vfsmount[i]);
-			hugetlbfs_vfsmount[i] = NULL;
-		}
+		mnt = mount_one_hugetlbfs(h);
+		if (IS_ERR(mnt) && i == 0)
+			goto out;
+		hugetlbfs_vfsmount[i] = mnt;
 		i++;
 	}
-	/* Non default hstates are optional */
-	if (!IS_ERR_OR_NULL(hugetlbfs_vfsmount[default_hstate_idx]))
-		return 0;
 
  out:
 	kmem_cache_destroy(hugetlbfs_inode_cachep);


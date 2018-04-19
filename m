Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43454 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751903AbeDSNeA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:34:00 -0400
Subject: [PATCH 24/24] afs: Use fs_context to pass parameters over automount
 [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, "Eric W. Biederman" <ebiederm@redhat.com>,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:58 +0100
Message-ID: <152414483809.23902.8889932949488546742.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Alter the AFS automounting code to create and modify an fs_context struct
when parameterising a new mount triggered by an AFS mountpoint rather than
constructing device name and option strings.

Also remove the cell=, vol= and rwpath options as they are then redundant.
The reason they existed is because the 'device name' may be derived
literally from a mountpoint object in the filesystem, so default cell and
parent-type information needed to be passed in by some other method from
the automount routines.  The vol= option didn't end up being used.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Eric W. Biederman <ebiederm@redhat.com>
---

 fs/afs/internal.h |    1 
 fs/afs/mntpt.c    |  152 ++++++++++++++++++++++++++++-------------------------
 fs/afs/super.c    |   42 +--------------
 3 files changed, 83 insertions(+), 112 deletions(-)

diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index a5161c0ae3ab..589e5356c560 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -37,7 +37,6 @@ struct afs_call;
 struct afs_fs_context {
 	struct fs_context	fc;
 	struct afs_super_info	*as;
-	bool			rwpath;		/* T if the parent should be considered R/W */
 	bool			force;		/* T to force cell type */
 	bool			autocell;	/* T if set auto mount operation */
 	bool			dyn_root;	/* T if dynamic root */
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index c45aa1776591..9c4ad0565154 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -47,6 +47,8 @@ static DECLARE_DELAYED_WORK(afs_mntpt_expiry_timer, afs_mntpt_expiry_timed_out);
 
 static unsigned long afs_mntpt_expiry_timeout = 10 * 60;
 
+static const char afs_root_volume[] = "root.cell";
+
 /*
  * no valid lookup procedure on this sort of dir
  */
@@ -68,107 +70,111 @@ static int afs_mntpt_open(struct inode *inode, struct file *file)
 }
 
 /*
- * create a vfsmount to be automounted
+ * Set the parameters for the proposed superblock.
  */
-static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
+static int afs_mntpt_set_params(struct fs_context *fc, struct dentry *mntpt)
 {
-	struct afs_super_info *as;
-	struct vfsmount *mnt;
-	struct afs_vnode *vnode;
-	struct page *page;
-	char *devname, *options;
-	bool rwpath = false;
+	struct afs_fs_context *ctx = container_of(fc, struct afs_fs_context, fc);
+	struct afs_vnode *vnode = AFS_FS_I(d_inode(mntpt));
+	struct afs_cell *cell;
+	const char *p;
 	int ret;
 
-	_enter("{%pd}", mntpt);
-
-	BUG_ON(!d_inode(mntpt));
-
-	ret = -ENOMEM;
-	devname = (char *) get_zeroed_page(GFP_KERNEL);
-	if (!devname)
-		goto error_no_devname;
-
-	options = (char *) get_zeroed_page(GFP_KERNEL);
-	if (!options)
-		goto error_no_options;
-
-	vnode = AFS_FS_I(d_inode(mntpt));
 	if (test_bit(AFS_VNODE_PSEUDODIR, &vnode->flags)) {
 		/* if the directory is a pseudo directory, use the d_name */
-		static const char afs_root_cell[] = ":root.cell.";
 		unsigned size = mntpt->d_name.len;
 
-		ret = -ENOENT;
-		if (size < 2 || size > AFS_MAXCELLNAME)
-			goto error_no_page;
+		if (size < 2)
+			return -ENOENT;
 
+		p = mntpt->d_name.name;
 		if (mntpt->d_name.name[0] == '.') {
-			devname[0] = '%';
-			memcpy(devname + 1, mntpt->d_name.name + 1, size - 1);
-			memcpy(devname + size, afs_root_cell,
-			       sizeof(afs_root_cell));
-			rwpath = true;
-		} else {
-			devname[0] = '#';
-			memcpy(devname + 1, mntpt->d_name.name, size);
-			memcpy(devname + size + 1, afs_root_cell,
-			       sizeof(afs_root_cell));
+			size--;
+			p++;
+			ctx->type = AFSVL_RWVOL;
+			ctx->force = true;
+		}
+		if (size > AFS_MAXCELLNAME)
+			return -ENAMETOOLONG;
+
+		cell = afs_lookup_cell(ctx->net, p, size, NULL, false);
+		if (IS_ERR(cell)) {
+			pr_err("kAFS: unable to lookup cell '%pd'\n", mntpt);
+			return PTR_ERR(cell);
 		}
+		afs_put_cell(ctx->net, ctx->cell);
+		ctx->cell = cell;
+
+		ctx->volname = afs_root_volume;
+		ctx->volnamesz = sizeof(afs_root_volume) - 1;
 	} else {
 		/* read the contents of the AFS special symlink */
+		struct page *page;
 		loff_t size = i_size_read(d_inode(mntpt));
 		char *buf;
 
-		ret = -EINVAL;
 		if (size > PAGE_SIZE - 1)
-			goto error_no_page;
+			return -EINVAL;
 
 		page = read_mapping_page(d_inode(mntpt)->i_mapping, 0, NULL);
-		if (IS_ERR(page)) {
-			ret = PTR_ERR(page);
-			goto error_no_page;
-		}
+		if (IS_ERR(page))
+			return PTR_ERR(page);
 
-		ret = -EIO;
-		if (PageError(page))
-			goto error;
+		if (PageError(page)) {
+			put_page(page);
+			return -EIO;
+		}
 
-		buf = kmap_atomic(page);
-		memcpy(devname, buf, size);
-		kunmap_atomic(buf);
+		buf = kmap(page);
+		ctx->fc.source = kmemdup_nul(buf, size, GFP_KERNEL);
+		kunmap(page);
 		put_page(page);
-		page = NULL;
-	}
+		if (!ctx->fc.source)
+			return -ENOMEM;
 
-	/* work out what options we want */
-	as = AFS_FS_S(mntpt->d_sb);
-	if (as->cell) {
-		memcpy(options, "cell=", 5);
-		strcpy(options + 5, as->cell->name);
-		if ((as->volume && as->volume->type == AFSVL_RWVOL) || rwpath)
-			strcat(options, ",rwpath");
+		ret = ctx->fc.ops->parse_source(fc);
+		if (ret < 0)
+			return ret;
 	}
 
-	/* try and do the mount */
-	_debug("--- attempting mount %s -o %s ---", devname, options);
-	mnt = vfs_submount(mntpt, &afs_fs_type, devname,
-			   options, strlen(options) + 1);
-	_debug("--- mount result %p ---", mnt);
+	return 0;
+}
+
+/*
+ * create a vfsmount to be automounted
+ */
+static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
+{
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	int ret;
+
+	BUG_ON(!d_inode(mntpt));
+
+	fc = vfs_new_fs_context(&afs_fs_type, mntpt->d_sb, 0,
+				FS_CONTEXT_FOR_SUBMOUNT);
+	if (IS_ERR(fc))
+		return ERR_CAST(fc);
+
+	ret = afs_mntpt_set_params(fc, mntpt);
+	if (ret < 0)
+		goto error_fc;
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto error_fc;
+
+	mnt = vfs_create_mount(fc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto error_fc;
+	}
 
-	free_page((unsigned long) devname);
-	free_page((unsigned long) options);
-	_leave(" = %p", mnt);
+	put_fs_context(fc);
 	return mnt;
 
-error:
-	put_page(page);
-error_no_page:
-	free_page((unsigned long) options);
-error_no_options:
-	free_page((unsigned long) devname);
-error_no_devname:
-	_leave(" = %d", ret);
+error_fc:
+	put_fs_context(fc);
 	return ERR_PTR(ret);
 }
 
diff --git a/fs/afs/super.c b/fs/afs/super.c
index f56070a9c606..5f9d225e32d9 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -65,18 +65,12 @@ static atomic_t afs_count_active_inodes;
 
 enum {
 	afs_no_opt,
-	afs_opt_cell,
 	afs_opt_dyn,
-	afs_opt_rwpath,
-	afs_opt_vol,
 	afs_opt_autocell,
 };
 
 static const match_table_t afs_options_list = {
-	{ afs_opt_cell,		"cell=%s"	},
 	{ afs_opt_dyn,		"dyn"		},
-	{ afs_opt_rwpath,	"rwpath"	},
-	{ afs_opt_vol,		"vol=%s"	},
 	{ afs_opt_autocell,	"autocell"	},
 	{ afs_no_opt,		NULL		},
 };
@@ -195,37 +189,13 @@ static int afs_show_options(struct seq_file *m, struct dentry *root)
 static int afs_parse_option(struct fs_context *fc, char *opt, size_t len)
 {
 	struct afs_fs_context *ctx = container_of(fc, struct afs_fs_context, fc);
-	struct afs_cell *cell;
 	substring_t args[MAX_OPT_ARGS];
-	int token, size;
+	int token;
 
 	_enter("%s", opt);
 
 	token = match_token(opt, afs_options_list, args);
 	switch (token) {
-	case afs_opt_cell:
-		size = args[0].to - args[0].from;
-		if (size <= 0)
-			return -EINVAL;
-		if (size > AFS_MAXCELLNAME)
-			return -ENAMETOOLONG;
-
-		rcu_read_lock();
-		cell = afs_lookup_cell_rcu(ctx->net, args[0].from, size);
-		rcu_read_unlock();
-		if (IS_ERR(cell))
-			return PTR_ERR(cell);
-		afs_put_cell(ctx->net, ctx->cell);
-		ctx->cell = cell;
-		break;
-
-	case afs_opt_rwpath:
-		ctx->rwpath = true;
-		break;
-
-	case afs_opt_vol:
-		return -EINVAL; /* Not required for automount */
-
 	case afs_opt_autocell:
 		ctx->autocell = true;
 		break;
@@ -249,8 +219,8 @@ static int afs_parse_option(struct fs_context *fc, char *opt, size_t len)
  *
  * This can be one of the following:
  *	"%[cell:]volume[.]"		R/W volume
- *	"#[cell:]volume[.]"		R/O or R/W volume (rwpath=0),
- *					 or R/W (rwpath=1) volume
+ *	"#[cell:]volume[.]"		R/O or R/W volume (R/O parent),
+ *					 or R/W (R/W parent) volume
  *	"%[cell:]volume.readonly"	R/O volume
  *	"#[cell:]volume.readonly"	R/O volume
  *	"%[cell:]volume.backup"		Backup volume
@@ -281,9 +251,7 @@ static int afs_parse_source(struct fs_context *fc)
 	}
 
 	/* determine the type of volume we're looking for */
-	ctx->type = AFSVL_ROVOL;
-	ctx->force = false;
-	if (ctx->rwpath || name[0] == '%') {
+	if (name[0] == '%') {
 		ctx->type = AFSVL_RWVOL;
 		ctx->force = true;
 	}
@@ -599,8 +567,6 @@ static int afs_init_fs_context(struct fs_context *fc, struct super_block *src_sb
 	struct afs_cell *cell;
 	struct net *net_ns;
 
-	if (current->nsproxy->net_ns != &init_net)
-		return -EINVAL;
 	ctx->type = AFSVL_ROVOL;
 
 	switch (ctx->fc.purpose) {


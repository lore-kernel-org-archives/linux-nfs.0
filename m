From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] 1/2 SELinux: Add get, set,
	and cloning of superblock	security information
Date: Wed, 05 Sep 2007 18:16:03 -0400
Message-ID: <1189030563.3460.41.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, sds@tycho.nsa.gov, steved@redhat.com
To: selinux@tycho.nsa.gov, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IT3Ae-0003AV-0i
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 15:16:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IT3Ah-0007yT-BP
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 15:16:28 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Adds security_get_sb_mnt_opts, security_set_sb_mnt_opts, and
security_clont_sb_mnt_opts to the LSM and to SELinux.  This is in
preparation for NFS to be able to own its own mount options and remove
the NFS specific code from SELinux.

>From the point of view of SELinux NFS does not use text based mount
options so this patch is not something that is going away.  NFS merely
takes the text options from userspace and puts them into the same binary
format as always and passes that binary mount data around.

Signed-off-by: Eric Paris <eparis@redhat.com>

---

 include/linux/security.h          |   70 +++++
 security/dummy.c                  |   26 ++
 security/selinux/hooks.c          |  618 ++++++++++++++++++++++++-------------
 security/selinux/include/objsec.h |    1 +
 4 files changed, 505 insertions(+), 210 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 1a15526..65f2d91 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -34,6 +34,12 @@
 #include <linux/xfrm.h>
 #include <net/flow.h>
 
+/* only a char in selinux superblock security struct flags */
+#define FSCONTEXT_MNT		0x01
+#define CONTEXT_MNT		0x02
+#define ROOTCONTEXT_MNT		0x04
+#define DEFCONTEXT_MNT		0x08
+
 struct ctl_table;
 
 /*
@@ -248,6 +254,22 @@ struct request_sock;
  *	Update module state after a successful pivot.
  *	@old_nd contains the nameidata structure for the old root.
  *      @new_nd contains the nameidata structure for the new root.
+ * @sb_get_mnt_opts:
+ *      Get the security relevant mount options used for a superblock
+ *      @sb the superblock to get security mount options from
+ *      @mount_options array for pointers to mount options
+ *      @mount_flags array of ints specifying what each mount options is
+ *      @num_opts number of options in the arrays
+ * @sb_set_mnt_opts:
+ *      Set the security relevant mount options used for a superblock
+ *      @sb the superblock to set security mount options for
+ *      @mount_options array for pointers to mount options
+ *      @mount_flags array of ints specifying what each mount options is
+ *      @num_opts number of options in the arrays
+ * @sb_clone_mnt_opts:
+ *	Copy all security options from a given superblock to another
+ *	@oldsb old superblock which contain information to clone
+ *	@newsb new superblock which needs filled in
  *
  * Security hooks for inode operations.
  *
@@ -1201,6 +1223,13 @@ struct security_operations {
 			     struct nameidata * new_nd);
 	void (*sb_post_pivotroot) (struct nameidata * old_nd,
 				   struct nameidata * new_nd);
+	int (*sb_get_mnt_opts) (const struct super_block *sb,
+				char ***mount_options, int **flags,
+				int *num_opts);
+	int (*sb_set_mnt_opts) (struct super_block *sb, char **mount_options,
+				int *flags, int num_opts);
+	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
+				   struct super_block *newsb);
 
 	int (*inode_alloc_security) (struct inode *inode);	
 	void (*inode_free_security) (struct inode *inode);
@@ -1594,6 +1623,26 @@ static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
 	security_ops->sb_post_pivotroot (old_nd, new_nd);
 }
 
+static inline int security_sb_get_mnt_opts (const struct super_block *sb,
+					    char ***mount_options,
+					    int **flags, int *num_opts)
+{
+	return security_ops->sb_get_mnt_opts(sb, mount_options, flags, num_opts);
+}
+
+static inline int security_sb_set_mnt_opts (struct super_block *sb,
+					    char **mount_options,
+					    int *flags, int num_opts)
+{
+	return security_ops->sb_set_mnt_opts(sb, mount_options, flags, num_opts);
+}
+
+static inline void security_sb_clone_mnt_opts(const struct super_block *oldsb,
+					      struct super_block *newsb)
+{
+	security_ops->sb_clone_mnt_opts(oldsb, newsb);
+}
+
 static inline int security_inode_alloc (struct inode *inode)
 {
 	inode->i_security = NULL;
@@ -2334,6 +2383,27 @@ static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
 					       struct nameidata *new_nd)
 { }
 
+static inline int security_sb_get_mnt_opts (const struct super_block *sb,
+					    char ***mount_options,
+					    int **flags, int *num_opts)
+{
+	*mount_options = NULL;
+	*flags = NULL;
+	*num_opts = 0;
+	return 0;
+}
+
+static inline int security_sb_set_mnt_opts (struct super_block *sb,
+					    char **mount_options,
+					    int *flags, int num_opts)
+{
+	return 0;
+}
+
+static inline void security_sb_clone_mnt_opts(const struct super_block *oldsb,
+					     struct super_block *newsb)
+{ }
+
 static inline int security_inode_alloc (struct inode *inode)
 {
 	return 0;
diff --git a/security/dummy.c b/security/dummy.c
index 853ec22..c3ac361 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -248,6 +248,29 @@ static void dummy_sb_post_pivotroot (struct nameidata *old_nd, struct nameidata
 	return;
 }
 
+static int dummy_sb_get_mnt_opts(const struct super_block *sb, char ***mount_options,
+				 int **flags, int *num_opts)
+{
+	*mount_options = NULL;
+	*flags = NULL;
+	*num_opts = 0;
+	return 0;
+}
+
+static int dummy_sb_set_mnt_opts(struct super_block *sb, char **mount_options,
+				 int *flags, int num_opts)
+{
+	if (unlikely(num_opts))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static void dummy_sb_clone_mnt_opts(const struct super_block *oldsb,
+				    struct super_block *newsb)
+{
+	return;
+}
+
 static int dummy_inode_alloc_security (struct inode *inode)
 {
 	return 0;
@@ -996,6 +1019,9 @@ void security_fixup_ops (struct security_operations *ops)
 	set_to_dummy_if_null(ops, sb_post_addmount);
 	set_to_dummy_if_null(ops, sb_pivotroot);
 	set_to_dummy_if_null(ops, sb_post_pivotroot);
+	set_to_dummy_if_null(ops, sb_get_mnt_opts);
+	set_to_dummy_if_null(ops, sb_set_mnt_opts);
+	set_to_dummy_if_null(ops, sb_clone_mnt_opts);
 	set_to_dummy_if_null(ops, inode_alloc_security);
 	set_to_dummy_if_null(ops, inode_free_security);
 	set_to_dummy_if_null(ops, inode_init_security);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 3694662..5ebe30b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -362,135 +362,228 @@ static int may_context_mount_inode_relabel(u32 sid,
 	return rc;
 }
 
-static int try_context_mount(struct super_block *sb, void *data)
+static int sb_finish_set_opts(struct super_block *sb)
 {
-	char *context = NULL, *defcontext = NULL;
-	char *fscontext = NULL, *rootcontext = NULL;
-	const char *name;
-	u32 sid;
-	int alloc = 0, rc = 0, seen = 0;
-	struct task_security_struct *tsec = current->security;
 	struct superblock_security_struct *sbsec = sb->s_security;
+	struct dentry *root = sb->s_root;
+	struct inode *root_inode = root->d_inode;
+	int rc = 0;
 
-	if (!data)
-		goto out;
+	BUG_ON(!ss_initialized);
 
-	name = sb->s_type->name;
+	if (sbsec->initialized)
+		return 0;
 
-	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
+	if (sbsec->behavior == SECURITY_FS_USE_XATTR) {
+		/* Make sure that the xattr handler exists and that no
+		   error other than -ENODATA is returned by getxattr on
+		   the root directory.  -ENODATA is ok, as this may be
+		   the first boot of the SELinux kernel before we have
+		   assigned xattr values to the filesystem. */
+		if (!root_inode->i_op->getxattr) {
+			printk(KERN_WARNING "SELinux: (dev %s, type %s) has no "
+			       "xattr support\n", sb->s_id, sb->s_type->name);
+			rc = -EOPNOTSUPP;
+			goto out;
+		}
+		rc = root_inode->i_op->getxattr(root, XATTR_NAME_SELINUX, NULL, 0);
+		if (rc < 0 && rc != -ENODATA) {
+			if (rc == -EOPNOTSUPP)
+				printk(KERN_WARNING "SELinux: (dev %s, type "
+				       "%s) has no security xattr handler\n",
+				       sb->s_id, sb->s_type->name);
+			else
+				printk(KERN_WARNING "SELinux: (dev %s, type "
+				       "%s) getxattr errno %d\n", sb->s_id,
+				       sb->s_type->name, -rc);
+			goto out;
+		}
+	}
 
-		/* NFS we understand. */
-		if (!strcmp(name, "nfs")) {
-			struct nfs_mount_data *d = data;
+	sbsec->initialized = 1;
 
-			if (d->version <  NFS_MOUNT_VERSION)
-				goto out;
+	if (sbsec->behavior > ARRAY_SIZE(labeling_behaviors)) {
+		printk(KERN_ERR "SELinux: initialized (dev %s, type %s), unknown behavior\n",
+		       sb->s_id, sb->s_type->name);
+	}
+	else {
+		printk(KERN_DEBUG "SELinux: initialized (dev %s, type %s), %s\n",
+		       sb->s_id, sb->s_type->name,
+		       labeling_behaviors[sbsec->behavior-1]);
+	}
 
-			if (d->context[0]) {
-				context = d->context;
-				seen |= Opt_context;
-			}
-		} else
-			goto out;
+	/* Initialize the root inode. */
+	rc = inode_doinit_with_dentry(root_inode, root);
 
-	} else {
-		/* Standard string-based options. */
-		char *p, *options = data;
+	/* Initialize any other inodes associated with the superblock, e.g.
+	   inodes created prior to initial policy load or inodes created
+	   during get_sb by a pseudo filesystem that directly
+	   populates itself. */
+	spin_lock(&sbsec->isec_lock);
+next_inode:
+	if (!list_empty(&sbsec->isec_head)) {
+		struct inode_security_struct *isec =
+				list_entry(sbsec->isec_head.next,
+					   struct inode_security_struct, list);
+		struct inode *inode = isec->inode;
+		spin_unlock(&sbsec->isec_lock);
+		inode = igrab(inode);
+		if (inode) {
+			if (!IS_PRIVATE (inode))
+				inode_doinit(inode);
+			iput(inode);
+		}
+		spin_lock(&sbsec->isec_lock);
+		list_del_init(&isec->list);
+		goto next_inode;
+	}
+	spin_unlock(&sbsec->isec_lock);
+out:
+	return rc;
+}
+
+/*
+ * This function should allow an FS (like NFS) to ask what it's mount security
+ * options were so it can use those later for submounts and the like
+ */
+static int selinux_get_mnt_opts(const struct super_block *sb,
+				char ***mount_options, int **mnt_opts_flags,
+				int *num_opts)
+{
+	int rc = 0, i;
+	struct superblock_security_struct *sbsec = sb->s_security;
+	char *context = NULL;
+	u32 len;
+	/* 
+	 * if we ever use sbsec flags for anything other than tracking mount
+	 * settings this is going to need a mask
+	 */
+	char tmp = sbsec->flags; 
+	*num_opts = 0;
+	*mount_options = NULL;
+	*mnt_opts_flags = NULL;
+
+	for(i = 0; i < 8; i++) {
+		if (tmp & 0x01)
+			(*num_opts)++;
+		tmp >>= 1;
+	}
 
-		while ((p = strsep(&options, "|")) != NULL) {
-			int token;
-			substring_t args[MAX_OPT_ARGS];
+	i = 0;
+	*mount_options = kcalloc(*num_opts, sizeof(char *), GFP_ATOMIC);
+	if (!*mount_options) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
 
-			if (!*p)
-				continue;
+	*mnt_opts_flags = kcalloc(*num_opts, sizeof(int), GFP_ATOMIC);
+	if (!*mnt_opts_flags) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
 
-			token = match_token(p, tokens, args);
+	if (sbsec->flags & FSCONTEXT_MNT) {
+		rc = security_sid_to_context(sbsec->sid, &context, &len);
+		if (rc)
+			goto out_free;
+		(*mount_options)[i] = context;
+		(*mnt_opts_flags)[i++] = FSCONTEXT_MNT;
+	}
+	if (sbsec->flags & CONTEXT_MNT) {
+		rc = security_sid_to_context(sbsec->mntpoint_sid, &context, &len);
+		if (rc)
+			goto out_free;
+		(*mount_options)[i] = context;
+		(*mnt_opts_flags)[i++] = CONTEXT_MNT;
+	}
+	if (sbsec->flags & DEFCONTEXT_MNT) {
+		rc = security_sid_to_context(sbsec->def_sid, &context, &len);
+		if (rc)
+			goto out_free;
+		(*mount_options)[i] = context;
+		(*mnt_opts_flags)[i++] = DEFCONTEXT_MNT;
+	}
+	if (sbsec->flags & ROOTCONTEXT_MNT) {
+		rc = security_sid_to_context(sbsec->def_sid, &context, &len);
+		if (rc)
+			goto out_free;
+		(*mount_options)[i] = context;
+		(*mnt_opts_flags)[i++] = ROOTCONTEXT_MNT;
+	}
 
-			switch (token) {
-			case Opt_context:
-				if (seen & (Opt_context|Opt_defcontext)) {
-					rc = -EINVAL;
-					printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
-					goto out_free;
-				}
-				context = match_strdup(&args[0]);
-				if (!context) {
-					rc = -ENOMEM;
-					goto out_free;
-				}
-				if (!alloc)
-					alloc = 1;
-				seen |= Opt_context;
-				break;
+	BUG_ON(i != *num_opts);
 
-			case Opt_fscontext:
-				if (seen & Opt_fscontext) {
-					rc = -EINVAL;
-					printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
-					goto out_free;
-				}
-				fscontext = match_strdup(&args[0]);
-				if (!fscontext) {
-					rc = -ENOMEM;
-					goto out_free;
-				}
-				if (!alloc)
-					alloc = 1;
-				seen |= Opt_fscontext;
-				break;
+	return 0;
 
-			case Opt_rootcontext:
-				if (seen & Opt_rootcontext) {
-					rc = -EINVAL;
-					printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
-					goto out_free;
-				}
-				rootcontext = match_strdup(&args[0]);
-				if (!rootcontext) {
-					rc = -ENOMEM;
-					goto out_free;
-				}
-				if (!alloc)
-					alloc = 1;
-				seen |= Opt_rootcontext;
-				break;
+out_free:
+	/* don't leak context string if security_sid_to_context had an error */
+	if(*mount_options && i)
+		for (; i > 0; i--)
+			kfree((*mount_options)[i-1]);
+	kfree(*mount_options);
+	*mount_options = NULL;
+	kfree(*mnt_opts_flags);
+	*mnt_opts_flags = NULL;
+	*num_opts = 0;
+	return rc;
+}
 
-			case Opt_defcontext:
-				if (sbsec->behavior != SECURITY_FS_USE_XATTR) {
-					rc = -EINVAL;
-					printk(KERN_WARNING "SELinux:  "
-					       "defcontext option is invalid "
-					       "for this filesystem type\n");
-					goto out_free;
-				}
-				if (seen & (Opt_context|Opt_defcontext)) {
-					rc = -EINVAL;
-					printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
-					goto out_free;
-				}
-				defcontext = match_strdup(&args[0]);
-				if (!defcontext) {
-					rc = -ENOMEM;
-					goto out_free;
-				}
-				if (!alloc)
-					alloc = 1;
-				seen |= Opt_defcontext;
-				break;
+/*
+ * Allow filesystems with binary mount data to explicitly set mount point labeling.
+ */
+int selinux_set_mnt_opts(struct super_block *sb, char **mount_options,
+				 int *flags, int num_opts)
+{
+	int rc = 0, i;
+	u32 sid;
+	struct task_security_struct *tsec = current->security;
+	struct superblock_security_struct *sbsec = sb->s_security;
+	char *fscontext = NULL, *context = NULL, *rootcontext= NULL;
+	char *defcontext = NULL;
+	const char *name = sb->s_type->name;
 
-			default:
-				rc = -EINVAL;
-				printk(KERN_WARNING "SELinux:  unknown mount "
-				       "option\n");
-				goto out_free;
+	mutex_lock(&sbsec->lock);
 
-			}
-		}
+	if (sbsec->initialized) {
+		printk(KERN_WARNING "%s: we are here with sbsec->initialized == 1\n",
+			__FUNCTION__);
+		goto out;
 	}
 
-	if (!seen)
+	if (strcmp(sb->s_type->name, "proc") == 0)
+		sbsec->proc = 1;
+
+	/* Determine the labeling behavior to use for this filesystem type. */
+	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
+	if (rc) {
+		printk(KERN_WARNING "%s: security_fs_use(%s) returned %d\n",
+		       __FUNCTION__, sb->s_type->name, rc);
 		goto out;
+	}
 
+	for(i = 0; i < num_opts; i++) {
+		switch(flags[i]) {
+		case FSCONTEXT_MNT:
+			fscontext = mount_options[i];
+			sbsec->flags |= FSCONTEXT_MNT;
+			break;
+		case CONTEXT_MNT:
+			context = mount_options[i];
+			sbsec->flags |= CONTEXT_MNT;
+			break;
+		case ROOTCONTEXT_MNT:
+			rootcontext = mount_options[i];
+			sbsec->flags |= ROOTCONTEXT_MNT;
+			break;
+		case DEFCONTEXT_MNT:
+			defcontext = mount_options[i];
+			sbsec->flags |= DEFCONTEXT_MNT;
+			break;
+		default:
+			rc = -EINVAL;
+			goto out;
+		}
+	}
 	/* sets the context of the superblock for the fs being mounted. */
 	if (fscontext) {
 		rc = security_context_to_sid(fscontext, strlen(fscontext), &sid);
@@ -498,12 +591,12 @@ static int try_context_mount(struct super_block *sb, void *data)
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       fscontext, sb->s_id, name, rc);
-			goto out_free;
+			goto out;
 		}
 
 		rc = may_context_mount_sb_relabel(sid, sbsec, tsec);
 		if (rc)
-			goto out_free;
+			goto out;
 
 		sbsec->sid = sid;
 	}
@@ -519,21 +612,23 @@ static int try_context_mount(struct super_block *sb, void *data)
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       context, sb->s_id, name, rc);
-			goto out_free;
+			goto out;
 		}
 
 		if (!fscontext) {
 			rc = may_context_mount_sb_relabel(sid, sbsec, tsec);
 			if (rc)
-				goto out_free;
+				goto out;
 			sbsec->sid = sid;
 		} else {
 			rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
 			if (rc)
-				goto out_free;
+				goto out;
 		}
-		sbsec->mntpoint_sid = sid;
+		if (!rootcontext)
+			rootcontext = context;
 
+		sbsec->mntpoint_sid = sid;
 		sbsec->behavior = SECURITY_FS_USE_MNTPOINT;
 	}
 
@@ -545,55 +640,234 @@ static int try_context_mount(struct super_block *sb, void *data)
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       rootcontext, sb->s_id, name, rc);
-			goto out_free;
+			goto out;
 		}
 
 		rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
 		if (rc)
-			goto out_free;
+			goto out;
 
 		isec->sid = sid;
 		isec->initialized = 1;
 	}
 
 	if (defcontext) {
+		if (sbsec->behavior != SECURITY_FS_USE_XATTR) {
+			rc = -EINVAL;
+			printk(KERN_WARNING "SELinux: defcontext option is "
+			       "invalid for this filesystem type\n");
+			goto out;
+		}
 		rc = security_context_to_sid(defcontext, strlen(defcontext), &sid);
 		if (rc) {
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       defcontext, sb->s_id, name, rc);
-			goto out_free;
+			goto out;
 		}
 
-		if (sid == sbsec->def_sid)
-			goto out_free;
-
-		rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
-		if (rc)
-			goto out_free;
+		if (sid != sbsec->def_sid) {
+			rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
+			if (rc)
+				goto out;
+		}
 
 		sbsec->def_sid = sid;
 	}
 
-out_free:
-	if (alloc) {
-		kfree(context);
-		kfree(defcontext);
-		kfree(fscontext);
-		kfree(rootcontext);
+	rc = sb_finish_set_opts(sb);
+out:
+	mutex_unlock(&sbsec->lock);
+	return rc;
+}
+
+static void selinux_sb_clone_mnt_opts (const struct super_block *oldsb,
+					struct super_block *newsb)
+{
+	const struct superblock_security_struct *oldsbsec = oldsb->s_security;
+	struct superblock_security_struct *newsbsec = newsb->s_security;
+
+	int set_fscontext =	(oldsbsec->flags & FSCONTEXT_MNT);
+	int set_context =	(oldsbsec->flags & CONTEXT_MNT);
+	int set_rootcontext =	(oldsbsec->flags & ROOTCONTEXT_MNT);
+
+	mutex_lock(&newsbsec->lock);
+
+	newsbsec->flags = oldsbsec->flags;
+
+	newsbsec->sid = oldsbsec->sid;
+	newsbsec->def_sid = oldsbsec->def_sid;
+	newsbsec->behavior = oldsbsec->behavior;
+
+	if (set_context) {
+		u32 sid = oldsbsec->mntpoint_sid;
+
+		if (!set_fscontext)
+			newsbsec->sid = sid;
+		if (!set_rootcontext) {
+			struct inode *newinode = newsb->s_root->d_inode;
+			struct inode_security_struct *newisec = newinode->i_security;
+			newisec->sid = sid;
+		}
+		newsbsec->mntpoint_sid = sid;
+	}
+	if (set_rootcontext) {
+		const struct inode *oldinode = oldsb->s_root->d_inode;
+		const struct inode_security_struct *oldisec = oldinode->i_security;
+		struct inode *newinode = newsb->s_root->d_inode;
+		struct inode_security_struct *newisec = newinode->i_security;
+
+		newisec->sid = oldisec->sid;
 	}
+
+	sb_finish_set_opts(newsb);
+	mutex_unlock(&newsbsec->lock);
+}
+
+/*
+ * string mount options parsing and call to function to set the sbsec
+ */
+static int try_context_mount(struct super_block *sb, void *data)
+{
+	char *context = NULL, *defcontext = NULL;
+	char *fscontext = NULL, *rootcontext = NULL;
+	int rc = 0;
+	char *p, *options = data;
+	/* selinux only know about 4 mount options */
+	char *mnt_opts[4];
+	int mnt_opts_flags[4], num_mnt_opts = 0;
+	int con_from_nfs = 0;
+
+	if (!data)
+		goto out;
+
+	/* with the nfs patch this will become a goto out; */
+	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
+		const char *name = sb->s_type->name;
+		/* NFS we understand. */
+		if (!strcmp(name, "nfs")) {
+			struct nfs_mount_data *d = data;
+
+			if (d->version !=  NFS_MOUNT_VERSION)
+				goto out;
+
+			if (d->context[0])
+				context = d->context;
+			con_from_nfs = 1;
+		} else
+			goto out;
+	} else {
+
+	/* Standard string-based options. */
+	while ((p = strsep(&options, "|")) != NULL) {
+		int token;
+		substring_t args[MAX_OPT_ARGS];
+
+		if (!*p)
+			continue;
+
+		token = match_token(p, tokens, args);
+
+		switch (token) {
+		case Opt_context:
+			if (context || defcontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_err;
+			}
+			context = match_strdup(&args[0]);
+			if (!context) {
+				rc = -ENOMEM;
+				goto out_err;
+			}
+			break;
+
+		case Opt_fscontext:
+			if (fscontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_err;
+			}
+			fscontext = match_strdup(&args[0]);
+			if (!fscontext) {
+				rc = -ENOMEM;
+				goto out_err;
+			}
+			break;
+
+		case Opt_rootcontext:
+			if (rootcontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_err;
+			}
+			rootcontext = match_strdup(&args[0]);
+			if (!rootcontext) {
+				rc = -ENOMEM;
+				goto out_err;
+			}
+			break;
+
+		case Opt_defcontext:
+			if (context || defcontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_err;
+			}
+			defcontext = match_strdup(&args[0]);
+			if (!defcontext) {
+				rc = -ENOMEM;
+				goto out_err;
+			}
+			break;
+
+		default:
+			rc = -EINVAL;
+			printk(KERN_WARNING "SELinux:  unknown mount option\n");
+			goto out_err;
+
+		}
+	}
+	} // else for binary mount data.  delete with nfs patch
+
+	if(fscontext){
+		mnt_opts[num_mnt_opts] = fscontext;
+		mnt_opts_flags[num_mnt_opts++] = FSCONTEXT_MNT;
+	}
+	if(context){
+		mnt_opts[num_mnt_opts] = context;
+		mnt_opts_flags[num_mnt_opts++] = CONTEXT_MNT;
+	}
+	if(rootcontext){
+		mnt_opts[num_mnt_opts] = rootcontext;
+		mnt_opts_flags[num_mnt_opts++] = ROOTCONTEXT_MNT;
+	}
+	if(defcontext){
+		mnt_opts[num_mnt_opts] = defcontext;
+		mnt_opts_flags[num_mnt_opts++] = DEFCONTEXT_MNT;
+	}
+
 out:
+	rc = selinux_set_mnt_opts(sb, mnt_opts, mnt_opts_flags, num_mnt_opts);
+out_err:
+	/* remove conditional when we remove nfs */
+	if (!con_from_nfs)
+		kfree(context);
+	kfree(defcontext);
+	kfree(fscontext);
+	kfree(rootcontext);
 	return rc;
 }
 
+/* 
+ * no locking done here, but it shouldn't matter, sbsec->proc would just get
+ * set the same way in another thread and fs_use, hmmmmmm 
+ */
 static int superblock_doinit(struct super_block *sb, void *data)
 {
 	struct superblock_security_struct *sbsec = sb->s_security;
-	struct dentry *root = sb->s_root;
-	struct inode *inode = root->d_inode;
 	int rc = 0;
 
-	mutex_lock(&sbsec->lock);
 	if (sbsec->initialized)
 		goto out;
 
@@ -608,87 +882,8 @@ static int superblock_doinit(struct super_block *sb, void *data)
 		goto out;
 	}
 
-	/* Determine the labeling behavior to use for this filesystem type. */
-	rc = security_fs_use(sb->s_type->name, &sbsec->behavior, &sbsec->sid);
-	if (rc) {
-		printk(KERN_WARNING "%s:  security_fs_use(%s) returned %d\n",
-		       __FUNCTION__, sb->s_type->name, rc);
-		goto out;
-	}
-
 	rc = try_context_mount(sb, data);
-	if (rc)
-		goto out;
-
-	if (sbsec->behavior == SECURITY_FS_USE_XATTR) {
-		/* Make sure that the xattr handler exists and that no
-		   error other than -ENODATA is returned by getxattr on
-		   the root directory.  -ENODATA is ok, as this may be
-		   the first boot of the SELinux kernel before we have
-		   assigned xattr values to the filesystem. */
-		if (!inode->i_op->getxattr) {
-			printk(KERN_WARNING "SELinux: (dev %s, type %s) has no "
-			       "xattr support\n", sb->s_id, sb->s_type->name);
-			rc = -EOPNOTSUPP;
-			goto out;
-		}
-		rc = inode->i_op->getxattr(root, XATTR_NAME_SELINUX, NULL, 0);
-		if (rc < 0 && rc != -ENODATA) {
-			if (rc == -EOPNOTSUPP)
-				printk(KERN_WARNING "SELinux: (dev %s, type "
-				       "%s) has no security xattr handler\n",
-				       sb->s_id, sb->s_type->name);
-			else
-				printk(KERN_WARNING "SELinux: (dev %s, type "
-				       "%s) getxattr errno %d\n", sb->s_id,
-				       sb->s_type->name, -rc);
-			goto out;
-		}
-	}
-
-	if (strcmp(sb->s_type->name, "proc") == 0)
-		sbsec->proc = 1;
-
-	sbsec->initialized = 1;
-
-	if (sbsec->behavior > ARRAY_SIZE(labeling_behaviors)) {
-		printk(KERN_ERR "SELinux: initialized (dev %s, type %s), unknown behavior\n",
-		       sb->s_id, sb->s_type->name);
-	}
-	else {
-		printk(KERN_DEBUG "SELinux: initialized (dev %s, type %s), %s\n",
-		       sb->s_id, sb->s_type->name,
-		       labeling_behaviors[sbsec->behavior-1]);
-	}
-
-	/* Initialize the root inode. */
-	rc = inode_doinit_with_dentry(sb->s_root->d_inode, sb->s_root);
-
-	/* Initialize any other inodes associated with the superblock, e.g.
-	   inodes created prior to initial policy load or inodes created
-	   during get_sb by a pseudo filesystem that directly
-	   populates itself. */
-	spin_lock(&sbsec->isec_lock);
-next_inode:
-	if (!list_empty(&sbsec->isec_head)) {
-		struct inode_security_struct *isec =
-				list_entry(sbsec->isec_head.next,
-				           struct inode_security_struct, list);
-		struct inode *inode = isec->inode;
-		spin_unlock(&sbsec->isec_lock);
-		inode = igrab(inode);
-		if (inode) {
-			if (!IS_PRIVATE (inode))
-				inode_doinit(inode);
-			iput(inode);
-		}
-		spin_lock(&sbsec->isec_lock);
-		list_del_init(&isec->list);
-		goto next_inode;
-	}
-	spin_unlock(&sbsec->isec_lock);
 out:
-	mutex_unlock(&sbsec->lock);
 	return rc;
 }
 
@@ -4749,6 +4944,9 @@ static struct security_operations selinux_ops = {
 	.sb_statfs =			selinux_sb_statfs,
 	.sb_mount =			selinux_mount,
 	.sb_umount =			selinux_umount,
+	.sb_get_mnt_opts =		selinux_get_mnt_opts,
+	.sb_set_mnt_opts =		selinux_set_mnt_opts,
+	.sb_clone_mnt_opts = 		selinux_sb_clone_mnt_opts,
 
 	.inode_alloc_security =		selinux_inode_alloc_security,
 	.inode_free_security =		selinux_inode_free_security,
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 91b88f0..fc4768e 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -63,6 +63,7 @@ struct superblock_security_struct {
 	u32 mntpoint_sid;		/* SECURITY_FS_USE_MNTPOINT context for files */
 	unsigned int behavior;          /* labeling behavior */
 	unsigned char initialized;      /* initialization flag */
+	unsigned char flags;		/* which mount options were specified */
 	unsigned char proc;             /* proc fs */
 	struct mutex lock;
 	struct list_head isec_head;



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

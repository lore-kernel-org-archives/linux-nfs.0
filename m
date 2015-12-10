Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm41.bullet.mail.bf1.yahoo.com ([216.109.114.57]:49785 "EHLO
	nm41.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751222AbbLJUgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Dec 2015 15:36:43 -0500
From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [RFC PATCH] VFS: Remove security module inode blob allocation
 overhead
To: LKLM <linux-kernel@vger.kernel.org>,
        LSM <linux-security-module@vger.kernel.org>, paul@paul-moore.com,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Cc: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <5669E0C9.2010705@schaufler-ca.com>
Date: Thu, 10 Dec 2015 12:30:01 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Subject: [RFC PATCH] VFS: Remove security module inode blob allocation overhead

The LSM infrastructure requires that the security modules
allocate and free inode data as they require it. SELinux
and Smack, the two security modules that use inode data,
require that all inodes allocate security data. Allocating
and freeing this data independently from the inode adds
unnecessary overhead. The indirection from the inode to
the security blob also adds overhead.

I fully expect objections to this approach. This approach
would have been unreasonable when the LSM was introduced,
as the majority of systems did not use a security module.
That is no longer the case. Most systems (RedHat, Fedora,
Ubuntu, Tizen, Android) use security modules today.

Putting the security blob directly into the inode increases
the size of the inode. The relative sizes are:

	Security disabled:		552
	Security enabled, no module:	552
	Security enabled with Smack:	624
	Security enabled with SELinux:	632
	Security enabled with both:	632

The first two numbers are the same because the module
data is only included if the module is included. There
is no i_security taking up space when it isn't needed.
The last two numbers are the same because i_selinux
and i_smack are unioned, which is sane since you can't
use them both at the same time. Systems using only
AppArmor get smaller inodes when properly configured.
Systems with security modules compiled out are unaffected.
Systems using either SELinux or Smack get full advantage.

It should be clear that for a properly configured kernel
it will always be advantageous to include the security blob
in the inode. By "properly configured" I mean simply that
the only security facilities built in are the ones that are
intended to be used, or that the value of generality is
sufficient to incur some overhead. A downside of this
approach is that the security blob structures are exposed.
I expect that there is some compiler trick I could use to
get the size of the blobs without doing so, but I am
disinclined to pursue that. Exposing the blob structure
has typing advantages.

Earlier discussions about changing the inode structure to
better accommodate the use of security data include:

	https://lkml.org/lkml/2013/6/3/516

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
---
  fs/nfs/inode.c                    |   5 +-
  include/linux/fs.h                |  11 +++-
  include/linux/selinux_blob.h      |  41 ++++++++++++
  include/linux/smack_blob.h        |  32 +++++++++
  security/security.c               |   2 +-
  security/selinux/hooks.c          | 132 +++++++++++++++++---------------------
  security/selinux/include/objsec.h |  14 +---
  security/selinux/selinuxfs.c      |   8 +--
  security/smack/smack.h            |  16 +----
  security/smack/smack_lsm.c        |  54 ++++++----------
  10 files changed, 174 insertions(+), 141 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e1..157f99e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -292,11 +292,14 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
  					struct nfs4_label *label)
  {
  	int error;
+	u32 secid = 0;
  
  	if (label == NULL)
  		return;
  
-	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) && inode->i_security) {
+	security_inode_getsecid(inode, &secid);
+
+	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) && secid != 0) {
  		error = security_inode_notifysecctx(inode, label->label,
  				label->len);
  		if (error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3aa5142..65d17fb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -31,6 +31,8 @@
  #include <linux/blk_types.h>
  #include <linux/workqueue.h>
  #include <linux/percpu-rwsem.h>
+#include <linux/selinux_blob.h>
+#include <linux/smack_blob.h>
  
  #include <asm/byteorder.h>
  #include <uapi/linux/fs.h>
@@ -598,8 +600,15 @@ struct inode {
  	struct address_space	*i_mapping;
  
  #ifdef CONFIG_SECURITY
-	void			*i_security;
+	union {
+#ifdef CONFIG_SECURITY_SELINUX
+		struct inode_selinux	i_selinux;
+#endif
+#ifdef CONFIG_SECURITY_SMACK
+		struct inode_smack	i_smack;
  #endif
+	};
+#endif /* CONFIG_SECURITY */
  
  	/* Stat data, not accessed from path walking */
  	unsigned long		i_ino;
diff --git a/include/linux/selinux_blob.h b/include/linux/selinux_blob.h
new file mode 100644
index 0000000..0ee65bc
--- /dev/null
+++ b/include/linux/selinux_blob.h
@@ -0,0 +1,41 @@
+/*
+ *  NSA Security-Enhanced Linux (SELinux) security module
+ *
+ *  This file contains the SELinux security data structures for kernel objects
+ *  that are exposed outside the module.
+ *
+ *  Author(s):  Stephen Smalley, <sds@epoch.ncsc.mil>
+ *		Chris Vance, <cvance@nai.com>
+ *		Wayne Salamon, <wsalamon@nai.com>
+ *		James Morris <jmorris@redhat.com>
+ *		Casey Schaufler <casey@schaufler-ca.com>
+ *
+ *  Copyright (C) 2001,2002 Networks Associates Technology, Inc.
+ *  Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
+ *  Copyright (C) 2015 Intel Corporation.
+ *
+ *	This program is free software; you can redistribute it and/or modify
+ *	it under the terms of the GNU General Public License version 2,
+ *	as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_SELINUX_BLOB_H_
+#define _LINUX_SELINUX_BLOB_H_
+
+#include <linux/list.h>
+#include <linux/fs.h>
+#include <linux/spinlock.h>
+
+struct inode_selinux {
+	struct inode *inode;	/* back pointer to inode object */
+	union {
+		struct list_head list;	/* list of inode_security_struct */
+		struct rcu_head rcu;	/* for freeing inode_selinux_struct */
+	};
+	u32 task_sid;		/* SID of creating task */
+	u32 sid;		/* SID of this object */
+	u16 sclass;		/* security class of this object */
+	unsigned char initialized;	/* initialization flag */
+	struct mutex lock;
+};
+
+#endif /* _LINUX_SELINUX_BLOB_H_ */
diff --git a/include/linux/smack_blob.h b/include/linux/smack_blob.h
new file mode 100644
index 0000000..a8acf0d
--- /dev/null
+++ b/include/linux/smack_blob.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2015 Intel Corporation
+ * Copyright (C) 2015 Casey Schaufler <casey@schaufler-ca.com>
+ *
+ *      This program is free software; you can redistribute it and/or modify
+ *      it under the terms of the GNU General Public License as published by
+ *      the Free Software Foundation, version 2.
+ *
+ * Author:
+ *      Casey Schaufler <casey@schaufler-ca.com>
+ *
+ */
+
+#ifndef _LINUX_SMACK_BLOB_H
+#define _LINUX_SMACK_BLOB_H
+
+#include <linux/spinlock.h>
+
+struct smack_known;
+
+/*
+ * Inode smack data
+ */
+struct inode_smack {
+	struct smack_known	*smk_inode;	/* label of the fso */
+	struct smack_known	*smk_task;	/* label of the task */
+	struct smack_known	*smk_mmap;	/* label of the mmap domain */
+	struct mutex		smk_lock;	/* initialization lock */
+	int			smk_flags;	/* smack inode flags */
+};
+
+#endif  /* _LINUX_SMACK_BLOB_H */
diff --git a/security/security.c b/security/security.c
index 46f405c..7241647 100644
--- a/security/security.c
+++ b/security/security.c
@@ -344,7 +344,6 @@ EXPORT_SYMBOL(security_sb_parse_opts_str);
  
  int security_inode_alloc(struct inode *inode)
  {
-	inode->i_security = NULL;
  	return call_int_hook(inode_alloc_security, 0, inode);
  }
  
@@ -725,6 +724,7 @@ void security_inode_getsecid(const struct inode *inode, u32 *secid)
  {
  	call_void_hook(inode_getsecid, inode, secid);
  }
+EXPORT_SYMBOL(security_inode_getsecid);
  
  int security_file_permission(struct file *file, int mask)
  {
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index d0cfaa9..8d6def6 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -224,35 +224,24 @@ static inline u32 current_sid(void)
  
  static int inode_alloc_security(struct inode *inode)
  {
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	u32 sid = current_sid();
  
-	isec = kmem_cache_zalloc(sel_inode_cache, GFP_NOFS);
-	if (!isec)
-		return -ENOMEM;
-
+	isec = &inode->i_selinux;
+	memset(isec, 0, sizeof(*isec));
  	mutex_init(&isec->lock);
  	INIT_LIST_HEAD(&isec->list);
  	isec->inode = inode;
  	isec->sid = SECINITSID_UNLABELED;
  	isec->sclass = SECCLASS_FILE;
  	isec->task_sid = sid;
-	inode->i_security = isec;
  
  	return 0;
  }
  
-static void inode_free_rcu(struct rcu_head *head)
-{
-	struct inode_security_struct *isec;
-
-	isec = container_of(head, struct inode_security_struct, rcu);
-	kmem_cache_free(sel_inode_cache, isec);
-}
-
  static void inode_free_security(struct inode *inode)
  {
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	struct superblock_security_struct *sbsec = inode->i_sb->s_security;
  
  	/*
@@ -276,11 +265,8 @@ static void inode_free_security(struct inode *inode)
  	 * a call to selinux_inode_permission() can be made
  	 * after inode_free_security() is called. Ideally, the VFS
  	 * wouldn't do this, but fixing that is a much harder
-	 * job. For now, simply free the i_security via RCU, and
-	 * leave the current inode->i_security pointer intact.
-	 * The inode will be freed after the RCU grace period too.
+	 * job.
  	 */
-	call_rcu(&isec->rcu, inode_free_rcu);
  }
  
  static int file_alloc_security(struct file *file)
@@ -474,9 +460,9 @@ static int sb_finish_set_opts(struct super_block *sb)
  	spin_lock(&sbsec->isec_lock);
  next_inode:
  	if (!list_empty(&sbsec->isec_head)) {
-		struct inode_security_struct *isec =
+		struct inode_selinux *isec =
  				list_entry(sbsec->isec_head.next,
-					   struct inode_security_struct, list);
+					   struct inode_selinux, list);
  		struct inode *inode = isec->inode;
  		list_del_init(&isec->list);
  		spin_unlock(&sbsec->isec_lock);
@@ -566,7 +552,7 @@ static int selinux_get_mnt_opts(const struct super_block *sb,
  	}
  	if (sbsec->flags & ROOTCONTEXT_MNT) {
  		struct inode *root = d_backing_inode(sbsec->sb->s_root);
-		struct inode_security_struct *isec = root->i_security;
+		struct inode_selinux *isec = &root->i_selinux;
  
  		rc = security_sid_to_context(isec->sid, &context, &len);
  		if (rc)
@@ -622,7 +608,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
  	struct superblock_security_struct *sbsec = sb->s_security;
  	const char *name = sb->s_type->name;
  	struct inode *inode = d_backing_inode(sbsec->sb->s_root);
-	struct inode_security_struct *root_isec = inode->i_security;
+	struct inode_selinux *root_isec = &inode->i_selinux;
  	u32 fscontext_sid = 0, context_sid = 0, rootcontext_sid = 0;
  	u32 defcontext_sid = 0;
  	char **mount_options = opts->mnt_opts;
@@ -852,8 +838,8 @@ static int selinux_cmp_sb_context(const struct super_block *oldsb,
  	if ((oldflags & DEFCONTEXT_MNT) && old->def_sid != new->def_sid)
  		goto mismatch;
  	if (oldflags & ROOTCONTEXT_MNT) {
-		struct inode_security_struct *oldroot = d_backing_inode(oldsb->s_root)->i_security;
-		struct inode_security_struct *newroot = d_backing_inode(newsb->s_root)->i_security;
+		struct inode_selinux *oldroot = &d_backing_inode(oldsb->s_root)->i_selinux;
+		struct inode_selinux *newroot = &d_backing_inode(newsb->s_root)->i_selinux;
  		if (oldroot->sid != newroot->sid)
  			goto mismatch;
  	}
@@ -904,16 +890,16 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
  			newsbsec->sid = sid;
  		if (!set_rootcontext) {
  			struct inode *newinode = d_backing_inode(newsb->s_root);
-			struct inode_security_struct *newisec = newinode->i_security;
+			struct inode_selinux *newisec = &newinode->i_selinux;
  			newisec->sid = sid;
  		}
  		newsbsec->mntpoint_sid = sid;
  	}
  	if (set_rootcontext) {
  		const struct inode *oldinode = d_backing_inode(oldsb->s_root);
-		const struct inode_security_struct *oldisec = oldinode->i_security;
+		const struct inode_selinux *oldisec = &oldinode->i_selinux;
  		struct inode *newinode = d_backing_inode(newsb->s_root);
-		struct inode_security_struct *newisec = newinode->i_security;
+		struct inode_selinux *newisec = &newinode->i_selinux;
  
  		newisec->sid = oldisec->sid;
  	}
@@ -1285,7 +1271,7 @@ static int selinux_genfs_get_sid(struct dentry *dentry,
  static int inode_doinit_with_dentry(struct inode *inode, struct dentry *opt_dentry)
  {
  	struct superblock_security_struct *sbsec = NULL;
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	u32 sid;
  	struct dentry *dentry;
  #define INITCONTEXTLEN 255
@@ -1614,7 +1600,7 @@ static int inode_has_perm(const struct cred *cred,
  			  u32 perms,
  			  struct common_audit_data *adp)
  {
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	u32 sid;
  
  	validate_creds(cred);
@@ -1623,7 +1609,7 @@ static int inode_has_perm(const struct cred *cred,
  		return 0;
  
  	sid = cred_sid(cred);
-	isec = inode->i_security;
+	isec = &inode->i_selinux;
  
  	return avc_has_perm(sid, isec->sid, isec->sclass, perms, adp);
  }
@@ -1718,7 +1704,7 @@ static int selinux_determine_inode_label(const struct inode *dir,
  					 u32 *_new_isid)
  {
  	const struct superblock_security_struct *sbsec = dir->i_sb->s_security;
-	const struct inode_security_struct *dsec = dir->i_security;
+	const struct inode_selinux *dsec = &dir->i_selinux;
  	const struct task_security_struct *tsec = current_security();
  
  	if ((sbsec->flags & SE_SBINITIALIZED) &&
@@ -1741,13 +1727,13 @@ static int may_create(struct inode *dir,
  		      u16 tclass)
  {
  	const struct task_security_struct *tsec = current_security();
-	struct inode_security_struct *dsec;
+	struct inode_selinux *dsec;
  	struct superblock_security_struct *sbsec;
  	u32 sid, newsid;
  	struct common_audit_data ad;
  	int rc;
  
-	dsec = dir->i_security;
+	dsec = &dir->i_selinux;
  	sbsec = dir->i_sb->s_security;
  
  	sid = tsec->sid;
@@ -1794,14 +1780,14 @@ static int may_link(struct inode *dir,
  		    int kind)
  
  {
-	struct inode_security_struct *dsec, *isec;
+	struct inode_selinux *dsec, *isec;
  	struct common_audit_data ad;
  	u32 sid = current_sid();
  	u32 av;
  	int rc;
  
-	dsec = dir->i_security;
-	isec = d_backing_inode(dentry)->i_security;
+	dsec = &dir->i_selinux;
+	isec = &d_backing_inode(dentry)->i_selinux;
  
  	ad.type = LSM_AUDIT_DATA_DENTRY;
  	ad.u.dentry = dentry;
@@ -1837,17 +1823,17 @@ static inline int may_rename(struct inode *old_dir,
  			     struct inode *new_dir,
  			     struct dentry *new_dentry)
  {
-	struct inode_security_struct *old_dsec, *new_dsec, *old_isec, *new_isec;
+	struct inode_selinux *old_dsec, *new_dsec, *old_isec, *new_isec;
  	struct common_audit_data ad;
  	u32 sid = current_sid();
  	u32 av;
  	int old_is_dir, new_is_dir;
  	int rc;
  
-	old_dsec = old_dir->i_security;
-	old_isec = d_backing_inode(old_dentry)->i_security;
+	old_dsec = &old_dir->i_selinux;
+	old_isec = &d_backing_inode(old_dentry)->i_selinux;
  	old_is_dir = d_is_dir(old_dentry);
-	new_dsec = new_dir->i_security;
+	new_dsec = &new_dir->i_selinux;
  
  	ad.type = LSM_AUDIT_DATA_DENTRY;
  
@@ -1875,7 +1861,7 @@ static inline int may_rename(struct inode *old_dir,
  	if (rc)
  		return rc;
  	if (d_is_positive(new_dentry)) {
-		new_isec = d_backing_inode(new_dentry)->i_security;
+		new_isec = &d_backing_inode(new_dentry)->i_selinux;
  		new_is_dir = d_is_dir(new_dentry);
  		rc = avc_has_perm(sid, new_isec->sid,
  				  new_isec->sclass,
@@ -2012,7 +1998,7 @@ static int selinux_binder_transfer_file(struct task_struct *from,
  	u32 sid = task_sid(to);
  	struct file_security_struct *fsec = file->f_security;
  	struct inode *inode = d_backing_inode(file->f_path.dentry);
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	struct common_audit_data ad;
  	int rc;
  
@@ -2205,7 +2191,7 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
  {
  	const struct task_security_struct *old_tsec;
  	struct task_security_struct *new_tsec;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	struct common_audit_data ad;
  	struct inode *inode = file_inode(bprm->file);
  	int rc;
@@ -2217,7 +2203,7 @@ static int selinux_bprm_set_creds(struct linux_binprm *bprm)
  
  	old_tsec = current_security();
  	new_tsec = bprm->cred->security;
-	isec = inode->i_security;
+	isec = &inode->i_selinux;
  
  	/* Default to the current task SID. */
  	new_tsec->sid = old_tsec->sid;
@@ -2638,8 +2624,8 @@ static int selinux_sb_remount(struct super_block *sb, void *data)
  				goto out_bad_option;
  			break;
  		case ROOTCONTEXT_MNT: {
-			struct inode_security_struct *root_isec;
-			root_isec = d_backing_inode(sb->s_root)->i_security;
+			struct inode_selinux *root_isec;
+			root_isec = &d_backing_inode(sb->s_root)->i_selinux;
  
  			if (bad_option(sbsec, ROOTCONTEXT_MNT, root_isec->sid, sid))
  				goto out_bad_option;
@@ -2753,13 +2739,13 @@ static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
  				       void **value, size_t *len)
  {
  	const struct task_security_struct *tsec = current_security();
-	struct inode_security_struct *dsec;
+	struct inode_selinux *dsec;
  	struct superblock_security_struct *sbsec;
  	u32 sid, newsid, clen;
  	int rc;
  	char *context;
  
-	dsec = dir->i_security;
+	dsec = &dir->i_selinux;
  	sbsec = dir->i_sb->s_security;
  
  	sid = tsec->sid;
@@ -2774,7 +2760,7 @@ static int selinux_inode_init_security(struct inode *inode, struct inode *dir,
  
  	/* Possibly defer initialization to selinux_complete_init. */
  	if (sbsec->flags & SE_SBINITIALIZED) {
-		struct inode_security_struct *isec = inode->i_security;
+		struct inode_selinux *isec = &inode->i_selinux;
  		isec->sclass = inode_mode_to_security_class(inode->i_mode);
  		isec->sid = newsid;
  		isec->initialized = 1;
@@ -2850,7 +2836,7 @@ static int selinux_inode_follow_link(struct dentry *dentry, struct inode *inode,
  {
  	const struct cred *cred = current_cred();
  	struct common_audit_data ad;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	u32 sid;
  
  	validate_creds(cred);
@@ -2858,7 +2844,7 @@ static int selinux_inode_follow_link(struct dentry *dentry, struct inode *inode,
  	ad.type = LSM_AUDIT_DATA_DENTRY;
  	ad.u.dentry = dentry;
  	sid = cred_sid(cred);
-	isec = inode->i_security;
+	isec = &inode->i_selinux;
  
  	return avc_has_perm_flags(sid, isec->sid, isec->sclass, FILE__READ, &ad,
  				  rcu ? MAY_NOT_BLOCK : 0);
@@ -2870,7 +2856,7 @@ static noinline int audit_inode_permission(struct inode *inode,
  					   unsigned flags)
  {
  	struct common_audit_data ad;
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	int rc;
  
  	ad.type = LSM_AUDIT_DATA_INODE;
@@ -2889,7 +2875,7 @@ static int selinux_inode_permission(struct inode *inode, int mask)
  	u32 perms;
  	bool from_access;
  	unsigned flags = mask & MAY_NOT_BLOCK;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	u32 sid;
  	struct av_decision avd;
  	int rc, rc2;
@@ -2910,7 +2896,7 @@ static int selinux_inode_permission(struct inode *inode, int mask)
  	perms = file_mask_to_av(inode->i_mode, mask);
  
  	sid = cred_sid(cred);
-	isec = inode->i_security;
+	isec = &inode->i_selinux;
  
  	rc = avc_has_perm_noaudit(sid, isec->sid, isec->sclass, perms, 0, &avd);
  	audited = avc_audit_required(perms, &avd, rc,
@@ -2980,7 +2966,7 @@ static int selinux_inode_setxattr(struct dentry *dentry, const char *name,
  				  const void *value, size_t size, int flags)
  {
  	struct inode *inode = d_backing_inode(dentry);
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	struct superblock_security_struct *sbsec;
  	struct common_audit_data ad;
  	u32 newsid, sid = current_sid();
@@ -3057,7 +3043,7 @@ static void selinux_inode_post_setxattr(struct dentry *dentry, const char *name,
  					int flags)
  {
  	struct inode *inode = d_backing_inode(dentry);
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	u32 newsid;
  	int rc;
  
@@ -3115,7 +3101,7 @@ static int selinux_inode_getsecurity(const struct inode *inode, const char *name
  	u32 size;
  	int error;
  	char *context = NULL;
-	struct inode_security_struct *isec = inode->i_security;
+	const struct inode_selinux *isec = &inode->i_selinux;
  
  	if (strcmp(name, XATTR_SELINUX_SUFFIX))
  		return -EOPNOTSUPP;
@@ -3154,7 +3140,7 @@ out_nofree:
  static int selinux_inode_setsecurity(struct inode *inode, const char *name,
  				     const void *value, size_t size, int flags)
  {
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	u32 newsid;
  	int rc;
  
@@ -3184,7 +3170,7 @@ static int selinux_inode_listsecurity(struct inode *inode, char *buffer, size_t
  
  static void selinux_inode_getsecid(const struct inode *inode, u32 *secid)
  {
-	struct inode_security_struct *isec = inode->i_security;
+	const struct inode_selinux *isec = &inode->i_selinux;
  	*secid = isec->sid;
  }
  
@@ -3207,7 +3193,7 @@ static int selinux_file_permission(struct file *file, int mask)
  {
  	struct inode *inode = file_inode(file);
  	struct file_security_struct *fsec = file->f_security;
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	u32 sid = current_sid();
  
  	if (!mask)
@@ -3242,7 +3228,7 @@ static int ioctl_has_perm(const struct cred *cred, struct file *file,
  	struct common_audit_data ad;
  	struct file_security_struct *fsec = file->f_security;
  	struct inode *inode = file_inode(file);
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	struct lsm_ioctlop_audit ioctl;
  	u32 ssid = cred_sid(cred);
  	int rc;
@@ -3503,10 +3489,10 @@ static int selinux_file_receive(struct file *file)
  static int selinux_file_open(struct file *file, const struct cred *cred)
  {
  	struct file_security_struct *fsec;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  
  	fsec = file->f_security;
-	isec = file_inode(file)->i_security;
+	isec = &file_inode(file)->i_selinux;
  	/*
  	 * Save inode label and policy sequence number
  	 * at open-time so that selinux_file_permission
@@ -3624,7 +3610,7 @@ static int selinux_kernel_act_as(struct cred *new, u32 secid)
   */
  static int selinux_kernel_create_files_as(struct cred *new, struct inode *inode)
  {
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	struct task_security_struct *tsec = new->security;
  	u32 sid = current_sid();
  	int ret;
@@ -3744,7 +3730,7 @@ static int selinux_task_wait(struct task_struct *p)
  static void selinux_task_to_inode(struct task_struct *p,
  				  struct inode *inode)
  {
-	struct inode_security_struct *isec = inode->i_security;
+	struct inode_selinux *isec = &inode->i_selinux;
  	u32 sid = task_sid(p);
  
  	isec->sid = sid;
@@ -4065,7 +4051,7 @@ static int selinux_socket_post_create(struct socket *sock, int family,
  				      int type, int protocol, int kern)
  {
  	const struct task_security_struct *tsec = current_security();
-	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
+	struct inode_selinux *isec = &SOCK_INODE(sock)->i_selinux;
  	struct sk_security_struct *sksec;
  	int err = 0;
  
@@ -4258,16 +4244,16 @@ static int selinux_socket_listen(struct socket *sock, int backlog)
  static int selinux_socket_accept(struct socket *sock, struct socket *newsock)
  {
  	int err;
-	struct inode_security_struct *isec;
-	struct inode_security_struct *newisec;
+	struct inode_selinux *isec;
+	struct inode_selinux *newisec;
  
  	err = sock_has_perm(current, sock->sk, SOCKET__ACCEPT);
  	if (err)
  		return err;
  
-	newisec = SOCK_INODE(newsock)->i_security;
+	newisec = &SOCK_INODE(newsock)->i_selinux;
  
-	isec = SOCK_INODE(sock)->i_security;
+	isec = &SOCK_INODE(sock)->i_selinux;
  	newisec->sclass = isec->sclass;
  	newisec->sid = isec->sid;
  	newisec->initialized = 1;
@@ -4605,7 +4591,7 @@ static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
  
  static void selinux_sock_graft(struct sock *sk, struct socket *parent)
  {
-	struct inode_security_struct *isec = SOCK_INODE(parent)->i_security;
+	struct inode_selinux *isec = &SOCK_INODE(parent)->i_selinux;
  	struct sk_security_struct *sksec = sk->sk_security;
  
  	if (sk->sk_family == PF_INET || sk->sk_family == PF_INET6 ||
@@ -6087,7 +6073,7 @@ static __init int selinux_init(void)
  	default_noexec = !(VM_DATA_DEFAULT_FLAGS & VM_EXEC);
  
  	sel_inode_cache = kmem_cache_create("selinux_inode_security",
-					    sizeof(struct inode_security_struct),
+					    sizeof(struct inode_selinux),
  					    0, SLAB_PANIC, NULL);
  	file_security_cache = kmem_cache_create("selinux_file_security",
  					    sizeof(struct file_security_struct),
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 81fa718..57385b6 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -24,6 +24,7 @@
  #include <linux/binfmts.h>
  #include <linux/in.h>
  #include <linux/spinlock.h>
+#include <linux/selinux_blob.h>
  #include <net/net_namespace.h>
  #include "flask.h"
  #include "avc.h"
@@ -37,19 +38,6 @@ struct task_security_struct {
  	u32 sockcreate_sid;	/* fscreate SID */
  };
  
-struct inode_security_struct {
-	struct inode *inode;	/* back pointer to inode object */
-	union {
-		struct list_head list;	/* list of inode_security_struct */
-		struct rcu_head rcu;	/* for freeing the inode_security_struct */
-	};
-	u32 task_sid;		/* SID of creating task */
-	u32 sid;		/* SID of this object */
-	u16 sclass;		/* security class of this object */
-	unsigned char initialized;	/* initialization flag */
-	struct mutex lock;
-};
-
  struct file_security_struct {
  	u32 sid;		/* SID of open file description */
  	u32 fown_sid;		/* SID of file owner (for SIGIO) */
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index c02da25..7c1b0d1 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -1200,7 +1200,7 @@ static int sel_make_bools(void)
  	struct dentry *dentry = NULL;
  	struct dentry *dir = bool_dir;
  	struct inode *inode = NULL;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  	char **names = NULL, *page;
  	int num;
  	int *values = NULL;
@@ -1242,7 +1242,7 @@ static int sel_make_bools(void)
  		if (len >= PAGE_SIZE)
  			goto out;
  
-		isec = (struct inode_security_struct *)inode->i_security;
+		isec = &inode->i_selinux;
  		ret = security_genfs_sid("selinuxfs", page, SECCLASS_FILE, &sid);
  		if (ret)
  			goto out;
@@ -1739,7 +1739,7 @@ static int sel_fill_super(struct super_block *sb, void *data, int silent)
  	int ret;
  	struct dentry *dentry;
  	struct inode *inode;
-	struct inode_security_struct *isec;
+	struct inode_selinux *isec;
  
  	static struct tree_descr selinux_files[] = {
  		[SEL_LOAD] = {"load", &sel_load_ops, S_IRUSR|S_IWUSR},
@@ -1783,7 +1783,7 @@ static int sel_fill_super(struct super_block *sb, void *data, int silent)
  		goto err;
  
  	inode->i_ino = ++sel_last_ino;
-	isec = (struct inode_security_struct *)inode->i_security;
+	isec = &inode->i_selinux;
  	isec->sid = SECINITSID_DEVNULL;
  	isec->sclass = SECCLASS_CHR_FILE;
  	isec->initialized = 1;
diff --git a/security/smack/smack.h b/security/smack/smack.h
index 6c91156..0e1c39a 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -24,6 +24,7 @@
  #include <linux/list.h>
  #include <linux/rculist.h>
  #include <linux/lsm_audit.h>
+#include <linux/smack_blob.h>
  
  /*
   * Use IPv6 port labeling if IPv6 is enabled and secmarks
@@ -99,17 +100,6 @@ struct socket_smack {
  	struct smack_known	*smk_packet;	/* TCP peer label */
  };
  
-/*
- * Inode smack data
- */
-struct inode_smack {
-	struct smack_known	*smk_inode;	/* label of the fso */
-	struct smack_known	*smk_task;	/* label of the task */
-	struct smack_known	*smk_mmap;	/* label of the mmap domain */
-	struct mutex		smk_lock;	/* initialization lock */
-	int			smk_flags;	/* smack inode flags */
-};
-
  struct task_smack {
  	struct smack_known	*smk_task;	/* label for access control */
  	struct smack_known	*smk_forked;	/* label when forked */
@@ -342,7 +332,7 @@ extern struct hlist_head smack_known_hash[SMACK_HASH_SLOTS];
   */
  static inline int smk_inode_transmutable(const struct inode *isp)
  {
-	struct inode_smack *sip = isp->i_security;
+	const struct inode_smack *sip = &isp->i_smack;
  	return (sip->smk_flags & SMK_INODE_TRANSMUTE) != 0;
  }
  
@@ -351,7 +341,7 @@ static inline int smk_inode_transmutable(const struct inode *isp)
   */
  static inline struct smack_known *smk_of_inode(const struct inode *isp)
  {
-	struct inode_smack *sip = isp->i_security;
+	const struct inode_smack *sip = &isp->i_smack;
  	return sip->smk_inode;
  }
  
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index ff81026..14cc49d 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -164,7 +164,7 @@ static int smk_bu_task(struct task_struct *otp, int mode, int rc)
  static int smk_bu_inode(struct inode *inode, int mode, int rc)
  {
  	struct task_smack *tsp = current_security();
-	struct inode_smack *isp = inode->i_security;
+	struct inode_smack *isp = &inode->i_smack;
  	char acc[SMK_NUM_ACCESS_TYPE + 1];
  
  	if (isp->smk_flags & SMK_INODE_IMPURE)
@@ -196,7 +196,7 @@ static int smk_bu_file(struct file *file, int mode, int rc)
  	struct task_smack *tsp = current_security();
  	struct smack_known *sskp = tsp->smk_task;
  	struct inode *inode = file_inode(file);
-	struct inode_smack *isp = inode->i_security;
+	struct inode_smack *isp = &inode->i_smack;
  	char acc[SMK_NUM_ACCESS_TYPE + 1];
  
  	if (isp->smk_flags & SMK_INODE_IMPURE)
@@ -226,7 +226,7 @@ static int smk_bu_credfile(const struct cred *cred, struct file *file,
  	struct task_smack *tsp = cred->security;
  	struct smack_known *sskp = tsp->smk_task;
  	struct inode *inode = file->f_inode;
-	struct inode_smack *isp = inode->i_security;
+	struct inode_smack *isp = &inode->i_smack;
  	char acc[SMK_NUM_ACCESS_TYPE + 1];
  
  	if (isp->smk_flags & SMK_INODE_IMPURE)
@@ -291,19 +291,11 @@ static struct smack_known *smk_fetch(const char *name, struct inode *ip,
   *
   * Returns the new blob or NULL if there's no memory available
   */
-static struct inode_smack *new_inode_smack(struct smack_known *skp)
+static void new_inode_smack(struct inode_smack *isp, struct smack_known *skp)
  {
-	struct inode_smack *isp;
-
-	isp = kmem_cache_zalloc(smack_inode_cache, GFP_NOFS);
-	if (isp == NULL)
-		return NULL;
-
  	isp->smk_inode = skp;
  	isp->smk_flags = 0;
  	mutex_init(&isp->smk_lock);
-
-	return isp;
  }
  
  /**
@@ -828,14 +820,8 @@ static int smack_set_mnt_opts(struct super_block *sb,
  	/*
  	 * Initialize the root inode.
  	 */
-	isp = inode->i_security;
-	if (isp == NULL) {
-		isp = new_inode_smack(sp->smk_root);
-		if (isp == NULL)
-			return -ENOMEM;
-		inode->i_security = isp;
-	} else
-		isp->smk_inode = sp->smk_root;
+	isp = &inode->i_smack;
+	isp->smk_inode = sp->smk_root;
  
  	if (transmute)
  		isp->smk_flags |= SMK_INODE_TRANSMUTE;
@@ -915,7 +901,7 @@ static int smack_bprm_set_creds(struct linux_binprm *bprm)
  	if (bprm->cred_prepared)
  		return 0;
  
-	isp = inode->i_security;
+	isp = &inode->i_smack;
  	if (isp->smk_task == NULL || isp->smk_task == bsp->smk_task)
  		return 0;
  
@@ -987,9 +973,7 @@ static int smack_inode_alloc_security(struct inode *inode)
  {
  	struct smack_known *skp = smk_of_current();
  
-	inode->i_security = new_inode_smack(skp);
-	if (inode->i_security == NULL)
-		return -ENOMEM;
+	new_inode_smack(&inode->i_smack, skp);
  	return 0;
  }
  
@@ -1001,8 +985,8 @@ static int smack_inode_alloc_security(struct inode *inode)
   */
  static void smack_inode_free_security(struct inode *inode)
  {
-	kmem_cache_free(smack_inode_cache, inode->i_security);
-	inode->i_security = NULL;
+	inode->i_smack.smk_inode = NULL;
+	inode->i_smack.smk_flags = 0;
  }
  
  /**
@@ -1020,7 +1004,7 @@ static int smack_inode_init_security(struct inode *inode, struct inode *dir,
  				     const struct qstr *qstr, const char **name,
  				     void **value, size_t *len)
  {
-	struct inode_smack *issp = inode->i_security;
+	struct inode_smack *issp = &inode->i_smack;
  	struct smack_known *skp = smk_of_current();
  	struct smack_known *isp = smk_of_inode(inode);
  	struct smack_known *dsp = smk_of_inode(dir);
@@ -1352,7 +1336,7 @@ static void smack_inode_post_setxattr(struct dentry *dentry, const char *name,
  				      const void *value, size_t size, int flags)
  {
  	struct smack_known *skp;
-	struct inode_smack *isp = d_backing_inode(dentry)->i_security;
+	struct inode_smack *isp = &d_backing_inode(dentry)->i_smack;
  
  	if (strcmp(name, XATTR_NAME_SMACKTRANSMUTE) == 0) {
  		isp->smk_flags |= SMK_INODE_TRANSMUTE;
@@ -1439,7 +1423,7 @@ static int smack_inode_removexattr(struct dentry *dentry, const char *name)
  	if (rc != 0)
  		return rc;
  
-	isp = d_backing_inode(dentry)->i_security;
+	isp = &d_backing_inode(dentry)->i_smack;
  	/*
  	 * Don't do anything special for these.
  	 *	XATTR_NAME_SMACKIPIN
@@ -1540,7 +1524,7 @@ static int smack_inode_listsecurity(struct inode *inode, char *buffer,
   */
  static void smack_inode_getsecid(const struct inode *inode, u32 *secid)
  {
-	struct inode_smack *isp = inode->i_security;
+	const struct inode_smack *isp = &inode->i_smack;
  
  	*secid = isp->smk_inode->smk_secid;
  }
@@ -1724,7 +1708,7 @@ static int smack_mmap_file(struct file *file,
  	if (file == NULL)
  		return 0;
  
-	isp = file_inode(file)->i_security;
+	isp = &file_inode(file)->i_smack;
  	if (isp->smk_mmap == NULL)
  		return 0;
  	mkp = isp->smk_mmap;
@@ -2045,7 +2029,7 @@ static int smack_kernel_act_as(struct cred *new, u32 secid)
  static int smack_kernel_create_files_as(struct cred *new,
  					struct inode *inode)
  {
-	struct inode_smack *isp = inode->i_security;
+	struct inode_smack *isp = &inode->i_smack;
  	struct task_smack *tsp = new->security;
  
  	tsp->smk_forked = isp->smk_inode;
@@ -2263,7 +2247,7 @@ static int smack_task_wait(struct task_struct *p)
   */
  static void smack_task_to_inode(struct task_struct *p, struct inode *inode)
  {
-	struct inode_smack *isp = inode->i_security;
+	struct inode_smack *isp = &inode->i_smack;
  	struct smack_known *skp = smk_of_task_struct(p);
  
  	isp->smk_inode = skp;
@@ -2687,7 +2671,7 @@ static int smack_inode_setsecurity(struct inode *inode, const char *name,
  				   const void *value, size_t size, int flags)
  {
  	struct smack_known *skp;
-	struct inode_smack *nsp = inode->i_security;
+	struct inode_smack *nsp = &inode->i_smack;
  	struct socket_smack *ssp;
  	struct socket *sock;
  	int rc = 0;
@@ -3348,7 +3332,7 @@ static void smack_d_instantiate(struct dentry *opt_dentry, struct inode *inode)
  	if (inode == NULL)
  		return;
  
-	isp = inode->i_security;
+	isp = &inode->i_smack;
  
  	mutex_lock(&isp->smk_lock);
  	/*


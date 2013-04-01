Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:39099 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512Ab3DAMOb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2013 08:14:31 -0400
Received: by mail-qc0-f174.google.com with SMTP id z24so1000705qcq.5
        for <linux-nfs@vger.kernel.org>; Mon, 01 Apr 2013 05:14:30 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: sds@tycho.nsa.gov, james.l.morris@oracle.com, eparis@parisplace.org
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2] selinux: make security_sb_clone_mnt_opts return an error on context mismatch
Date: Mon,  1 Apr 2013 08:14:24 -0400
Message-Id: <1364818464-20220-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1358437249-8631-1-git-send-email-jlayton@redhat.com>
References: <1358437249-8631-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had the following problem reported a while back. If you mount the
same filesystem twice using NFSv4 with different contexts, then the
second context= option is ignored. For instance:

    # mount server:/export /mnt/test1
    # mount server:/export /mnt/test2 -o context=system_u:object_r:tmp_t:s0
    # ls -dZ /mnt/test1
    drwxrwxrwt. root root system_u:object_r:nfs_t:s0       /mnt/test1
    # ls -dZ /mnt/test2
    drwxrwxrwt. root root system_u:object_r:nfs_t:s0       /mnt/test2

When we call into SELinux to set the context of a "cloned" superblock,
it will currently just bail out when it notices that we're reusing an
existing superblock. Since the existing superblock is already set up and
presumably in use, we can't go overwriting its context with the one from
the "original" sb. Because of this, the second context= option in this
case cannot take effect.

This patch fixes this by turning security_sb_clone_mnt_opts into an int
return operation. When it finds that the "new" superblock that it has
been handed is already set up, it checks to see whether the contexts on
the old superblock match it. If it does, then it will just return
success, otherwise it'll return -EBUSY and emit a printk to tell the
admin why the second mount failed.

Note that this patch may cause casualties. The NFSv4 code relies on
being able to walk down to an export from the pseudoroot. If you mount
filesystems that are nested within one another with different contexts,
then this patch will make those mounts fail in new and "exciting" ways.

For instance, suppose that /export is a separate filesystem on the
server:

    # mount server:/ /mnt/test1
    # mount salusa:/export /mnt/test2 -o context=system_u:object_r:tmp_t:s0
    mount.nfs: an incorrect mount option was specified

...with the printk in the ring buffer. Because we *might* eventually
walk down to /mnt/test1/export, the mount is denied due to this patch.
The second mount needs the pseudoroot superblock, but that's already
present with the wrong context.

OTOH, if we mount these in the reverse order, then both mounts work,
because the pseudoroot superblock created when mounting /export is
discarded once that mount is done. If we then however try to walk into
that directory, the automount fails for the similar reasons:

    # cd /mnt/test1/scratch/
    -bash: cd: /mnt/test1/scratch: Device or resource busy

The story I've gotten from the SELinux folks that I've talked to is that
this is desirable behavior. In SELinux-land, mounting the same data
under different contexts is wrong -- there can be only one.

Cc: Steve Dickson <steved@redhat.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Eric Paris <eparis@redhat.com>
---
 fs/nfs/super.c           |  3 +--
 include/linux/security.h | 10 ++++++----
 security/capability.c    |  3 ++-
 security/security.c      |  4 ++--
 security/selinux/hooks.c | 39 +++++++++++++++++++++++++++++++++++----
 5 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f8a29d..76924ad 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2381,10 +2381,9 @@ int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 			  struct nfs_mount_info *mount_info)
 {
 	/* clone any lsm security options from the parent to the new sb */
-	security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
 	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
 		return -ESTALE;
-	return 0;
+	return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
diff --git a/include/linux/security.h b/include/linux/security.h
index eee7478..4c7058d 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1436,7 +1436,7 @@ struct security_operations {
 			     struct path *new_path);
 	int (*sb_set_mnt_opts) (struct super_block *sb,
 				struct security_mnt_opts *opts);
-	void (*sb_clone_mnt_opts) (const struct super_block *oldsb,
+	int (*sb_clone_mnt_opts) (const struct super_block *oldsb,
 				   struct super_block *newsb);
 	int (*sb_parse_opts_str) (char *options, struct security_mnt_opts *opts);
 
@@ -1721,7 +1721,7 @@ int security_sb_mount(const char *dev_name, struct path *path,
 int security_sb_umount(struct vfsmount *mnt, int flags);
 int security_sb_pivotroot(struct path *old_path, struct path *new_path);
 int security_sb_set_mnt_opts(struct super_block *sb, struct security_mnt_opts *opts);
-void security_sb_clone_mnt_opts(const struct super_block *oldsb,
+int security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb);
 int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts);
 
@@ -2011,9 +2011,11 @@ static inline int security_sb_set_mnt_opts(struct super_block *sb,
 	return 0;
 }
 
-static inline void security_sb_clone_mnt_opts(const struct super_block *oldsb,
+static inline int security_sb_clone_mnt_opts(const struct super_block *oldsb,
 					      struct super_block *newsb)
-{ }
+{
+	return 0;
+}
 
 static inline int security_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
 {
diff --git a/security/capability.c b/security/capability.c
index 5797750..a6290b6 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -98,9 +98,10 @@ static int cap_sb_set_mnt_opts(struct super_block *sb,
 	return 0;
 }
 
-static void cap_sb_clone_mnt_opts(const struct super_block *oldsb,
+static int cap_sb_clone_mnt_opts(const struct super_block *oldsb,
 				  struct super_block *newsb)
 {
+	return 0;
 }
 
 static int cap_sb_parse_opts_str(char *options, struct security_mnt_opts *opts)
diff --git a/security/security.c b/security/security.c
index 7b88c6a..108281d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -299,10 +299,10 @@ int security_sb_set_mnt_opts(struct super_block *sb,
 }
 EXPORT_SYMBOL(security_sb_set_mnt_opts);
 
-void security_sb_clone_mnt_opts(const struct super_block *oldsb,
+int security_sb_clone_mnt_opts(const struct super_block *oldsb,
 				struct super_block *newsb)
 {
-	security_ops->sb_clone_mnt_opts(oldsb, newsb);
+	return security_ops->sb_clone_mnt_opts(oldsb, newsb);
 }
 EXPORT_SYMBOL(security_sb_clone_mnt_opts);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fa28c8..3c02be3 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -750,7 +750,37 @@ out_double_mount:
 	goto out;
 }
 
-static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
+static int selinux_cmp_sb_context(const struct super_block *oldsb,
+				    const struct super_block *newsb)
+{
+	struct superblock_security_struct *old = oldsb->s_security;
+	struct superblock_security_struct *new = newsb->s_security;
+	char oldflags = old->flags & SE_MNTMASK;
+	char newflags = new->flags & SE_MNTMASK;
+
+	if (oldflags != newflags)
+		goto mismatch;
+	if ((oldflags & FSCONTEXT_MNT) && old->sid != new->sid)
+		goto mismatch;
+	if ((oldflags & CONTEXT_MNT) && old->mntpoint_sid != new->mntpoint_sid)
+		goto mismatch;
+	if ((oldflags & DEFCONTEXT_MNT) && old->def_sid != new->def_sid)
+		goto mismatch;
+	if (oldflags & ROOTCONTEXT_MNT) {
+		struct inode_security_struct *oldroot = oldsb->s_root->d_inode->i_security;
+		struct inode_security_struct *newroot = newsb->s_root->d_inode->i_security;
+		if (oldroot->sid != newroot->sid)
+			goto mismatch;
+	}
+	return 0;
+mismatch:
+	printk(KERN_WARNING "SELinux: mount invalid.  Same superblock, "
+			    "different security settings for (dev %s, "
+			    "type %s)\n", newsb->s_id, newsb->s_type->name);
+	return -EBUSY;
+}
+
+static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
 					struct super_block *newsb)
 {
 	const struct superblock_security_struct *oldsbsec = oldsb->s_security;
@@ -765,14 +795,14 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
 	 * mount options.  thus we can safely deal with this superblock later
 	 */
 	if (!ss_initialized)
-		return;
+		return 0;
 
 	/* how can we clone if the old one wasn't set up?? */
 	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
 
-	/* if fs is reusing a sb, just let its options stand... */
+	/* if fs is reusing a sb, make sure that the contexts match */
 	if (newsbsec->flags & SE_SBINITIALIZED)
-		return;
+		return selinux_cmp_sb_context(oldsb, newsb);
 
 	mutex_lock(&newsbsec->lock);
 
@@ -805,6 +835,7 @@ static void selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
 
 	sb_finish_set_opts(newsb);
 	mutex_unlock(&newsbsec->lock);
+	return 0;
 }
 
 static int selinux_parse_opts_str(char *options,
-- 
1.7.11.7


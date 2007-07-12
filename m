From: Eric Paris <eparis@redhat.com>
Subject: RFC: LSM/SELinux handling of mount options
Date: Thu, 12 Jul 2007 19:41:33 -0400
Message-ID: <1184283693.3510.123.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: steved@redhat.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	trond.myklebust@fys.uio.no, sds@tycho.nsa.gov
To: selinux@tycho.nsa.gov, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I98IH-0003kP-EE
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 16:42:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I98IJ-00014L-RW
	for nfs@lists.sourceforge.net; Thu, 12 Jul 2007 16:42:01 -0700
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

Do not commit to any tree!  This patch is busted and is only being
posted for comments on design!  I'll explain the problem below but I
don't see it in the code right offhand and if the whole design is going
to get crapped on I don't feel like digging into it.  If the design
looks reasonable to people it won't take me long to figure out what I
did wrong.

So there are 2 overarching problems this patch set it attempting to
solve or make later solutions easier.  

1) NFS uses binary mount data (for both normal and nohide/referral
mounts) which currently SELinux attempts to understand and use.  This
was declared a layering issue, no security module should have FS
specific data structure knowledge.  (Instead we have to put security
module specific knowledge into the FS since the FS 'owns' the mount
data, see below)

2) File systems own all of their mount options.  SELinux currently scans
through the text mount data of most filesystems and pulls out the key
options it understands, in the case of SELinux those are context=,
fscontext=, rootcontext=, defcontext=.  On these 2 lists it was stated
that the FS owns the options and mount data.  I don't try to remove all
handling of text mount data from SELinux but I am adding the
infrastructure for FS code to pass that data explicitly.  Future work
may eliminate the fact that security modules directly read and use text
mount data for their own purposes.

Someday this will be a 3 part patch.
1) add get/set_sb_sec_ops so an FS can get or set their own security
attributes.
2) add set_sec_ops to struct file_system_type to call out to FS specific
security module settings
3) make nfs use the get/set_sb_sec_ops code when doing nohide/referral
mounts.

LONG explanation below.

How does this patch work?  For submitting I'm going to break it up
probably into 3 parts.  The first part will add new LSM hooks and new
functionality where we can get or set the security information relevant
to a superblock (see selinux_set_mnt_opts).

static int selinux_set_mnt_opts(const struct super_block *sb,
                                char **mount_options, int *flags,
                                int num_opts)

mount_options is an array of strings which contain the actual security
data.  In the case of selinux this will be an array of selinux context
strings.  Flags is an array which tells which string is trying to set
which security relevant attribute.  These flags are global flags in
security.h of the form

#define SELINUX__FSCONTEXT_MNT_OPT      1

My convention is the first part will specify the security module, and
the second part will specify what it's for in that module.  Above I said
that SELinux had 4 mount options it cared about so there are currently 4
of these flags defined.  That example says this is for SELinux and we
are setting the FSCONTEXT SELinux mount options.

The last argument is num_opts which is simply how many security
parameters are being passed to this function.  Assume num_opts = 1.  We
look at flags[0] (say it equals 1) to find out what we are supposed to
set (fscontext), and then set it to the string at mount_options[0] (=
some context like system_u:object_r:type_t).  The get functions do the
opposite.  They return all of these arrays based on the information in
the given sb.  Now we have the infrastructure for a FS to set their own
security settings assuming they know what the security module below them
is.  (Big if and I'm not really solving that problem right now...
ifdefs?)

The second part of the patch will be the change to add

struct file_system_type {
	[....]
        int (*set_sec_ops) (struct vfsmount *mnt, void *mnt_ops);

Since now the FS owns the mount data the security layer needs a way to
tell the FS, "hey FS, now is the time for you to set the security
information on this vfsmount, and here is the mount data you sent our
way but we don't understand."  The only user I see for this at the
moment is NFS.  But others may use this if they don't continue to just
let SELinux grep the security information from the text mount data.  NFS
will set the NFS specific

	.set_sec_ops = nfs_set_sec_ops;

Inside vfs_kern_mount we can call back out and get NFS to set its
security settings (using the new LSM hooks above).  Obviously this is
the point where the FS now has to have security module specific
information.  If NFS is going to own the mount options and the mount
options are security module specific some level of security module
knowledge must exist.  This is easy on NFS, it only understands context=
and only has a ->context field in the nfs_mount_data so this can be hard
coded.  Right now I think this function will bust without SELinux below
it, but that's an easy fix to just handle the return from a call to
security_sb_set_mnt_opts if it is a no-op.

This set_sec_ops pointer would be null on all FS's which didn't need
this call back and wouldn't do anything.

At this point we should have the same functionality we have today, but
should have gone a lot of the way towards solving problem 2.  Other FS's
which want to own their mount data completely could switch to start
using this infrastructure.

part 3 and now the real reason I started to look at this, NFS referral
and nohide mounts which use nfs_clone_mount instead of nfs_mount_data.
The fix for this is to actually change nfs_do_clone_mount() to get the
security relevant information on the parent superblock, mount the new
'child,' and then set that security information onto the child.  All of
this security getting/setting data is actually opaque to NFS and it
doesn't matter what the underlying security module is (or if there even
is one once i handle return codes better)

I said there was a problem right?  The root inode is not getting the
label specified in the mount options.  I'm not sure why but in the case
of NFS I always get nfs_t on the root inode instead of the label I
explicitly set for the rest of the mount point.  I thought that would be
fixed by setting rootcontext in my set_mnt_opts() function but it isn't
working and I don't see the issue offhand.  Obviously this will be fixed
before I considered posting for people to look at again.  You can
actually run and test with this code, just note that your root inode is
going to be labeled wrong....

Anyway, here is the single patch.  I'd like to hear comments on my
design (and my code but don't get picky, its got a long way to go, see
all those printk's and dump_stacks?  those are bad, don't tell me)

-Eric

 fs/nfs/client.c          |   18 +++
 fs/nfs/namespace.c       |   27 +++-
 fs/nfs/super.c           |   44 ++++++
 fs/super.c               |    5 +
 include/linux/fs.h       |    1 +
 include/linux/security.h |   54 +++++++-
 security/dummy.c         |   19 +++
 security/selinux/hooks.c |  379 +++++++++++++++++++++++++++++++---------------
 8 files changed, 422 insertions(+), 125 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 881fa49..1d124ad 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -532,6 +532,13 @@ static int nfs_init_client(struct nfs_client *clp, const struct nfs_mount_data *
 	int proto = (data->flags & NFS_MOUNT_TCP) ? IPPROTO_TCP : IPPROTO_UDP;
 	int error;
 
+	printk(KERN_CRIT "%s: called.  mount data is: ", __FUNCTION__);
+	if (data && data->context)
+		printk("%s\n", data->context);
+	else
+		printk("NULL\n");
+	dump_stack();
+
 	if (clp->cl_cons_state == NFS_CS_READY) {
 		/* the client is already initialised */
 		dprintk("<-- nfs_init_client() = 0 [already %p]\n", clp);
@@ -569,6 +576,11 @@ static int nfs_init_server(struct nfs_server *server, const struct nfs_mount_dat
 	struct nfs_client *clp;
 	int error, nfsvers = 2;
 
+        printk(KERN_CRIT "%s: called.  mount data is: ", __FUNCTION__);
+        if (data && data->context)
+                printk("%s\n", data->context);
+        else
+                printk("NULL\n");
 	dprintk("--> nfs_init_server()\n");
 
 #ifdef CONFIG_NFS_V3
@@ -803,6 +815,12 @@ struct nfs_server *nfs_create_server(const struct nfs_mount_data *data,
 	struct nfs_fattr fattr;
 	int error;
 
+        printk(KERN_CRIT "%s: called.  mount data is: ", __FUNCTION__);
+        if (data && data->context)
+                printk(KERN_CRIT "%s\n", data->context);
+        else
+                printk(KERN_CRIT "NULL\n");
+
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 7f86e65..6436be0 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -11,6 +11,7 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/nfs_fs.h>
+#include <linux/security.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/vfs.h>
@@ -188,8 +189,18 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 					   const char *devname,
 					   struct nfs_clone_mount *mountdata)
 {
-#ifdef CONFIG_NFS_V4
+	int rc = 0, num_sec_mnt_opts = 0, i;
+	char **sec_mnt_opts;
+	int *sec_mnt_flags;
 	struct vfsmount *mnt = NULL;
+
+	sec_mnt_opts = NULL;
+	sec_mnt_flags = NULL;
+	rc = security_sb_get_mnt_opts(mountdata->sb, &sec_mnt_opts,
+				      &sec_mnt_flags, &num_sec_mnt_opts);
+	if (rc)
+		return ERR_PTR(rc);
+#ifdef CONFIG_NFS_V4
 	switch (server->nfs_client->cl_nfsversion) {
 		case 2:
 		case 3:
@@ -198,10 +209,20 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 		case 4:
 			mnt = vfs_kern_mount(&nfs4_xdev_fs_type, 0, devname, mountdata);
 	}
-	return mnt;
 #else
-	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
+	mnt = vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
 #endif
+	if (mnt) {
+		security_sb_set_mnt_opts(mnt->mnt_sb, sec_mnt_opts,
+					 sec_mnt_flags, num_sec_mnt_opts);
+	}
+	if (sec_mnt_opts) {
+		for (i = 0; i < num_sec_mnt_opts; i++)
+			kfree(sec_mnt_opts[i]);
+		kfree(sec_mnt_opts);
+		kfree(sec_mnt_flags);
+	}
+	return mnt;
 }
 
 /**
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ca20d3c..c7dcfba 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -37,6 +37,7 @@
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
+#include <linux/security.h>
 #include <linux/smp_lock.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
@@ -65,6 +66,7 @@ static int nfs_get_sb(struct file_system_type *, int, const char *, void *, stru
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
+static int nfs_set_sec_ops(struct vfsmount *mnt, void *mnt_ops);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -72,6 +74,7 @@ static struct file_system_type nfs_fs_type = {
 	.get_sb		= nfs_get_sb,
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.set_sec_ops	= nfs_set_sec_ops,
 };
 
 struct file_system_type nfs_xdev_fs_type = {
@@ -440,6 +443,12 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 static int nfs_validate_mount_data(struct nfs_mount_data *data,
 				   struct nfs_fh *mntfh)
 {
+        printk(KERN_CRIT "%s: called.  mount data is: ", __FUNCTION__);
+        if (data && data->context)
+                printk(KERN_CRIT "%s\n", data->context);
+        else
+                printk(KERN_CRIT "NULL\n");
+
 	if (data == NULL) {
 		dprintk("%s: missing data argument\n", __FUNCTION__);
 		return -EINVAL;
@@ -543,6 +552,11 @@ static void nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
+        if (data && data->context && data->context[0])
+        	printk(KERN_CRIT "%s: called.  mount data is: %s\n", __FUNCTION__, data->context);
+        else
+        	printk(KERN_CRIT "%s: called.  mount data is: NULL\n", __FUNCTION__);
+
 	sb->s_blocksize_bits = 0;
 	sb->s_blocksize = 0;
 	if (data->bsize)
@@ -617,6 +631,12 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	struct dentry *mntroot;
 	int error;
 
+	printk(KERN_CRIT "%s: called.  mount data is: ", __FUNCTION__);
+        if (data && data->context[0])
+                printk(KERN_CRIT "%s\n", data->context);
+        else
+                printk(KERN_CRIT "NULL\n");
+
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(data, &mntfh);
 	if (error < 0)
@@ -746,6 +766,30 @@ error_splat_super:
 	return error;
 }
 
+/*
+ * since nfs only supports the context= security string a lot of this is hard
+ * coded to 1.  If others mount opts are added this will get a bit more complex.
+ */
+static int nfs_set_sec_ops(struct vfsmount *mnt, void *mnt_ops)
+{
+	struct nfs_mount_data *nfs_ops = (struct nfs_mount_data *)mnt_ops;
+	char *contexts[1];
+	int mnt_ops_flags[1];
+	int rc = 0;
+
+	if (nfs_ops->context)
+		printk(KERN_CRIT "%s: nfs_ops->context=%s\n", __FUNCTION__, nfs_ops->context);
+	/* no security data in the nfs_mount_data */
+	if ((nfs_ops->version < 6) || !nfs_ops->context[0])
+		return 0;
+
+	contexts[0] = nfs_ops->context;
+	mnt_ops_flags[0] = SELINUX__CONTEXT_MNT_OPT;
+
+	rc = security_sb_set_mnt_opts(mnt->mnt_sb, contexts, mnt_ops_flags, 1);
+	return rc;
+}
+
 #ifdef CONFIG_NFS_V4
 
 /*
diff --git a/fs/super.c b/fs/super.c
index 5260d62..b555d61 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -889,6 +889,11 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
  	if (error)
  		goto out_sb;
 
+	if (type->set_sec_ops && data) {
+		error = type->set_sec_ops(mnt, data);
+		if (error)
+			goto out_sb;
+	}
 	mnt->mnt_mountpoint = mnt->mnt_root;
 	mnt->mnt_parent = mnt;
 	up_write(&mnt->mnt_sb->s_umount);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b3ae77c..ed6e0f2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1371,6 +1371,7 @@ struct file_system_type {
 	struct list_head fs_supers;
 	struct lock_class_key s_lock_key;
 	struct lock_class_key s_umount_key;
+	int (*set_sec_ops) (struct vfsmount *mnt, void *mnt_ops);
 };
 
 extern int get_sb_bdev(struct file_system_type *fs_type,
diff --git a/include/linux/security.h b/include/linux/security.h
index 9eb9e0f..854b2b6 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -34,6 +34,11 @@
 #include <linux/xfrm.h>
 #include <net/flow.h>
 
+#define SELINUX__FSCONTEXT_MNT_OPT			1
+#define SELINUX__CONTEXT_MNT_OPT			2
+#define SELINUX__ROOTCONTEXT_MNT_OPT			3
+#define SELINUX__DEFCONTEXT_MNT_OPT			4
+
 struct ctl_table;
 
 /*
@@ -247,6 +252,18 @@ struct request_sock;
  *	Update module state after a successful pivot.
  *	@old_nd contains the nameidata structure for the old root.
  *      @new_nd contains the nameidata structure for the new root.
+ * @sb_get_mount_options:
+ *      Get the security relevant mount options used for a superblock
+ *      @sb the superblock to get security mount options from
+ *      @mount_options array for pointers to mount options
+ *      @mount_flags array of ints specifying what each mount options is
+ *      @num_opts number of options in the arrays
+ * @sb_set_mount_options:
+ *      Set the security relevant mount options used for a superblock
+ *      @sb the superblock to set security mount options for
+ *      @mount_options array for pointers to mount options
+ *      @mount_flags array of ints specifying what each mount options is
+ *      @num_opts number of options in the arrays
  *
  * Security hooks for inode operations.
  *
@@ -1199,7 +1216,11 @@ struct security_operations {
 			     struct nameidata * new_nd);
 	void (*sb_post_pivotroot) (struct nameidata * old_nd,
 				   struct nameidata * new_nd);
-
+	int (*sb_get_mnt_opts) (const struct super_block *sb,
+				char ***mount_options, int **flags,
+				int *num_opts);
+	int (*sb_set_mnt_opts) (struct super_block *sb, char **mount_options,
+				int *flags, int num_opts);
 	int (*inode_alloc_security) (struct inode *inode);	
 	void (*inode_free_security) (struct inode *inode);
 	int (*inode_init_security) (struct inode *inode, struct inode *dir,
@@ -1587,6 +1608,20 @@ static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
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
 static inline int security_inode_alloc (struct inode *inode)
 {
 	inode->i_security = NULL;
@@ -2319,6 +2354,23 @@ static inline void security_sb_post_pivotroot (struct nameidata *old_nd,
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
 static inline int security_inode_alloc (struct inode *inode)
 {
 	return 0;
diff --git a/security/dummy.c b/security/dummy.c
index 8ffd764..f4644ff 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -248,6 +248,23 @@ static void dummy_sb_post_pivotroot (struct nameidata *old_nd, struct nameidata
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
 static int dummy_inode_alloc_security (struct inode *inode)
 {
 	return 0;
@@ -992,6 +1009,8 @@ void security_fixup_ops (struct security_operations *ops)
 	set_to_dummy_if_null(ops, sb_post_addmount);
 	set_to_dummy_if_null(ops, sb_pivotroot);
 	set_to_dummy_if_null(ops, sb_post_pivotroot);
+	set_to_dummy_if_null(ops, sb_get_mnt_opts);
+	set_to_dummy_if_null(ops, sb_set_mnt_opts);
 	set_to_dummy_if_null(ops, inode_alloc_security);
 	set_to_dummy_if_null(ops, inode_free_security);
 	set_to_dummy_if_null(ops, inode_init_security);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index ad8dd4e..9591536 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -362,135 +362,122 @@ static int may_context_mount_inode_relabel(u32 sid,
 	return rc;
 }
 
-static int try_context_mount(struct super_block *sb, void *data)
+/*
+ * This function should allow an FS (like NFS) to ask what it's mount security
+ * options were so it can use those later for submounts and the like
+ */
+static int selinux_get_mnt_opts(const struct super_block *sb,
+				char ***mount_options, int **flags,
+				int *num_opts)
 {
-	char *context = NULL, *defcontext = NULL;
-	char *fscontext = NULL, *rootcontext = NULL;
-	const char *name;
-	u32 sid;
-	int alloc = 0, rc = 0, seen = 0;
-	struct task_security_struct *tsec = current->security;
+	int rc = 0, i;
 	struct superblock_security_struct *sbsec = sb->s_security;
+	/* rootcontext is not applicable to submounts, the only known user... */
+	char *fscontext = NULL, *context = NULL;
+	char *defcontext = NULL;
+	u32 len;
 
-	if (!data)
-		goto out;
+	*num_opts = 0;
+	*mount_options = NULL;
+	*flags = NULL;
 
-	name = sb->s_type->name;
-
-	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
+	if (sbsec->sid) {
+		rc = security_sid_to_context(sbsec->sid, &fscontext, &len);
+		if (rc)
+			goto out_free;
+		*num_opts += 1;
+	}
 
-		/* NFS we understand. */
-		if (!strcmp(name, "nfs")) {
-			struct nfs_mount_data *d = data;
+	if (sbsec->mntpoint_sid) {
+		rc = security_sid_to_context(sbsec->mntpoint_sid, &context, &len);
+		if (rc)
+			goto out_free;
+		*num_opts += 1;
+	}
 
-			if (d->version <  NFS_MOUNT_VERSION)
-				goto out;
+	if (sbsec->def_sid) {
+		rc = security_sid_to_context(sbsec->def_sid, &defcontext, &len);
+		if (rc)
+			goto out_free;
+		*num_opts += 1;
+	}
 
-			if (d->context[0]) {
-				context = d->context;
-				seen |= Opt_context;
-			}
-		} else
-			goto out;
+	*mount_options = kcalloc(*num_opts, sizeof(char *), GFP_ATOMIC);
+	if (!*mount_options) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
 
-	} else {
-		/* Standard string-based options. */
-		char *p, *options = data;
+	*flags = kcalloc(*num_opts, sizeof(int), GFP_ATOMIC);
+	if (!*flags) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
 
-		while ((p = strsep(&options, "|")) != NULL) {
-			int token;
-			substring_t args[MAX_OPT_ARGS];
+	i = 0;
+	if(fscontext) {
+		(*mount_options)[i] = fscontext;
+		(*flags)[i++] = SELINUX__FSCONTEXT_MNT_OPT;
+	}
 
-			if (!*p)
-				continue;
+	if(context) {
+		(*mount_options)[i] = context;
+		(*flags)[i++] = SELINUX__CONTEXT_MNT_OPT;
+	}
 
-			token = match_token(p, tokens, args);
+	if(defcontext) {
+		(*mount_options)[i] = defcontext;
+		(*flags)[i++] = SELINUX__DEFCONTEXT_MNT_OPT;
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
+	kfree(*mount_options);
+	kfree(*flags);
+	kfree(fscontext);
+	kfree(context);
+	kfree(defcontext);
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
+	printk(KERN_CRIT "%s: with num_opts = %d\n", __FUNCTION__, num_opts);
 
-			}
+	for(i = 0; i < num_opts; i++) {
+		switch(flags[i]) {
+		case SELINUX__FSCONTEXT_MNT_OPT:
+			fscontext = mount_options[i];
+			break;
+		case SELINUX__CONTEXT_MNT_OPT:
+			context = mount_options[i];
+			break;
+		case SELINUX__ROOTCONTEXT_MNT_OPT:
+			rootcontext = mount_options[i];
+			break;
+		case SELINUX__DEFCONTEXT_MNT_OPT:
+			defcontext = mount_options[i];
+			break;
+		default:
+			return -EINVAL;
 		}
 	}
-
-	if (!seen)
-		goto out;
-
 	/* sets the context of the superblock for the fs being mounted. */
 	if (fscontext) {
 		rc = security_context_to_sid(fscontext, strlen(fscontext), &sid);
@@ -498,12 +485,12 @@ static int try_context_mount(struct super_block *sb, void *data)
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       fscontext, sb->s_id, name, rc);
-			goto out_free;
+			return rc;
 		}
 
 		rc = may_context_mount_sb_relabel(sid, sbsec, tsec);
 		if (rc)
-			goto out_free;
+			return rc;
 
 		sbsec->sid = sid;
 	}
@@ -514,43 +501,54 @@ static int try_context_mount(struct super_block *sb, void *data)
 	 * the superblock context if not already set.
 	 */
 	if (context) {
+		printk(KERN_CRIT "%s: inside context= block with context=%s\n", __FUNCTION__, context);
 		rc = security_context_to_sid(context, strlen(context), &sid);
 		if (rc) {
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       context, sb->s_id, name, rc);
-			goto out_free;
+			return rc;
 		}
 
 		if (!fscontext) {
 			rc = may_context_mount_sb_relabel(sid, sbsec, tsec);
 			if (rc)
-				goto out_free;
+				return rc;
 			sbsec->sid = sid;
 		} else {
 			rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
 			if (rc)
-				goto out_free;
+				return rc;
 		}
-		sbsec->mntpoint_sid = sid;
+		/* 
+		 * On a MNTPOINT labeled FS there is no harm in explicitly
+		 * setting the root inode label.  This is especially useful
+		 * if the root inode has already been created while the fs
+		 * may have still been genfs, as is the case with NFS, and 
+		 * other FS which calls directly into the set sec ops function
+		 */
+		if (!rootcontext)
+			rootcontext = context;
 
+		sbsec->mntpoint_sid = sid;
 		sbsec->behavior = SECURITY_FS_USE_MNTPOINT;
 	}
 
 	if (rootcontext) {
 		struct inode *inode = sb->s_root->d_inode;
 		struct inode_security_struct *isec = inode->i_security;
+		printk(KERN_CRIT "%s: inside rootcontext= block with rootcontext=%s\n", __FUNCTION__, rootcontext);
 		rc = security_context_to_sid(rootcontext, strlen(rootcontext), &sid);
 		if (rc) {
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       rootcontext, sb->s_id, name, rc);
-			goto out_free;
+			return rc;
 		}
 
 		rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
 		if (rc)
-			goto out_free;
+			return rc;
 
 		isec->sid = sid;
 		isec->initialized = 1;
@@ -562,18 +560,155 @@ static int try_context_mount(struct super_block *sb, void *data)
 			printk(KERN_WARNING "SELinux: security_context_to_sid"
 			       "(%s) failed for (dev %s, type %s) errno=%d\n",
 			       defcontext, sb->s_id, name, rc);
-			goto out_free;
+			return rc;
 		}
 
 		if (sid == sbsec->def_sid)
-			goto out_free;
+			return rc;
 
 		rc = may_context_mount_inode_relabel(sid, sbsec, tsec);
 		if (rc)
-			goto out_free;
+			return rc;
 
 		sbsec->def_sid = sid;
 	}
+	return 0;
+}
+
+static int try_context_mount(struct super_block *sb, void *data)
+{
+	char *context = NULL, *defcontext = NULL;
+	char *fscontext = NULL, *rootcontext = NULL;
+	const char *name;
+	int alloc = 0, rc = 0, seen = 0;
+	struct superblock_security_struct *sbsec = sb->s_security;
+	char *p, *options = data;
+	char *mnt_opts[4];
+	int mnt_opts_flags[4], num_mnt_opts = 0;
+
+	if (!data)
+		goto out;
+
+	if (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA) {
+		printk(KERN_CRIT "%s: with FS_BINARY_MOUNTDATA\n", __FUNCTION__);
+		dump_stack();
+		goto out;
+	}
+
+	/* Standard string-based options. */
+
+	name = sb->s_type->name;
+
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
+			if (seen & (Opt_context|Opt_defcontext)) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_free;
+			}
+			context = match_strdup(&args[0]);
+			if (!context) {
+				rc = -ENOMEM;
+				goto out_free;
+			}
+			if (!alloc)
+				alloc = 1;
+			seen |= Opt_context;
+			break;
+
+		case Opt_fscontext:
+			if (seen & Opt_fscontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_free;
+			}
+			fscontext = match_strdup(&args[0]);
+			if (!fscontext) {
+				rc = -ENOMEM;
+				goto out_free;
+			}
+			if (!alloc)
+				alloc = 1;
+			seen |= Opt_fscontext;
+			break;
+
+		case Opt_rootcontext:
+			if (seen & Opt_rootcontext) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+				goto out_free;
+			}
+			rootcontext = match_strdup(&args[0]);
+			if (!rootcontext) {
+				rc = -ENOMEM;
+				goto out_free;
+			}
+			if (!alloc)
+				alloc = 1;
+			seen |= Opt_rootcontext;
+			break;
+
+		case Opt_defcontext:
+			if (sbsec->behavior != SECURITY_FS_USE_XATTR) {
+				rc = -EINVAL;
+				printk(KERN_WARNING "SELinux:  "
+				       "defcontext option is invalid "
+				       "for this filesystem type\n");
+				goto out_free;
+			}
+			if (seen & (Opt_context|Opt_defcontext)) {
+				rc = -EINVAL;
+				printk(KERN_WARNING SEL_MOUNT_FAIL_MSG);
+					goto out_free;
+			}
+			defcontext = match_strdup(&args[0]);
+			if (!defcontext) {
+				rc = -ENOMEM;
+				goto out_free;
+			}
+			if (!alloc)
+				alloc = 1;
+			seen |= Opt_defcontext;
+			break;
+
+		default:
+			rc = -EINVAL;
+			printk(KERN_WARNING "SELinux:  unknown mount option\n");
+			goto out_free;
+
+		}
+	}
+
+	if (!seen)
+		goto out;
+
+	if(fscontext){
+		mnt_opts[num_mnt_opts] = fscontext;
+		mnt_opts_flags[num_mnt_opts++] = SELINUX__FSCONTEXT_MNT_OPT;
+	}
+	if(context){
+		mnt_opts[num_mnt_opts] = context;
+		mnt_opts_flags[num_mnt_opts++] = SELINUX__CONTEXT_MNT_OPT;
+	}
+	if(rootcontext){
+		mnt_opts[num_mnt_opts] = rootcontext;
+		mnt_opts_flags[num_mnt_opts++] = SELINUX__ROOTCONTEXT_MNT_OPT;
+	}
+	if(defcontext){
+		mnt_opts[num_mnt_opts] = defcontext;
+		mnt_opts_flags[num_mnt_opts++] = SELINUX__DEFCONTEXT_MNT_OPT;
+	}
+
+	rc = selinux_set_mnt_opts(sb, mnt_opts, mnt_opts_flags, num_mnt_opts);
 
 out_free:
 	if (alloc) {
@@ -4741,6 +4876,8 @@ static struct security_operations selinux_ops = {
 	.sb_statfs =			selinux_sb_statfs,
 	.sb_mount =			selinux_mount,
 	.sb_umount =			selinux_umount,
+	.sb_get_mnt_opts =		selinux_get_mnt_opts,
+	.sb_set_mnt_opts =		selinux_set_mnt_opts,
 
 	.inode_alloc_security =		selinux_inode_alloc_security,
 	.inode_free_security =		selinux_inode_free_security,



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

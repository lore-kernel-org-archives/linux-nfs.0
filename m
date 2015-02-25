From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Subject: [RFC 00/21] Richacls
Date: Thu, 26 Feb 2015 00:31:02 +0100
Message-ID: <cover.1424900921.git.agruenba@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

here is an updated richacl patch queue, also available in git [1].  For those
who might not know, richacls are an implementation of NFSv4 ACLs that cleanly
integrates into the POSIX file permission model.  The goal is to improve
interoperability between Linux and other systems, mainly across the NFSv4 and
CIFS/SMB protocols.  A file system can either contain posix acls or richacls,
but not both.

This patch queue includes the vfs and ext4 changes needed for local richacl
support.  A previous version of this patch queue was last posted about a year
ago [2]; I have updated the patches to v4.0-rc1 and tried to incorporate the
feedback from the previous discussion.  The changes include:

 * Introduction of a base_acl object type so that an inode can either cache
   a posix acl or a richacl largely without caring which of the two kinds
   it is dealing with.

 * RCU support as for posix acls.

 * Various cleanups and more documentation.

Things I'm not entirely happy with:

 * A new get_richacl inode operation is introduced.  This is needed because
   we need to perform permission checks in contexts where the dentry of the
   inode to check is not available and we cannot use the getxattr inode
   operation.  It would be nice if we could either convert the getxattr inode
   operation to take an inode instead, or pass the dentries down to where
   the get_richacl inode operation is currently used.

 * The base_acl code is rather ugly; maybe the previous version which was
   criticized wasn't so bad after all.

 * It would be nice if the MAY_DELETE_SELF flag could override the sticky
   directory check as it did in the previous version of this patch queue.  I
   couldn't come up with a clean way of achieving that, though.

Because the code has changed quite a bit since the last posting, I have removed
the previous sign-offs.

At this point, I would like to ask for your feedback as to what should be
changed before these patches can be merged, even if merging these patches alone
doesn't make a while lot of sense.  I will follow up with additional pieces to
the puzzle like the nfsv4 support as I get them into shape again.

--

Which kind of acls an ext4 file system supports is determined by the "richacl"
ext4 feature (mkfs.ext4 -O richacl or tune2fs -O richacl).  The file system
also needs to be mounted with the "acl" mount option, which is the default
nowadays.

A version of e2fsprogs with support for the "richacl" feature can be found on
github [3], but the feature can also be enabled "hard" in debugfs.  Note that
unpatched versions of e2fsck will not check file systems with the feature
enabled though.

The acls themselves can be manipulated with the richacl command-line utility
[4].  Some details on the permission model and examples of its use can be found
at the richacl page, http://acl.bestbits.at/richacl/.

 [1] git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git richacl
 [2] http://lwn.net/Articles/596517/
 [3] https://github.com/andreas-gruenbacher/e2fsprogs
 [4] https://github.com/andreas-gruenbacher/richacl

Thanks,
Andreas

--

Andreas Gruenbacher (19):
  vfs: Minor documentation fix
  vfs: Shrink struct posix_acl
  vfs: Add IS_ACL() and IS_RICHACL() tests
  vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR permission flags
  vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD permission flags
  vfs: Make the inode passed to inode_change_ok non-const
  vfs: Add permission flags for setting file attributes
  richacl: In-memory representation and helper functions
  richacl: Permission mapping functions
  richacl: Compute maximum file masks from an acl
  richacl: Update the file masks in chmod()
  richacl: Permission check algorithm
  richacl: Create-time inheritance
  richacl: Check if an acl is equivalent to a file mode
  richacl: Automatic Inheritance
  richacl: xattr mapping functions
  vfs: Cache base_acl objects in inodes
  vfs: Cache richacl in struct inode
  vfs: Add richacl permission checking

Aneesh Kumar K.V (2):
  ext4: Implement rich acl for ext4
  ext4: Add richacl feature flag

 Documentation/filesystems/porting               |   8 +-
 Documentation/filesystems/vfs.txt               |   3 +
 drivers/staging/lustre/lustre/llite/llite_lib.c |   2 +-
 fs/Kconfig                                      |   3 +
 fs/Makefile                                     |   2 +
 fs/attr.c                                       |  81 ++-
 fs/ext4/Kconfig                                 |  15 +
 fs/ext4/Makefile                                |   1 +
 fs/ext4/acl.c                                   |   7 +-
 fs/ext4/acl.h                                   |  12 +-
 fs/ext4/ext4.h                                  |   6 +-
 fs/ext4/file.c                                  |   6 +-
 fs/ext4/ialloc.c                                |   7 +-
 fs/ext4/inode.c                                 |  10 +-
 fs/ext4/namei.c                                 |  11 +-
 fs/ext4/richacl.c                               | 229 ++++++++
 fs/ext4/richacl.h                               |  47 ++
 fs/ext4/super.c                                 |  41 +-
 fs/ext4/xattr.c                                 |   6 +
 fs/ext4/xattr.h                                 |   1 +
 fs/f2fs/acl.c                                   |   4 +-
 fs/inode.c                                      |  15 +-
 fs/namei.c                                      | 108 +++-
 fs/posix_acl.c                                  |  31 +-
 fs/richacl_base.c                               | 660 ++++++++++++++++++++++++
 fs/richacl_inode.c                              |  67 +++
 fs/richacl_xattr.c                              | 131 +++++
 include/linux/fs.h                              |  47 +-
 include/linux/posix_acl.h                       |  12 +-
 include/linux/richacl.h                         | 329 ++++++++++++
 include/linux/richacl_xattr.h                   |  47 ++
 include/uapi/linux/fs.h                         |   3 +-
 32 files changed, 1844 insertions(+), 108 deletions(-)
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h
 create mode 100644 fs/richacl_base.c
 create mode 100644 fs/richacl_inode.c
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/richacl.h
 create mode 100644 include/linux/richacl_xattr.h

-- 
2.1.0

>From a7ae9dc44b9772622cb5d17b142a43cea2d18d10 Mon Sep 17 00:00:00 2001
Message-Id: <a7ae9dc44b9772622cb5d17b142a43cea2d18d10.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 4 Feb 2015 15:47:36 +0100
Subject: [RFC 01/21] vfs: Minor documentation fix
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

The check_acl inode operation and the IPERM_FLAG_RCU are long gone.
Document what get_acl does instead.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 Documentation/filesystems/porting | 8 ++++----
 Documentation/filesystems/vfs.txt | 3 +++
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index fa2db08..d6f9ab4 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -379,10 +379,10 @@ may now be called in rcu-walk mode (nd->flags & LOOKUP_RCU). -ECHILD should be
 returned if the filesystem cannot handle rcu-walk. See
 Documentation/filesystems/vfs.txt for more details.
 
-	permission and check_acl are inode permission checks that are called
-on many or all directory inodes on the way down a path walk (to check for
-exec permission). These must now be rcu-walk aware (flags & IPERM_FLAG_RCU).
-See Documentation/filesystems/vfs.txt for more details.
+	permission is an inode permission check that is called on many or all
+directory inodes on the way down a path walk (to check for exec permission). It
+must now be rcu-walk aware (mask & MAY_NOT_BLOCK).  See
+Documentation/filesystems/vfs.txt for more details.
  
 --
 [mandatory]
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 966b228..700cdf6 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -457,6 +457,9 @@ otherwise noted.
 	If a situation is encountered that rcu-walk cannot handle, return
 	-ECHILD and it will be called again in ref-walk mode.
 
+  get_acl: called by the VFS to get the posix acl of an inode. Called during
+	permission checks. The returned acl is cached in the inode.
+
   setattr: called by the VFS to set attributes for a file. This method
   	is called by chmod(2) and related system calls.
 
-- 
2.1.0


>From d89155579f576fbe07756462212365f678afdb75 Mon Sep 17 00:00:00 2001
Message-Id: <d89155579f576fbe07756462212365f678afdb75.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 4 Feb 2015 14:46:15 +0100
Subject: [RFC 02/21] vfs: Shrink struct posix_acl
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

There is a hole in struct posix_acl because its struct rcu_head member is too
large; at least on on 64-bit architectures, the hole cannot be closed by
changing the definition of struct posix_acl. So instead, remove the struct
rcu_head member from struct posix_acl, make sure that acls are always big
enough to fit a struct rcu_head, and cast to struct rcu_head * when disposing
of an acl.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/posix_acl.c            | 5 +++--
 include/linux/posix_acl.h | 7 ++-----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 3a48bb7..efe983e 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -140,8 +140,9 @@ EXPORT_SYMBOL(posix_acl_init);
 struct posix_acl *
 posix_acl_alloc(int count, gfp_t flags)
 {
-	const size_t size = sizeof(struct posix_acl) +
-	                    count * sizeof(struct posix_acl_entry);
+	const size_t size = max(sizeof(struct rcu_head),
+		sizeof(struct posix_acl) +
+		count * sizeof(struct posix_acl_entry));
 	struct posix_acl *acl = kmalloc(size, flags);
 	if (acl)
 		posix_acl_init(acl, count);
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 3e96a6a..66cf477 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -43,10 +43,7 @@ struct posix_acl_entry {
 };
 
 struct posix_acl {
-	union {
-		atomic_t		a_refcount;
-		struct rcu_head		a_rcu;
-	};
+	atomic_t		a_refcount;
 	unsigned int		a_count;
 	struct posix_acl_entry	a_entries[0];
 };
@@ -73,7 +70,7 @@ static inline void
 posix_acl_release(struct posix_acl *acl)
 {
 	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		kfree_rcu(acl, a_rcu);
+		__kfree_rcu((struct rcu_head *)acl, 0);
 }
 
 
-- 
2.1.0


>From 611a0b6fe640f6d4ff7bb98931edf8c2fe81471c Mon Sep 17 00:00:00 2001
Message-Id: <611a0b6fe640f6d4ff7bb98931edf8c2fe81471c.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 00:19:53 +0530
Subject: [RFC 03/21] vfs: Add IS_ACL() and IS_RICHACL() tests
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

The vfs does not apply the umask for file systems that support acls. The test
used for this used to be called IS_POSIXACL(). Switch to a new IS_ACL() test to
check for either posix acls or richacls instead. Add a new MS_RICHACL flag and
IS_RICHACL() test for richacls alone. The IS_POSIXACL() test is still needed
by file systems that specifically support POSIX ACLs, like nfsd.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Kconfig              |  3 +++
 fs/namei.c              |  8 ++++----
 include/linux/fs.h      | 12 ++++++++++++
 include/uapi/linux/fs.h |  3 ++-
 4 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index ec35851..8b84f99 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -58,6 +58,9 @@ endif # BLOCK
 config FS_POSIX_ACL
 	def_bool n
 
+config FS_RICHACL
+	def_bool n
+
 config EXPORTFS
 	tristate
 
diff --git a/fs/namei.c b/fs/namei.c
index c83145a..0ba4bbc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2696,7 +2696,7 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
 	}
 
 	mode = op->mode;
-	if ((open_flag & O_CREAT) && !IS_POSIXACL(dir))
+	if ((open_flag & O_CREAT) && !IS_ACL(dir))
 		mode &= ~current_umask();
 
 	excl = (open_flag & (O_EXCL | O_CREAT)) == (O_EXCL | O_CREAT);
@@ -2880,7 +2880,7 @@ static int lookup_open(struct nameidata *nd, struct path *path,
 	/* Negative dentry, just create the file */
 	if (!dentry->d_inode && (op->open_flag & O_CREAT)) {
 		umode_t mode = op->mode;
-		if (!IS_POSIXACL(dir->d_inode))
+		if (!IS_ACL(dir->d_inode))
 			mode &= ~current_umask();
 		/*
 		 * This write is needed to ensure that a
@@ -3481,7 +3481,7 @@ retry:
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
+	if (!IS_ACL(path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = security_path_mknod(&path, dentry, mode, dev);
 	if (error)
@@ -3550,7 +3550,7 @@ retry:
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
+	if (!IS_ACL(path.dentry->d_inode))
 		mode &= ~current_umask();
 	error = security_path_mkdir(&path, dentry, mode);
 	if (!error)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b4d71b5..f64eb45 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1708,6 +1708,12 @@ struct super_operations {
 #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
 #define IS_POSIXACL(inode)	__IS_FLG(inode, MS_POSIXACL)
 
+#ifdef CONFIG_FS_RICHACL
+#define IS_RICHACL(inode)	__IS_FLG(inode, MS_RICHACL)
+#else
+#define IS_RICHACL(inode)	0
+#endif
+
 #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
 #define IS_SWAPFILE(inode)	((inode)->i_flags & S_SWAPFILE)
@@ -1721,6 +1727,12 @@ struct super_operations {
 				 (inode)->i_rdev == WHITEOUT_DEV)
 
 /*
+ * IS_ACL() tells the VFS to not apply the umask
+ * and use check_acl for acl permission checks when defined.
+ */
+#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL | MS_RICHACL)
+
+/*
  * Inode state bits.  Protected by inode->i_lock
  *
  * Three bits determine the dirty state of the inode, I_DIRTY_SYNC,
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 9b964a5..6ac6bc9 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -81,7 +81,7 @@ struct inodes_stat_t {
 #define MS_VERBOSE	32768	/* War is peace. Verbosity is silence.
 				   MS_VERBOSE is deprecated. */
 #define MS_SILENT	32768
-#define MS_POSIXACL	(1<<16)	/* VFS does not apply the umask */
+#define MS_POSIXACL	(1<<16)	/* Supports POSIX ACLs */
 #define MS_UNBINDABLE	(1<<17)	/* change to unbindable */
 #define MS_PRIVATE	(1<<18)	/* change to private */
 #define MS_SLAVE	(1<<19)	/* change to slave */
@@ -91,6 +91,7 @@ struct inodes_stat_t {
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
 #define MS_LAZYTIME	(1<<25) /* Update the on-disk [acm]times lazily */
+#define MS_RICHACL	(1<<26) /* Supports richacls */
 
 /* These sb flags are internal to the kernel */
 #define MS_NOSEC	(1<<28)
-- 
2.1.0


>From f8b04df08a0dd950d47e17c901773258f0653eed Mon Sep 17 00:00:00 2001
Message-Id: <f8b04df08a0dd950d47e17c901773258f0653eed.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 28 Jan 2015 20:23:15 +0100
Subject: [RFC 04/21] vfs: Add MAY_CREATE_FILE and MAY_CREATE_DIR
 permission flags
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Richacls distinguish between creating non-directories and directories. To
support that, add an isdir parameter to may_create(). When checking
inode_permission() for create permission, pass in an additional MAY_CREATE_FILE
or MAY_CREATE_DIR mask flag.

To allow checking for delete *and* create access when replacing an existing
file via vfs_rename(), add a replace parameter to may_delete().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c         | 42 ++++++++++++++++++++++++------------------
 include/linux/fs.h |  2 ++
 2 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0ba4bbc..a8bc030 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -454,7 +454,8 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * this, letting us set arbitrary permissions for filesystem access without
  * changing the "normal" UIDs which are used for other things.
  *
- * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
+ * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
+ * MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2447,10 +2448,11 @@ EXPORT_SYMBOL(__check_sticky);
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      bool isdir, bool replace)
 {
 	struct inode *inode = victim->d_inode;
-	int error;
+	int error, mask = MAY_WRITE | MAY_EXEC;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2459,7 +2461,9 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
-	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	if (replace)
+		mask |= isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
+	error = inode_permission(dir, mask);
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
@@ -2490,14 +2494,16 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
  *  3. We should have write and exec permissions on dir
  *  4. We can't do it if dir is immutable (done in permission())
  */
-static inline int may_create(struct inode *dir, struct dentry *child)
+static inline int may_create(struct inode *dir, struct dentry *child, bool isdir)
 {
+	int mask = isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
+
 	audit_inode_child(dir, child, AUDIT_TYPE_CHILD_CREATE);
 	if (child->d_inode)
 		return -EEXIST;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
-	return inode_permission(dir, MAY_WRITE | MAY_EXEC);
+	return inode_permission(dir, MAY_WRITE | MAY_EXEC | mask);
 }
 
 /*
@@ -2547,7 +2553,7 @@ EXPORT_SYMBOL(unlock_rename);
 int vfs_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 		bool want_excl)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 	if (error)
 		return error;
 
@@ -3422,7 +3428,7 @@ EXPORT_SYMBOL(user_path_create);
 
 int vfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 
 	if (error)
 		return error;
@@ -3514,7 +3520,7 @@ SYSCALL_DEFINE3(mknod, const char __user *, filename, umode_t, mode, unsigned, d
 
 int vfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, true);
 	unsigned max_links = dir->i_sb->s_max_links;
 
 	if (error)
@@ -3595,7 +3601,7 @@ EXPORT_SYMBOL(dentry_unhash);
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, true, false);
 
 	if (error)
 		return error;
@@ -3715,7 +3721,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegated_inode)
 {
 	struct inode *target = dentry->d_inode;
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, false, false);
 
 	if (error)
 		return error;
@@ -3847,7 +3853,7 @@ SYSCALL_DEFINE1(unlink, const char __user *, pathname)
 
 int vfs_symlink(struct inode *dir, struct dentry *dentry, const char *oldname)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 
 	if (error)
 		return error;
@@ -3930,7 +3936,7 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	if (!inode)
 		return -ENOENT;
 
-	error = may_create(dir, new_dentry);
+	error = may_create(dir, new_dentry, false);
 	if (error)
 		return error;
 
@@ -4118,19 +4124,19 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (source == target)
 		return 0;
 
-	error = may_delete(old_dir, old_dentry, is_dir);
+	error = may_delete(old_dir, old_dentry, is_dir, false);
 	if (error)
 		return error;
 
 	if (!target) {
-		error = may_create(new_dir, new_dentry);
+		error = may_create(new_dir, new_dentry, is_dir);
 	} else {
 		new_is_dir = d_is_dir(new_dentry);
 
 		if (!(flags & RENAME_EXCHANGE))
-			error = may_delete(new_dir, new_dentry, is_dir);
+			error = may_delete(new_dir, new_dentry, is_dir, true);
 		else
-			error = may_delete(new_dir, new_dentry, new_is_dir);
+			error = may_delete(new_dir, new_dentry, new_is_dir, true);
 	}
 	if (error)
 		return error;
@@ -4394,7 +4400,7 @@ SYSCALL_DEFINE2(rename, const char __user *, oldname, const char __user *, newna
 
 int vfs_whiteout(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_create(dir, dentry);
+	int error = may_create(dir, dentry, false);
 	if (error)
 		return error;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f64eb45..bbe1d26 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -80,6 +80,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+#define MAY_CREATE_FILE		0x00000100
+#define MAY_CREATE_DIR		0x00000200
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.1.0


>From a858d4a82fe74516f5036cb0b8ff8f177830025f Mon Sep 17 00:00:00 2001
Message-Id: <a858d4a82fe74516f5036cb0b8ff8f177830025f.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 05:06:26 +0530
Subject: [RFC 05/21] vfs: Add MAY_DELETE_SELF and MAY_DELETE_CHILD
 permission flags
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Normally, deleting a file requires write and execute access to the parent
directory.  With Richacls, a process with MAY_DELETE_SELF access to a file may
delete the file even without write access to the parent directory.

To support that, pass the MAY_DELETE_CHILD mask flag to inode_permission() when
checking for delete access inside a directory, and MAY_DELETE_SELF when
checking for delete access to a file itelf.

The MAY_DELETE_SELF permission does not override the sticky directory check.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c         | 15 +++++++++++----
 include/linux/fs.h |  2 ++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a8bc030..a8d1674 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -455,7 +455,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  * changing the "normal" UIDs which are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -2452,7 +2452,7 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 		      bool isdir, bool replace)
 {
 	struct inode *inode = victim->d_inode;
-	int error, mask = MAY_WRITE | MAY_EXEC;
+	int error, mask = MAY_EXEC;
 
 	if (d_is_negative(victim))
 		return -ENOENT;
@@ -2462,8 +2462,15 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 	audit_inode_child(dir, victim, AUDIT_TYPE_CHILD_DELETE);
 
 	if (replace)
-		mask |= isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
-	error = inode_permission(dir, mask);
+		mask |= MAY_WRITE | (isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE);
+	error = inode_permission(dir, mask | MAY_WRITE | MAY_DELETE_CHILD);
+	if (error && IS_RICHACL(inode)) {
+		/* Deleting is also permitted with MAY_EXEC on the directory
+		 * and MAY_DELETE_SELF on the inode.  */
+		if (!inode_permission(inode, MAY_DELETE_SELF) &&
+		    !inode_permission(dir, mask))
+			error = 0;
+	}
 	if (error)
 		return error;
 	if (IS_APPEND(dir))
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bbe1d26..101abcf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -82,6 +82,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.1.0


>From 19510de7d710a34c47eadb9b8f71881b5621574a Mon Sep 17 00:00:00 2001
Message-Id: <19510de7d710a34c47eadb9b8f71881b5621574a.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 05:13:56 +0530
Subject: [RFC 06/21] vfs: Make the inode passed to inode_change_ok
 non-const
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

We will need to call iop->permission and iop->get_acl from
inode_change_ok() for additional permission checks, and both take a
non-const inode.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/attr.c          | 2 +-
 include/linux/fs.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 6530ced..328be71 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -28,7 +28,7 @@
  * Should be called as the first thing in ->setattr implementations,
  * possibly after taking additional locks.
  */
-int inode_change_ok(const struct inode *inode, struct iattr *attr)
+int inode_change_ok(struct inode *inode, struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 101abcf..f688ea6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2760,7 +2760,7 @@ extern int buffer_migrate_page(struct address_space *,
 #define buffer_migrate_page NULL
 #endif
 
-extern int inode_change_ok(const struct inode *, struct iattr *);
+extern int inode_change_ok(struct inode *, struct iattr *);
 extern int inode_newsize_ok(const struct inode *, loff_t offset);
 extern void setattr_copy(struct inode *inode, const struct iattr *attr);
 
-- 
2.1.0


>From e710237138b0ee9012bc616012d1f8511cf6af4a Mon Sep 17 00:00:00 2001
Message-Id: <e710237138b0ee9012bc616012d1f8511cf6af4a.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 05:29:34 +0530
Subject: [RFC 07/21] vfs: Add permission flags for setting file
 attributes
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Richacls support permissions that allow to take ownership of a file, change the
file permissions, and set the file timestamps.  Support that by introducing new
permission mask flags and by checking for those mask flags in
inode_change_ok().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/attr.c          | 79 +++++++++++++++++++++++++++++++++++++++++++++---------
 include/linux/fs.h |  3 +++
 2 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 328be71..85483e0 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -17,6 +17,65 @@
 #include <linux/ima.h>
 
 /**
+ * inode_extended_permission  -  permissions beyond read/write/execute
+ *
+ * Check for permissions that only richacls can currently grant.
+ */
+static int inode_extended_permission(struct inode *inode, int mask)
+{
+	if (!IS_RICHACL(inode))
+		return -EPERM;
+	return inode_permission(inode, mask);
+}
+
+static bool inode_uid_change_ok(struct inode *inode, kuid_t ia_uid)
+{
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    uid_eq(ia_uid, inode->i_uid))
+		return true;
+	if (uid_eq(current_fsuid(), ia_uid) &&
+	    inode_extended_permission(inode, MAY_TAKE_OWNERSHIP) == 0)
+		return true;
+	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+		return true;
+	return false;
+}
+
+static bool inode_gid_change_ok(struct inode *inode, kgid_t ia_gid)
+{
+	int in_group = in_group_p(ia_gid);
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    (in_group || gid_eq(ia_gid, inode->i_gid)))
+		return true;
+	if (in_group && inode_extended_permission(inode, MAY_TAKE_OWNERSHIP) == 0)
+		return true;
+	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+		return true;
+	return false;
+}
+
+/**
+ * inode_owner_permitted_or_capable
+ *
+ * Check for permissions implicitly granted to the owner, like MAY_CHMOD or
+ * MAY_SET_TIMES.  Equivalent to inode_owner_or_capable for file systems
+ * without support for those permissions.
+ */
+static bool inode_owner_permitted_or_capable(struct inode *inode, int mask)
+{
+	struct user_namespace *ns;
+
+	if (uid_eq(current_fsuid(), inode->i_uid))
+		return true;
+	if (inode_extended_permission(inode, mask) == 0)
+		return true;
+	ns = current_user_ns();
+	if (ns_capable(ns, CAP_FOWNER) && kuid_has_mapping(ns, inode->i_uid))
+		return true;
+	return false;
+}
+
+/**
  * inode_change_ok - check if attribute changes to an inode are allowed
  * @inode:	inode to check
  * @attr:	attributes to change
@@ -47,22 +106,18 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 		return 0;
 
 	/* Make sure a caller can chown. */
-	if ((ia_valid & ATTR_UID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	     !uid_eq(attr->ia_uid, inode->i_uid)) &&
-	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_UID)
+		if (!inode_uid_change_ok(inode, attr->ia_uid))
+			return -EPERM;
 
 	/* Make sure caller can chgrp. */
-	if ((ia_valid & ATTR_GID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	    (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
-	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
-		return -EPERM;
+	if (ia_valid & ATTR_GID)
+		if (!inode_gid_change_ok(inode, attr->ia_gid))
+			return -EPERM;
 
 	/* Make sure a caller can chmod. */
 	if (ia_valid & ATTR_MODE) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_CHMOD))
 			return -EPERM;
 		/* Also check the setgid bit! */
 		if (!in_group_p((ia_valid & ATTR_GID) ? attr->ia_gid :
@@ -73,7 +128,7 @@ int inode_change_ok(struct inode *inode, struct iattr *attr)
 
 	/* Check for setting the inode time. */
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)) {
-		if (!inode_owner_or_capable(inode))
+		if (!inode_owner_permitted_or_capable(inode, MAY_SET_TIMES))
 			return -EPERM;
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f688ea6..e3e1e42 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -84,6 +84,9 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define MAY_CREATE_DIR		0x00000200
 #define MAY_DELETE_CHILD	0x00000400
 #define MAY_DELETE_SELF		0x00000800
+#define MAY_TAKE_OWNERSHIP	0x00001000
+#define MAY_CHMOD		0x00002000
+#define MAY_SET_TIMES		0x00004000
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
-- 
2.1.0


>From a47d85681cea868d4e34794982297950533c2930 Mon Sep 17 00:00:00 2001
Message-Id: <a47d85681cea868d4e34794982297950533c2930.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:10:17 +0530
Subject: [RFC 08/21] richacl: In-memory representation and helper
 functions
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

A richacl consists of an NFSv4 acl and an owner, group, and other mask.
These three masks correspond to the owner, group, and other file
permission bits, but they contain NFSv4 permissions instead of POSIX
permissions.

Each entry in the NFSv4 acl applies to the file owner (OWNER@), the owning
group (GROUP@), everyone (EVERYONE@), or to a specific uid or gid.

As in the standard POSIX file permission model, each process is the
owner, group, or other file class.  A richacl grants a requested access
only if the NFSv4 acl in the richacl grants the access (according to the
NFSv4 permission check algorithm), and the file mask that applies to the
process includes the requested permissions.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile             |   2 +
 fs/richacl_base.c       |  57 +++++++++++
 include/linux/richacl.h | 248 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 307 insertions(+)
 create mode 100644 fs/richacl_base.c
 create mode 100644 include/linux/richacl.h

diff --git a/fs/Makefile b/fs/Makefile
index a88ac48..8f0a59c 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -47,6 +47,8 @@ obj-$(CONFIG_COREDUMP)		+= coredump.o
 obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
+obj-$(CONFIG_FS_RICHACL)	+= richacl.o
+richacl-y			:= richacl_base.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
new file mode 100644
index 0000000..abf8bce
--- /dev/null
+++ b/fs/richacl_base.c
@@ -0,0 +1,57 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/richacl.h>
+
+MODULE_LICENSE("GPL");
+
+/**
+ * richacl_alloc  -  allocate a richacl
+ * @count:	number of entries
+ */
+struct richacl *
+richacl_alloc(int count)
+{
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	struct richacl *acl = kzalloc(size, GFP_KERNEL);
+
+	if (acl) {
+		atomic_set(&acl->a_refcount, 1);
+		acl->a_count = count;
+	}
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_alloc);
+
+/**
+ * richacl_clone  -  create a copy of a richacl
+ */
+static struct richacl *
+richacl_clone(const struct richacl *acl)
+{
+	int count = acl->a_count;
+	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	struct richacl *dup = kmalloc(size, GFP_KERNEL);
+
+	if (dup) {
+		memcpy(dup, acl, size);
+		atomic_set(&dup->a_refcount, 1);
+	}
+	return dup;
+}
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
new file mode 100644
index 0000000..b16d865
--- /dev/null
+++ b/include/linux/richacl.h
@@ -0,0 +1,248 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef __RICHACL_H
+#define __RICHACL_H
+#include <linux/slab.h>
+
+#define ACE_OWNER_ID		130
+#define ACE_GROUP_ID		131
+#define ACE_EVERYONE_ID		110
+
+struct richace {
+	unsigned short	e_type;
+	unsigned short	e_flags;
+	unsigned int	e_mask;
+	unsigned int	e_id;
+};
+
+struct richacl {
+	atomic_t	a_refcount;
+	unsigned int	a_owner_mask;
+	unsigned int	a_group_mask;
+	unsigned int	a_other_mask;
+	unsigned short	a_count;
+	unsigned short	a_flags;
+	struct richace	a_entries[0];
+};
+
+#define richacl_for_each_entry(_ace, _acl) \
+	for (_ace = (_acl)->a_entries; \
+	     _ace != (_acl)->a_entries + (_acl)->a_count; \
+	     _ace++)
+
+#define richacl_for_each_entry_reverse(_ace, _acl) \
+	for (_ace = (_acl)->a_entries + (_acl)->a_count - 1; \
+	     _ace != (_acl)->a_entries - 1; \
+	     _ace--)
+
+/* Flag values defined by richacls */
+#define ACL4_MASKED			0x80
+
+#define ACL4_VALID_FLAGS (			\
+		ACL4_MASKED)
+
+/* e_type values */
+#define ACE4_ACCESS_ALLOWED_ACE_TYPE	0x0000
+#define ACE4_ACCESS_DENIED_ACE_TYPE	0x0001
+/*#define ACE4_SYSTEM_AUDIT_ACE_TYPE	0x0002*/
+/*#define ACE4_SYSTEM_ALARM_ACE_TYPE	0x0003*/
+
+/* e_flags bitflags */
+#define ACE4_FILE_INHERIT_ACE		0x0001
+#define ACE4_DIRECTORY_INHERIT_ACE	0x0002
+#define ACE4_NO_PROPAGATE_INHERIT_ACE	0x0004
+#define ACE4_INHERIT_ONLY_ACE		0x0008
+/*#define ACE4_SUCCESSFUL_ACCESS_ACE_FLAG	0x0010*/
+/*#define ACE4_FAILED_ACCESS_ACE_FLAG	0x0020*/
+#define ACE4_IDENTIFIER_GROUP		0x0040
+/* richacl specific flag values */
+#define ACE4_SPECIAL_WHO		0x4000
+
+#define ACE4_VALID_FLAGS (			\
+	ACE4_FILE_INHERIT_ACE |			\
+	ACE4_DIRECTORY_INHERIT_ACE |		\
+	ACE4_NO_PROPAGATE_INHERIT_ACE |		\
+	ACE4_INHERIT_ONLY_ACE |			\
+	ACE4_IDENTIFIER_GROUP |			\
+	ACE4_SPECIAL_WHO)
+
+/* e_mask bitflags */
+#define ACE4_READ_DATA			0x00000001
+#define ACE4_LIST_DIRECTORY		0x00000001
+#define ACE4_WRITE_DATA			0x00000002
+#define ACE4_ADD_FILE			0x00000002
+#define ACE4_APPEND_DATA		0x00000004
+#define ACE4_ADD_SUBDIRECTORY		0x00000004
+#define ACE4_READ_NAMED_ATTRS		0x00000008
+#define ACE4_WRITE_NAMED_ATTRS		0x00000010
+#define ACE4_EXECUTE			0x00000020
+#define ACE4_DELETE_CHILD		0x00000040
+#define ACE4_READ_ATTRIBUTES		0x00000080
+#define ACE4_WRITE_ATTRIBUTES		0x00000100
+#define ACE4_WRITE_RETENTION		0x00000200
+#define ACE4_WRITE_RETENTION_HOLD	0x00000400
+#define ACE4_DELETE			0x00010000
+#define ACE4_READ_ACL			0x00020000
+#define ACE4_WRITE_ACL			0x00040000
+#define ACE4_WRITE_OWNER		0x00080000
+#define ACE4_SYNCHRONIZE		0x00100000
+
+/* Valid ACE4_* flags for directories and non-directories */
+#define ACE4_VALID_MASK (				\
+	ACE4_READ_DATA | ACE4_LIST_DIRECTORY |		\
+	ACE4_WRITE_DATA | ACE4_ADD_FILE |		\
+	ACE4_APPEND_DATA | ACE4_ADD_SUBDIRECTORY |	\
+	ACE4_READ_NAMED_ATTRS |				\
+	ACE4_WRITE_NAMED_ATTRS |			\
+	ACE4_EXECUTE |					\
+	ACE4_DELETE_CHILD |				\
+	ACE4_READ_ATTRIBUTES |				\
+	ACE4_WRITE_ATTRIBUTES |				\
+	ACE4_WRITE_RETENTION |				\
+	ACE4_WRITE_RETENTION_HOLD |			\
+	ACE4_DELETE |					\
+	ACE4_READ_ACL |					\
+	ACE4_WRITE_ACL |				\
+	ACE4_WRITE_OWNER |				\
+	ACE4_SYNCHRONIZE)
+
+/**
+ * richacl_get  -  grab another reference to a richacl handle
+ */
+static inline struct richacl *
+richacl_get(struct richacl *acl)
+{
+	if (acl)
+		atomic_inc(&acl->a_refcount);
+	return acl;
+}
+
+/**
+ * richacl_put  -  free a richacl handle
+ */
+static inline void
+richacl_put(struct richacl *acl)
+{
+	if (acl && atomic_dec_and_test(&acl->a_refcount))
+		kfree(acl);
+}
+
+/**
+ * richace_is_owner  -  check if @ace is an OWNER@ entry
+ */
+static inline bool
+richace_is_owner(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_OWNER_ID;
+}
+
+/**
+ * richace_is_group  -  check if @ace is a GROUP@ entry
+ */
+static inline bool
+richace_is_group(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_GROUP_ID;
+}
+
+/**
+ * richace_is_everyone  -  check if @ace is an EVERYONE@ entry
+ */
+static inline bool
+richace_is_everyone(const struct richace *ace)
+{
+	return (ace->e_flags & ACE4_SPECIAL_WHO) &&
+	       ace->e_id == ACE_EVERYONE_ID;
+}
+
+/**
+ * richace_is_unix_id  -  check if @ace applies to a specific uid or gid
+ */
+static inline bool
+richace_is_unix_id(const struct richace *ace)
+{
+	return !(ace->e_flags & ACE4_SPECIAL_WHO);
+}
+
+/**
+ * richace_is_inherit_only  -  check if @ace is for inheritance only
+ *
+ * ACEs with the %ACE4_INHERIT_ONLY_ACE flag set have no effect during
+ * permission checking.
+ */
+static inline bool
+richace_is_inherit_only(const struct richace *ace)
+{
+	return ace->e_flags & ACE4_INHERIT_ONLY_ACE;
+}
+
+/**
+ * richace_is_inheritable  -  check if @ace is inheritable
+ */
+static inline bool
+richace_is_inheritable(const struct richace *ace)
+{
+	return ace->e_flags & (ACE4_FILE_INHERIT_ACE |
+			       ACE4_DIRECTORY_INHERIT_ACE);
+}
+
+/**
+ * richace_clear_inheritance_flags  - clear all inheritance flags in @ace
+ */
+static inline void
+richace_clear_inheritance_flags(struct richace *ace)
+{
+	ace->e_flags &= ~(ACE4_FILE_INHERIT_ACE |
+			  ACE4_DIRECTORY_INHERIT_ACE |
+			  ACE4_NO_PROPAGATE_INHERIT_ACE |
+			  ACE4_INHERIT_ONLY_ACE);
+}
+
+/**
+ * richace_is_allow  -  check if @ace is an %ALLOW type entry
+ */
+static inline bool
+richace_is_allow(const struct richace *ace)
+{
+	return ace->e_type == ACE4_ACCESS_ALLOWED_ACE_TYPE;
+}
+
+/**
+ * richace_is_deny  -  check if @ace is a %DENY type entry
+ */
+static inline bool
+richace_is_deny(const struct richace *ace)
+{
+	return ace->e_type == ACE4_ACCESS_DENIED_ACE_TYPE;
+}
+
+/**
+ * richace_is_same_identifier  -  are both identifiers the same?
+ */
+static inline bool
+richace_is_same_identifier(const struct richace *a, const struct richace *b)
+{
+	return !((a->e_flags ^ b->e_flags) &
+		 (ACE4_SPECIAL_WHO | ACE4_IDENTIFIER_GROUP)) &&
+	       a->e_id == b->e_id;
+}
+
+extern struct richacl *richacl_alloc(int);
+
+#endif /* __RICHACL_H */
-- 
2.1.0


>From fe15273975043bc6064de8395e41ba3066f8d5d4 Mon Sep 17 00:00:00 2001
Message-Id: <fe15273975043bc6064de8395e41ba3066f8d5d4.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:11:56 +0530
Subject: [RFC 09/21] richacl: Permission mapping functions
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

We need to map from POSIX permissions to NFSv4 permissions when a
chmod() is done, from NFSv4 permissions to POSIX permissions when an acl
is set (which implicitly sets the file permission bits), and from the
MAY_READ/MAY_WRITE/MAY_EXEC/MAY_APPEND flags to NFSv4 permissions when
doing an access check in a richacl.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 117 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  46 +++++++++++++++++++
 2 files changed, 163 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index abf8bce..83731c7 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -55,3 +55,120 @@ richacl_clone(const struct richacl *acl)
 	}
 	return dup;
 }
+
+/**
+ * richacl_mask_to_mode  -  compute the file permission bits which correspond to @mask
+ * @mask:	%ACE4_* permission mask
+ *
+ * See richacl_masks_to_mode().
+ */
+static int
+richacl_mask_to_mode(unsigned int mask)
+{
+	int mode = 0;
+
+	if (mask & ACE4_POSIX_MODE_READ)
+		mode |= S_IROTH;
+	if (mask & ACE4_POSIX_MODE_WRITE)
+		mode |= S_IWOTH;
+	if (mask & ACE4_POSIX_MODE_EXEC)
+		mode |= S_IXOTH;
+
+	return mode;
+}
+
+/**
+ * richacl_masks_to_mode  -  compute the file permission bits from the file masks
+ *
+ * When setting a richacl, we set the file permission bits to indicate maximum
+ * permissions: for example, we set the Write permission when a mask contains
+ * ACE4_APPEND_DATA even if it does not also contain ACE4_WRITE_DATA.
+ *
+ * Permissions which are not in ACE4_POSIX_MODE_READ, ACE4_POSIX_MODE_WRITE, or
+ * ACE4_POSIX_MODE_EXEC cannot be represented in the file permission bits.
+ * Such permissions can still be effective, but not for new files or after a
+ * chmod(), and only if they were set explicitly, for example, by setting a
+ * richacl.
+ */
+int
+richacl_masks_to_mode(const struct richacl *acl)
+{
+	return richacl_mask_to_mode(acl->a_owner_mask) << 6 |
+	       richacl_mask_to_mode(acl->a_group_mask) << 3 |
+	       richacl_mask_to_mode(acl->a_other_mask);
+}
+EXPORT_SYMBOL_GPL(richacl_masks_to_mode);
+
+/**
+ * richacl_mode_to_mask  - compute a file mask from the lowest three mode bits
+ *
+ * When the file permission bits of a file are set with chmod(), this specifies
+ * the maximum permissions that processes will get.  All permissions beyond
+ * that will be removed from the file masks, and become ineffective.
+ *
+ * We also add in the permissions which are always allowed no matter what the
+ * acl says.
+ */
+unsigned int
+richacl_mode_to_mask(mode_t mode)
+{
+	unsigned int mask = ACE4_POSIX_ALWAYS_ALLOWED;
+
+	if (mode & S_IROTH)
+		mask |= ACE4_POSIX_MODE_READ;
+	if (mode & S_IWOTH)
+		mask |= ACE4_POSIX_MODE_WRITE;
+	if (mode & S_IXOTH)
+		mask |= ACE4_POSIX_MODE_EXEC;
+
+	return mask;
+}
+
+/**
+ * richacl_want_to_mask  - convert the iop->permission want argument to a mask
+ * @want:	@want argument of the permission inode operation
+ *
+ * When checking for append, @want is (MAY_WRITE | MAY_APPEND).
+ *
+ * Richacls use the iop->may_create and iop->may_delete hooks which are
+ * used for checking if creating and deleting files is allowed.  These hooks do
+ * not use richacl_want_to_mask(), so we do not have to deal with mapping
+ * MAY_WRITE to ACE4_ADD_FILE, ACE4_ADD_SUBDIRECTORY, and ACE4_DELETE_CHILD
+ * here.
+ */
+unsigned int
+richacl_want_to_mask(unsigned int want)
+{
+	unsigned int mask = 0;
+
+	if (want & MAY_READ)
+		mask |= ACE4_READ_DATA;
+	if (want & MAY_DELETE_SELF)
+		mask |= ACE4_DELETE;
+	if (want & MAY_TAKE_OWNERSHIP)
+		mask |= ACE4_WRITE_OWNER;
+	if (want & MAY_CHMOD)
+		mask |= ACE4_WRITE_ACL;
+	if (want & MAY_SET_TIMES)
+		mask |= ACE4_WRITE_ATTRIBUTES;
+	if (want & MAY_EXEC)
+		mask |= ACE4_EXECUTE;
+	/*
+	 * differentiate MAY_WRITE from these request
+	 */
+	if (want & (MAY_APPEND |
+		    MAY_CREATE_FILE | MAY_CREATE_DIR |
+		    MAY_DELETE_CHILD)) {
+		if (want & MAY_APPEND)
+			mask |= ACE4_APPEND_DATA;
+		if (want & MAY_CREATE_FILE)
+			mask |= ACE4_ADD_FILE;
+		if (want & MAY_CREATE_DIR)
+			mask |= ACE4_ADD_SUBDIRECTORY;
+		if (want & MAY_DELETE_CHILD)
+			mask |= ACE4_DELETE_CHILD;
+	} else if (want & MAY_WRITE)
+		mask |= ACE4_WRITE_DATA;
+	return mask;
+}
+EXPORT_SYMBOL_GPL(richacl_want_to_mask);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index b16d865..41819f4 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -120,6 +120,49 @@ struct richacl {
 	ACE4_WRITE_OWNER |				\
 	ACE4_SYNCHRONIZE)
 
+/*
+ * The POSIX permissions are supersets of the following NFSv4 permissions:
+ *
+ *  - MAY_READ maps to READ_DATA or LIST_DIRECTORY, depending on the type
+ *    of the file system object.
+ *
+ *  - MAY_WRITE maps to WRITE_DATA or ACE4_APPEND_DATA for files, and to
+ *    ADD_FILE, ACE4_ADD_SUBDIRECTORY, or ACE4_DELETE_CHILD for directories.
+ *
+ *  - MAY_EXECUTE maps to ACE4_EXECUTE.
+ *
+ *  (Some of these NFSv4 permissions have the same bit values.)
+ */
+#define ACE4_POSIX_MODE_READ (			\
+		ACE4_READ_DATA |		\
+		ACE4_LIST_DIRECTORY)
+#define ACE4_POSIX_MODE_WRITE (			\
+		ACE4_WRITE_DATA |		\
+		ACE4_ADD_FILE |			\
+		ACE4_APPEND_DATA |		\
+		ACE4_ADD_SUBDIRECTORY |		\
+		ACE4_DELETE_CHILD)
+#define ACE4_POSIX_MODE_EXEC ACE4_EXECUTE
+#define ACE4_POSIX_MODE_ALL (			\
+		ACE4_POSIX_MODE_READ |		\
+		ACE4_POSIX_MODE_WRITE |		\
+		ACE4_POSIX_MODE_EXEC)
+/*
+ * These permissions are always allowed
+ * no matter what the acl says.
+ */
+#define ACE4_POSIX_ALWAYS_ALLOWED (	\
+		ACE4_SYNCHRONIZE |	\
+		ACE4_READ_ATTRIBUTES |	\
+		ACE4_READ_ACL)
+/*
+ * The owner is implicitly granted
+ * these permissions under POSIX.
+ */
+#define ACE4_POSIX_OWNER_ALLOWED (		\
+		ACE4_WRITE_ATTRIBUTES |		\
+		ACE4_WRITE_OWNER |		\
+		ACE4_WRITE_ACL)
 /**
  * richacl_get  -  grab another reference to a richacl handle
  */
@@ -244,5 +287,8 @@ richace_is_same_identifier(const struct richace *a, const struct richace *b)
 }
 
 extern struct richacl *richacl_alloc(int);
+extern int richacl_masks_to_mode(const struct richacl *);
+extern unsigned int richacl_mode_to_mask(mode_t);
+extern unsigned int richacl_want_to_mask(unsigned int);
 
 #endif /* __RICHACL_H */
-- 
2.1.0


>From ae4e31aeac1c56249ae7092c84fe554ccb34df41 Mon Sep 17 00:00:00 2001
Message-Id: <ae4e31aeac1c56249ae7092c84fe554ccb34df41.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:13:16 +0530
Subject: [RFC 10/21] richacl: Compute maximum file masks from an acl
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Compute upper bound owner, group, and other file masks with as few
permissions as possible without denying any permissions that the NFSv4
acl in a richacl grants.

This algorithm is used when a file inherits an acl at create time and
when an acl is set via a mechanism that does not specify file modes
(such as via nfsd).  When user-space sets an acl, the file masks are
passed in as part of the xattr.

When setting a richacl, the file masks determine what the file
permission bits will be set to; see richacl_masks_to_mode().

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 128 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   1 +
 2 files changed, 129 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 83731c7..683bde2 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -172,3 +172,131 @@ richacl_want_to_mask(unsigned int want)
 	return mask;
 }
 EXPORT_SYMBOL_GPL(richacl_want_to_mask);
+
+/**
+ * richacl_allowed_to_who  -  mask flags allowed to a specific who value
+ *
+ * Computes the mask values allowed to a specific who value, taking
+ * EVERYONE@ entries into account.
+ */
+static unsigned int richacl_allowed_to_who(struct richacl *acl,
+					   struct richace *who)
+{
+	struct richace *ace;
+	unsigned int allowed = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_same_identifier(ace, who) ||
+		    richace_is_everyone(ace)) {
+			if (richace_is_allow(ace))
+				allowed |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				allowed &= ~ace->e_mask;
+		}
+	}
+	return allowed;
+}
+
+/**
+ * richacl_group_class_allowed  -  maximum permissions the group class is allowed
+ *
+ * See richacl_compute_max_masks().
+ */
+static unsigned int richacl_group_class_allowed(struct richacl *acl)
+{
+	struct richace *ace;
+	unsigned int everyone_allowed = 0, group_class_allowed = 0;
+	int had_group_ace = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace) ||
+		    richace_is_owner(ace))
+			continue;
+
+		if (richace_is_everyone(ace)) {
+			if (richace_is_allow(ace))
+				everyone_allowed |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				everyone_allowed &= ~ace->e_mask;
+		} else {
+			group_class_allowed |=
+				richacl_allowed_to_who(acl, ace);
+
+			if (richace_is_group(ace))
+				had_group_ace = 1;
+		}
+	}
+	if (!had_group_ace)
+		group_class_allowed |= everyone_allowed;
+	return group_class_allowed;
+}
+
+/**
+ * richacl_compute_max_masks  -  compute upper bound masks
+ *
+ * Computes upper bound owner, group, and other masks so that none of
+ * the mask flags allowed by the acl are disabled (for any choice of the
+ * file owner or group membership).
+ */
+void richacl_compute_max_masks(struct richacl *acl)
+{
+	unsigned int gmask = ~0;
+	struct richace *ace;
+
+	/*
+	 * @gmask contains all permissions which the group class is ever
+	 * allowed.  We use it to avoid adding permissions to the group mask
+	 * from everyone@ allow aces which the group class is always denied
+	 * through other aces.  For example, the following acl would otherwise
+	 * result in a group mask or rw:
+	 *
+	 *	group@:w::deny
+	 *	everyone@:rw::allow
+	 *
+	 * Avoid computing @gmask for acls which do not include any group class
+	 * deny aces: in such acls, the group class is never denied any
+	 * permissions from everyone@ allow aces.
+	 */
+
+restart:
+	acl->a_owner_mask = 0;
+	acl->a_group_mask = 0;
+	acl->a_other_mask = 0;
+
+	richacl_for_each_entry_reverse(ace, acl) {
+		if (richace_is_inherit_only(ace))
+			continue;
+
+		if (richace_is_owner(ace)) {
+			if (richace_is_allow(ace))
+				acl->a_owner_mask |= ace->e_mask;
+			else if (richace_is_deny(ace))
+				acl->a_owner_mask &= ~ace->e_mask;
+		} else if (richace_is_everyone(ace)) {
+			if (richace_is_allow(ace)) {
+				acl->a_owner_mask |= ace->e_mask;
+				acl->a_group_mask |= ace->e_mask & gmask;
+				acl->a_other_mask |= ace->e_mask;
+			} else if (richace_is_deny(ace)) {
+				acl->a_owner_mask &= ~ace->e_mask;
+				acl->a_group_mask &= ~ace->e_mask;
+				acl->a_other_mask &= ~ace->e_mask;
+			}
+		} else {
+			if (richace_is_allow(ace)) {
+				acl->a_owner_mask |= ace->e_mask & gmask;
+				acl->a_group_mask |= ace->e_mask & gmask;
+			} else if (richace_is_deny(ace) && gmask == ~0) {
+				gmask = richacl_group_class_allowed(acl);
+				if (likely(gmask != ~0))
+					/* should always be true */
+					goto restart;
+			}
+		}
+	}
+
+	acl->a_flags &= ~ACL4_MASKED;
+}
+EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 41819f4..05d79ac 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -290,5 +290,6 @@ extern struct richacl *richacl_alloc(int);
 extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
+extern void richacl_compute_max_masks(struct richacl *);
 
 #endif /* __RICHACL_H */
-- 
2.1.0


>From ae450198a6c8cb199f43005757598a41cc50937d Mon Sep 17 00:00:00 2001
Message-Id: <ae450198a6c8cb199f43005757598a41cc50937d.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:14:18 +0530
Subject: [RFC 11/21] richacl: Update the file masks in chmod()
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Doing a chmod() sets the file mode, which includes the file permission
bits.  When a file has a richacl, the permissions that the richacl
grants need to be limited to what the new file permission bits allow.

This is done by setting the file masks in the richacl to what the file
permission bits map to.  The richacl access check algorithm takes the
file masks into account, which ensures that the richacl cannot grant too
many permissions.

It is possible to explicitly add permissions to the file masks which go
beyond what the file permission bits can grant (like the ACE4_WRITE_ACL
permission).  The POSIX.1 standard calls this an alternate file access
control mechanism.  A subsequent chmod() would ensure that those
permissions are disabled again.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 40 ++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 41 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 683bde2..7de2e9e 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -300,3 +300,43 @@ restart:
 	acl->a_flags &= ~ACL4_MASKED;
 }
 EXPORT_SYMBOL_GPL(richacl_compute_max_masks);
+
+/**
+ * richacl_chmod  -  update the file masks to reflect the new mode
+ * @mode:	new file permission bits
+ *
+ * Return a copy of @acl where the file masks have been replaced by the file
+ * masks corresponding to the file permission bits in @mode, or returns @acl
+ * itself if the file masks are already up to date.  Takes over a reference
+ * to @acl.
+ */
+struct richacl *
+richacl_chmod(struct richacl *acl, mode_t mode)
+{
+	unsigned int owner_mask, group_mask, other_mask;
+	struct richacl *clone;
+
+	owner_mask = richacl_mode_to_mask(mode >> 6) |
+		     ACE4_POSIX_OWNER_ALLOWED;
+	group_mask = richacl_mode_to_mask(mode >> 3);
+	other_mask = richacl_mode_to_mask(mode);
+
+	if (acl->a_owner_mask == owner_mask &&
+	    acl->a_group_mask == group_mask &&
+	    acl->a_other_mask == other_mask &&
+	    (acl->a_flags & ACL4_MASKED))
+		return acl;
+
+	clone = richacl_clone(acl);
+	richacl_put(acl);
+	if (!clone)
+		return ERR_PTR(-ENOMEM);
+
+	clone->a_flags |= ACL4_MASKED;
+	clone->a_owner_mask = owner_mask;
+	clone->a_group_mask = group_mask;
+	clone->a_other_mask = other_mask;
+
+	return clone;
+}
+EXPORT_SYMBOL_GPL(richacl_chmod);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 05d79ac..f347125 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -291,5 +291,6 @@ extern int richacl_masks_to_mode(const struct richacl *);
 extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
+extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 
 #endif /* __RICHACL_H */
-- 
2.1.0


>From 516c44e08972125aee20a90e0399aaefe8e6d553 Mon Sep 17 00:00:00 2001
Message-Id: <516c44e08972125aee20a90e0399aaefe8e6d553.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:15:22 +0530
Subject: [RFC 12/21] richacl: Permission check algorithm
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

A richacl grants a requested access if the NFSv4 acl in the richacl grants the
requested permissions (according to the NFSv4 permission check algorithm) and
the file mask that applies to the process includes the requested permissions.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 112 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |   1 +
 2 files changed, 113 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 7de2e9e..7723bc8 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -340,3 +340,115 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	return clone;
 }
 EXPORT_SYMBOL_GPL(richacl_chmod);
+
+/**
+ * richacl_permission  -  richacl permission check algorithm
+ * @inode:	inode to check
+ * @acl:	rich acl of the inode
+ * @want:	requested access (MAY_* flags)
+ *
+ * Checks if the current process is granted @mask flags in @acl.
+ */
+int
+richacl_permission(struct inode *inode, const struct richacl *acl,
+		   int want)
+{
+	const struct richace *ace;
+	unsigned int mask = richacl_want_to_mask(want);
+	unsigned int requested = mask, denied = 0;
+	int in_owning_group = in_group_p(inode->i_gid);
+	int in_owner_or_group_class = in_owning_group;
+
+	/*
+	 * We don't need to know which class the process is in when the acl is
+	 * not masked.
+	 */
+	if (!(acl->a_flags & ACL4_MASKED))
+		in_owner_or_group_class = 1;
+
+	/*
+	 * A process is
+	 *   - in the owner file class if it owns the file,
+	 *   - in the group file class if it is in the file's owning group or
+	 *     it matches any of the user or group entries, and
+	 *   - in the other file class otherwise.
+	 */
+
+	/*
+	 * Check if the acl grants the requested access and determine which
+	 * file class the process is in.
+	 */
+	richacl_for_each_entry(ace, acl) {
+		unsigned int ace_mask = ace->e_mask;
+
+		if (richace_is_inherit_only(ace))
+			continue;
+		if (richace_is_owner(ace)) {
+			if (!uid_eq(current_fsuid(), inode->i_uid))
+				continue;
+			goto is_owner;
+		} else if (richace_is_group(ace)) {
+			if (!in_owning_group)
+				continue;
+		} else if (richace_is_unix_id(ace)) {
+			if (ace->e_flags & ACE4_IDENTIFIER_GROUP) {
+				if (!in_group_p(make_kgid(current_user_ns(),
+							  ace->e_id)))
+					continue;
+			} else {
+				if (!uid_eq(current_fsuid(),
+					    make_kuid(current_user_ns(),
+						     ace->e_id)))
+					continue;
+			}
+		} else
+			goto is_everyone;
+
+		/*
+		 * Apply the group file mask to entries other than OWNER@ and
+		 * EVERYONE@. This is not required for correct access checking
+		 * but ensures that we grant the same permissions as the acl
+		 * computed by richacl_apply_masks() would grant.
+		 */
+		if ((acl->a_flags & ACL4_MASKED) && richace_is_allow(ace))
+			ace_mask &= acl->a_group_mask;
+
+is_owner:
+		/* The process is in the owner or group file class. */
+		in_owner_or_group_class = 1;
+
+is_everyone:
+		/* Check which mask flags the ACE allows or denies. */
+		if (richace_is_deny(ace))
+			denied |= ace_mask & mask;
+		mask &= ~ace_mask;
+
+		/*
+		 * Keep going until we know which file class
+		 * the process is in.
+		 */
+		if (!mask && in_owner_or_group_class)
+			break;
+	}
+	denied |= mask;
+
+	if (acl->a_flags & ACL4_MASKED) {
+		unsigned int file_mask;
+
+		/*
+		 * The file class a process is in determines which file mask
+		 * applies.  Check if that file mask also grants the requested
+		 * access.
+		 */
+		if (uid_eq(current_fsuid(), inode->i_uid))
+			file_mask = acl->a_owner_mask;
+		else if (in_owner_or_group_class)
+			file_mask = acl->a_group_mask;
+		else
+			file_mask = acl->a_other_mask;
+		denied |= requested & ~file_mask;
+	}
+
+	return denied ? -EACCES : 0;
+}
+EXPORT_SYMBOL_GPL(richacl_permission);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index f347125..d92e1c2 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -292,5 +292,6 @@ extern unsigned int richacl_mode_to_mask(mode_t);
 extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
+extern int richacl_permission(struct inode *, const struct richacl *, int);
 
 #endif /* __RICHACL_H */
-- 
2.1.0


>From 213ba5b03fffbcf6a7ff78a3585568eff7b43527 Mon Sep 17 00:00:00 2001
Message-Id: <213ba5b03fffbcf6a7ff78a3585568eff7b43527.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:17:22 +0530
Subject: [RFC 13/21] richacl: Create-time inheritance
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

When a new file is created, it can inherit an acl from its parent
directory; this is similar to how default acls work in POSIX (draft)
ACLs.

As with POSIX ACLs, if a file inherits an acl from its parent directory,
the intersection between the create mode and the permissions granted by
the inherited acl determines the file masks and file permission bits,
and the umask is ignored.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile             |  2 +-
 fs/richacl_base.c       | 69 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/richacl_inode.c      | 62 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  4 +++
 4 files changed, 136 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_inode.c

diff --git a/fs/Makefile b/fs/Makefile
index 8f0a59c..bb96ad7 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o
+richacl-y			:= richacl_base.o richacl_inode.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 7723bc8..8d9dc2c 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -452,3 +452,72 @@ is_everyone:
 	return denied ? -EACCES : 0;
 }
 EXPORT_SYMBOL_GPL(richacl_permission);
+
+/**
+ * richacl_inherit  -  compute the inherited acl of a new file
+ * @dir_acl:	acl of the containing directory
+ * @isdir:	inherit by a directory or non-directory?
+ *
+ * A directory can have acl entries which files and/or directories created
+ * inside the directory will inherit.  This function computes the acl for such
+ * a new file.  If there is no inheritable acl, it will return %NULL.
+ */
+struct richacl *
+richacl_inherit(const struct richacl *dir_acl, int isdir)
+{
+	const struct richace *dir_ace;
+	struct richacl *acl = NULL;
+	struct richace *ace;
+	int count = 0;
+
+	if (isdir) {
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!richace_is_inheritable(dir_ace))
+				continue;
+			count++;
+		}
+		if (!count)
+			return NULL;
+		acl = richacl_alloc(count);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!richace_is_inheritable(dir_ace))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			if (dir_ace->e_flags & ACE4_NO_PROPAGATE_INHERIT_ACE)
+				richace_clear_inheritance_flags(ace);
+			if ((dir_ace->e_flags & ACE4_FILE_INHERIT_ACE) &&
+			    !(dir_ace->e_flags & ACE4_DIRECTORY_INHERIT_ACE))
+				ace->e_flags |= ACE4_INHERIT_ONLY_ACE;
+			ace++;
+		}
+	} else {
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & ACE4_FILE_INHERIT_ACE))
+				continue;
+			count++;
+		}
+		if (!count)
+			return NULL;
+		acl = richacl_alloc(count);
+		if (!acl)
+			return ERR_PTR(-ENOMEM);
+		ace = acl->a_entries;
+		richacl_for_each_entry(dir_ace, dir_acl) {
+			if (!(dir_ace->e_flags & ACE4_FILE_INHERIT_ACE))
+				continue;
+			memcpy(ace, dir_ace, sizeof(struct richace));
+			richace_clear_inheritance_flags(ace);
+			/*
+			 * ACE4_DELETE_CHILD is meaningless for
+			 * non-directories, so clear it.
+			 */
+			ace->e_mask &= ~ACE4_DELETE_CHILD;
+			ace++;
+		}
+	}
+
+	return acl;
+}
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
new file mode 100644
index 0000000..b95a584
--- /dev/null
+++ b/fs/richacl_inode.c
@@ -0,0 +1,62 @@
+/*
+ * Copyright (C) 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/richacl.h>
+
+/**
+ * richacl_inherit_inode  -  compute inherited acl and file mode
+ * @dir_acl:	acl of the containing directory
+ * @inode:	inode of the new file (create mode in i_mode)
+ *
+ * The file permission bits in inode->i_mode must be set to the create mode by
+ * the caller.
+ *
+ * If there is an inheritable acl, the maximum permissions that the acl grants
+ * will be computed and permissions not granted by the acl will be removed from
+ * inode->i_mode.  If there is no inheritable acl, the umask will be applied
+ * instead.
+ */
+struct richacl *
+richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
+{
+	struct richacl *acl;
+	mode_t mask;
+
+	acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
+	if (acl) {
+
+		richacl_compute_max_masks(acl);
+
+		/*
+		 * Ensure that the acl will not grant any permissions beyond
+		 * the create mode.
+		 */
+		acl->a_flags |= ACL4_MASKED;
+		acl->a_owner_mask &= richacl_mode_to_mask(inode->i_mode >> 6) |
+				     ACE4_POSIX_OWNER_ALLOWED;
+		acl->a_group_mask &= richacl_mode_to_mask(inode->i_mode >> 3);
+		acl->a_other_mask &= richacl_mode_to_mask(inode->i_mode);
+		mask = ~S_IRWXUGO | richacl_masks_to_mode(acl);
+	} else
+		mask = ~current_umask();
+
+	inode->i_mode &= mask;
+	return acl;
+}
+EXPORT_SYMBOL_GPL(richacl_inherit_inode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index d92e1c2..fd3eeb4 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -293,5 +293,9 @@ extern unsigned int richacl_want_to_mask(unsigned int);
 extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_permission(struct inode *, const struct richacl *, int);
+extern struct richacl *richacl_inherit(const struct richacl *, int);
 
+/* richacl_inode.c */
+extern struct richacl *richacl_inherit_inode(const struct richacl *,
+					     struct inode *);
 #endif /* __RICHACL_H */
-- 
2.1.0


>From 410d49744f16fb757be06a4c2a9e97b9eb760d70 Mon Sep 17 00:00:00 2001
Message-Id: <410d49744f16fb757be06a4c2a9e97b9eb760d70.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:18:38 +0530
Subject: [RFC 14/21] richacl: Check if an acl is equivalent to a file
 mode
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

This function is used to avoid storing richacls if the acl can be computed from
the file permission bits.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 54 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index 8d9dc2c..c853f7e 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -521,3 +521,57 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 
 	return acl;
 }
+
+/**
+ * richacl_equiv_mode  -  check if @acl is equivalent to file permission bits
+ * @mode_p:	the file mode (including the file type)
+ *
+ * If @acl can be fully represented by file permission bits, this function
+ * returns 0, and the file permission bits in @mode_p are set to the equivalent
+ * of @acl.
+ *
+ * This function is used to avoid storing richacls on disk if the acl can be
+ * computed from the file permission bits.  It allows user-space to make sure
+ * that a file has no explicit richacl set.
+ */
+int
+richacl_equiv_mode(const struct richacl *acl, mode_t *mode_p)
+{
+	const struct richace *ace = acl->a_entries;
+	unsigned int x;
+	mode_t mode;
+
+	if (acl->a_count != 1 ||
+	    acl->a_flags != ACL4_MASKED ||
+	    !richace_is_everyone(ace) ||
+	    !richace_is_allow(ace) ||
+	    ace->e_flags & ~ACE4_SPECIAL_WHO)
+		return -1;
+
+	/*
+	 * Figure out the permissions we care about: ACE4_DELETE_CHILD is
+	 * meaningless for non-directories, so we ignore it.
+	 */
+	x = ~ACE4_POSIX_ALWAYS_ALLOWED;
+	if (!S_ISDIR(*mode_p))
+		x &= ~ACE4_DELETE_CHILD;
+
+	mode = richacl_masks_to_mode(acl);
+	if ((acl->a_group_mask & x) != (richacl_mode_to_mask(mode >> 3) & x) ||
+	    (acl->a_other_mask & x) != (richacl_mode_to_mask(mode) & x))
+		return -1;
+
+	/*
+	 * Ignore permissions which the owner is always allowed.
+	 */
+	x &= ~ACE4_POSIX_OWNER_ALLOWED;
+	if ((acl->a_owner_mask & x) != (richacl_mode_to_mask(mode >> 6) & x))
+		return -1;
+
+	if ((ace->e_mask & x) != (ACE4_POSIX_MODE_ALL & x))
+		return -1;
+
+	*mode_p = (*mode_p & ~S_IRWXUGO) | mode;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(richacl_equiv_mode);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index fd3eeb4..39072a0 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -294,6 +294,7 @@ extern void richacl_compute_max_masks(struct richacl *);
 extern struct richacl *richacl_chmod(struct richacl *, mode_t);
 extern int richacl_permission(struct inode *, const struct richacl *, int);
 extern struct richacl *richacl_inherit(const struct richacl *, int);
+extern int richacl_equiv_mode(const struct richacl *, mode_t *);
 
 /* richacl_inode.c */
 extern struct richacl *richacl_inherit_inode(const struct richacl *,
-- 
2.1.0


>From 39c338514faf1b135b8515db11c58720f6897e9d Mon Sep 17 00:00:00 2001
Message-Id: <39c338514faf1b135b8515db11c58720f6897e9d.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:19:48 +0530
Subject: [RFC 15/21] richacl: Automatic Inheritance
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Automatic Inheritance (AI) allows changes to the acl of a directory to
recursively propagate down to files and directories in the directory.

To implement this, the kernel keeps track of which permissions have been
inherited, and makes sure that permission propagation is turned off when the
file permission bits of a file are changed (upon create or chmod).

The actual permission propagation is implemented in user space.

Automatic Inheritance works as follows:

 - When the ACL4_AUTO_INHERIT flag in the acl of a file is not set, the
   file is not affected by AI.

 - When the ACL4_AUTO_INHERIT flag in the acl of a directory is set and
   a file or subdirectory is created in that directory, files created in
   the directory will have the ACL4_AUTO_INHERIT flag set, and all
   inherited aces will have the ACE4_INHERITED_ACE flag set.  This
   allows user space to distinguish between aces which have been
   inherited and aces which have been explicitly added.

 - When the ACL4_PROTECTED acl flag in the acl of a file is set, AI will
   not modify the acl of the file.  This does not affect propagation of
   permissions from the file to its children (if the file is a
   directory).

Linux does not have a way of creating files without setting the file permission
bits, so all files created inside a directory with ACL4_AUTO_INHERIT set will
also have the ACL4_PROTECTED flag set.  This effectively disables Automatic
Inheritance.

Protocols which support creating files without specifying permissions can
explicitly clear the ACL4_PROTECTED flag after creating a file and reset the
file masks to "undo" applying the create mode; see richacl_compute_max_masks().
This is a workaround; a mechanism that would allow a process to indicate to the
kernel to ignore the create mode when there are inherited permissions would fix
this problem.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/richacl_base.c       | 10 +++++++++-
 fs/richacl_inode.c      |  7 ++++++-
 include/linux/richacl.h | 24 +++++++++++++++++++++++-
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index c853f7e..ec570ef 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -324,7 +324,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	if (acl->a_owner_mask == owner_mask &&
 	    acl->a_group_mask == group_mask &&
 	    acl->a_other_mask == other_mask &&
-	    (acl->a_flags & ACL4_MASKED))
+	    (acl->a_flags & ACL4_MASKED) &&
+	    (!richacl_is_auto_inherit(acl) || richacl_is_protected(acl)))
 		return acl;
 
 	clone = richacl_clone(acl);
@@ -336,6 +337,8 @@ richacl_chmod(struct richacl *acl, mode_t mode)
 	clone->a_owner_mask = owner_mask;
 	clone->a_group_mask = group_mask;
 	clone->a_other_mask = other_mask;
+	if (richacl_is_auto_inherit(clone))
+		clone->a_flags |= ACL4_PROTECTED;
 
 	return clone;
 }
@@ -518,6 +521,11 @@ richacl_inherit(const struct richacl *dir_acl, int isdir)
 			ace++;
 		}
 	}
+	if (richacl_is_auto_inherit(dir_acl)) {
+		acl->a_flags = ACL4_AUTO_INHERIT;
+		richacl_for_each_entry(ace, acl)
+			ace->e_flags |= ACE4_INHERITED_ACE;
+	}
 
 	return acl;
 }
diff --git a/fs/richacl_inode.c b/fs/richacl_inode.c
index b95a584..9f96564 100644
--- a/fs/richacl_inode.c
+++ b/fs/richacl_inode.c
@@ -40,9 +40,14 @@ richacl_inherit_inode(const struct richacl *dir_acl, struct inode *inode)
 
 	acl = richacl_inherit(dir_acl, S_ISDIR(inode->i_mode));
 	if (acl) {
+		/*
+		 * We need to set ACL4_PROTECTED because we are
+		 * doing an implicit chmod
+		 */
+		if (richacl_is_auto_inherit(acl))
+			acl->a_flags |= ACL4_PROTECTED;
 
 		richacl_compute_max_masks(acl);
-
 		/*
 		 * Ensure that the acl will not grant any permissions beyond
 		 * the create mode.
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 39072a0..a607d6f 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -49,10 +49,17 @@ struct richacl {
 	     _ace != (_acl)->a_entries - 1; \
 	     _ace--)
 
+/* a_flags values */
+#define ACL4_AUTO_INHERIT		0x01
+#define ACL4_PROTECTED			0x02
+#define ACL4_DEFAULTED			0x04
 /* Flag values defined by richacls */
 #define ACL4_MASKED			0x80
 
 #define ACL4_VALID_FLAGS (			\
+		ACL4_AUTO_INHERIT |		\
+		ACL4_PROTECTED |		\
+		ACL4_DEFAULTED |		\
 		ACL4_MASKED)
 
 /* e_type values */
@@ -69,6 +76,7 @@ struct richacl {
 /*#define ACE4_SUCCESSFUL_ACCESS_ACE_FLAG	0x0010*/
 /*#define ACE4_FAILED_ACCESS_ACE_FLAG	0x0020*/
 #define ACE4_IDENTIFIER_GROUP		0x0040
+#define ACE4_INHERITED_ACE		0x0080
 /* richacl specific flag values */
 #define ACE4_SPECIAL_WHO		0x4000
 
@@ -78,6 +86,7 @@ struct richacl {
 	ACE4_NO_PROPAGATE_INHERIT_ACE |		\
 	ACE4_INHERIT_ONLY_ACE |			\
 	ACE4_IDENTIFIER_GROUP |			\
+	ACE4_INHERITED_ACE |			\
 	ACE4_SPECIAL_WHO)
 
 /* e_mask bitflags */
@@ -184,6 +193,18 @@ richacl_put(struct richacl *acl)
 		kfree(acl);
 }
 
+static inline int
+richacl_is_auto_inherit(const struct richacl *acl)
+{
+	return acl->a_flags & ACL4_AUTO_INHERIT;
+}
+
+static inline int
+richacl_is_protected(const struct richacl *acl)
+{
+	return acl->a_flags & ACL4_PROTECTED;
+}
+
 /**
  * richace_is_owner  -  check if @ace is an OWNER@ entry
  */
@@ -254,7 +275,8 @@ richace_clear_inheritance_flags(struct richace *ace)
 	ace->e_flags &= ~(ACE4_FILE_INHERIT_ACE |
 			  ACE4_DIRECTORY_INHERIT_ACE |
 			  ACE4_NO_PROPAGATE_INHERIT_ACE |
-			  ACE4_INHERIT_ONLY_ACE);
+			  ACE4_INHERIT_ONLY_ACE |
+			  ACE4_INHERITED_ACE);
 }
 
 /**
-- 
2.1.0


>From 38f525822b15ec67c337cc90659fecb3737a0767 Mon Sep 17 00:00:00 2001
Message-Id: <38f525822b15ec67c337cc90659fecb3737a0767.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:20:43 +0530
Subject: [RFC 16/21] richacl: xattr mapping functions
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Map between "system.richacl" xattrs and the in-kernel representation.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/Makefile                   |   2 +-
 fs/richacl_xattr.c            | 131 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/richacl_xattr.h |  47 +++++++++++++++
 3 files changed, 179 insertions(+), 1 deletion(-)
 create mode 100644 fs/richacl_xattr.c
 create mode 100644 include/linux/richacl_xattr.h

diff --git a/fs/Makefile b/fs/Makefile
index bb96ad7..6155cc4 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -48,7 +48,7 @@ obj-$(CONFIG_SYSCTL)		+= drop_caches.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
 obj-$(CONFIG_FS_RICHACL)	+= richacl.o
-richacl-y			:= richacl_base.o richacl_inode.o
+richacl-y			:= richacl_base.o richacl_inode.o richacl_xattr.o
 
 obj-y				+= quota/
 
diff --git a/fs/richacl_xattr.c b/fs/richacl_xattr.c
new file mode 100644
index 0000000..05e5e97
--- /dev/null
+++ b/fs/richacl_xattr.c
@@ -0,0 +1,131 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/richacl_xattr.h>
+
+MODULE_LICENSE("GPL");
+
+/**
+ * richacl_from_xattr  -  convert a richacl xattr into the in-memory representation
+ */
+struct richacl *
+richacl_from_xattr(const void *value, size_t size)
+{
+	const struct richacl_xattr *xattr_acl = value;
+	const struct richace_xattr *xattr_ace = (void *)(xattr_acl + 1);
+	struct richacl *acl;
+	struct richace *ace;
+	int count;
+
+	if (size < sizeof(struct richacl_xattr) ||
+	    xattr_acl->a_version != ACL4_XATTR_VERSION ||
+	    (xattr_acl->a_flags & ~ACL4_VALID_FLAGS))
+		return ERR_PTR(-EINVAL);
+
+	count = le16_to_cpu(xattr_acl->a_count);
+	if (count > ACL4_XATTR_MAX_COUNT)
+		return ERR_PTR(-EINVAL);
+
+	acl = richacl_alloc(count);
+	if (!acl)
+		return ERR_PTR(-ENOMEM);
+
+	acl->a_flags = xattr_acl->a_flags;
+	acl->a_owner_mask = le32_to_cpu(xattr_acl->a_owner_mask);
+	if (acl->a_owner_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+	acl->a_group_mask = le32_to_cpu(xattr_acl->a_group_mask);
+	if (acl->a_group_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+	acl->a_other_mask = le32_to_cpu(xattr_acl->a_other_mask);
+	if (acl->a_other_mask & ~ACE4_VALID_MASK)
+		goto fail_einval;
+
+	if (((void *)xattr_ace + count * sizeof(*xattr_ace)) > (value + size))
+		goto fail_einval;
+
+	richacl_for_each_entry(ace, acl) {
+
+		ace->e_type  = le16_to_cpu(xattr_ace->e_type);
+		ace->e_flags = le16_to_cpu(xattr_ace->e_flags);
+		ace->e_mask  = le32_to_cpu(xattr_ace->e_mask);
+		ace->e_id    = le32_to_cpu(xattr_ace->e_id);
+
+		if (ace->e_flags & ~ACE4_VALID_FLAGS)
+			goto fail_einval;
+		if (ace->e_type > ACE4_ACCESS_DENIED_ACE_TYPE ||
+		    (ace->e_mask & ~ACE4_VALID_MASK))
+			goto fail_einval;
+
+		xattr_ace++;
+	}
+
+	return acl;
+
+fail_einval:
+	richacl_put(acl);
+	return ERR_PTR(-EINVAL);
+}
+EXPORT_SYMBOL_GPL(richacl_from_xattr);
+
+/**
+ * richacl_xattr_size  -  compute the size of the xattr representation of @acl
+ */
+size_t
+richacl_xattr_size(const struct richacl *acl)
+{
+	size_t size = sizeof(struct richacl_xattr);
+
+	size += sizeof(struct richace_xattr) * acl->a_count;
+	return size;
+}
+EXPORT_SYMBOL_GPL(richacl_xattr_size);
+
+/**
+ * richacl_to_xattr  -  convert @acl into its xattr representation
+ * @acl:	the richacl to convert
+ * @buffer:	buffer of size richacl_xattr_size(@acl) for the result
+ */
+void
+richacl_to_xattr(const struct richacl *acl, void *buffer)
+{
+	struct richacl_xattr *xattr_acl = buffer;
+	struct richace_xattr *xattr_ace;
+	const struct richace *ace;
+
+	xattr_acl->a_version = ACL4_XATTR_VERSION;
+	xattr_acl->a_flags = acl->a_flags;
+	xattr_acl->a_count = cpu_to_le16(acl->a_count);
+
+	xattr_acl->a_owner_mask = cpu_to_le32(acl->a_owner_mask);
+	xattr_acl->a_group_mask = cpu_to_le32(acl->a_group_mask);
+	xattr_acl->a_other_mask = cpu_to_le32(acl->a_other_mask);
+
+	xattr_ace = (void *)(xattr_acl + 1);
+	richacl_for_each_entry(ace, acl) {
+		xattr_ace->e_type = cpu_to_le16(ace->e_type);
+		xattr_ace->e_flags = cpu_to_le16(ace->e_flags &
+						 ACE4_VALID_FLAGS);
+		xattr_ace->e_mask = cpu_to_le32(ace->e_mask);
+		xattr_ace->e_id = cpu_to_le32(ace->e_id);
+		xattr_ace++;
+	}
+}
+EXPORT_SYMBOL_GPL(richacl_to_xattr);
diff --git a/include/linux/richacl_xattr.h b/include/linux/richacl_xattr.h
new file mode 100644
index 0000000..32ae512
--- /dev/null
+++ b/include/linux/richacl_xattr.h
@@ -0,0 +1,47 @@
+/*
+ * Copyright (C) 2006, 2010  Novell, Inc.
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Written by Andreas Gruenbacher <agruen@kernel.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef __RICHACL_XATTR_H
+#define __RICHACL_XATTR_H
+
+#include <linux/richacl.h>
+
+#define RICHACL_XATTR "system.richacl"
+
+struct richace_xattr {
+	__le16		e_type;
+	__le16		e_flags;
+	__le32		e_mask;
+	__le32		e_id;
+};
+
+struct richacl_xattr {
+	unsigned char	a_version;
+	unsigned char	a_flags;
+	__le16		a_count;
+	__le32		a_owner_mask;
+	__le32		a_group_mask;
+	__le32		a_other_mask;
+};
+
+#define ACL4_XATTR_VERSION	0
+#define ACL4_XATTR_MAX_COUNT	1024
+
+extern struct richacl *richacl_from_xattr(const void *, size_t);
+extern size_t richacl_xattr_size(const struct richacl *acl);
+extern void richacl_to_xattr(const struct richacl *, void *);
+
+#endif /* __RICHACL_XATTR_H */
-- 
2.1.0


>From ae174bdfb12f44f592301bec7c0e69688bb4d3b7 Mon Sep 17 00:00:00 2001
Message-Id: <ae174bdfb12f44f592301bec7c0e69688bb4d3b7.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Sat, 14 Feb 2015 19:31:38 +0100
Subject: [RFC 17/21] vfs: Cache base_acl objects in inodes
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

POSIX ACLs and richacls are both objects allocated by kmalloc() with a
reference count which are freed by kfree_rcu().  An inode can either cache an
access and a default POSIX ACL, or a richacl.  (Richacls do not have default
acls).  To allow an inode to cache either of the two kinds of acls, introduce a
new base_acl type and convert i_acl and i_default_acl to that type. In most
cases, the vfs then doesn't have to care which kind of acl an inode caches (if
any).

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 fs/f2fs/acl.c                                   |  4 ++--
 fs/inode.c                                      |  4 ++--
 fs/posix_acl.c                                  | 18 +++++++++---------
 include/linux/fs.h                              | 22 +++++++++++++++++++---
 include/linux/posix_acl.h                       |  9 ++++-----
 include/linux/richacl.h                         |  2 +-
 7 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0c1b583..c8cae33 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1145,7 +1145,7 @@ void ll_clear_inode(struct inode *inode)
 	}
 #ifdef CONFIG_FS_POSIX_ACL
 	else if (lli->lli_posix_acl) {
-		LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) == 1);
+		LASSERT(atomic_read(&lli->lli_posix_acl->a_base.ba_refcount) == 1);
 		LASSERT(lli->lli_remote_perms == NULL);
 		posix_acl_release(lli->lli_posix_acl);
 		lli->lli_posix_acl = NULL;
diff --git a/fs/f2fs/acl.c b/fs/f2fs/acl.c
index 7422027..ccb2c7c 100644
--- a/fs/f2fs/acl.c
+++ b/fs/f2fs/acl.c
@@ -270,7 +270,7 @@ static struct posix_acl *f2fs_acl_clone(const struct posix_acl *acl,
 				sizeof(struct posix_acl_entry);
 		clone = kmemdup(acl, size, flags);
 		if (clone)
-			atomic_set(&clone->a_refcount, 1);
+			atomic_set(&clone->a_base.ba_refcount, 1);
 	}
 	return clone;
 }
@@ -282,7 +282,7 @@ static int f2fs_acl_create_masq(struct posix_acl *acl, umode_t *mode_p)
 	umode_t mode = *mode_p;
 	int not_equiv = 0;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
diff --git a/fs/inode.c b/fs/inode.c
index f00b16f..555fe9c 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -233,9 +233,9 @@ void __destroy_inode(struct inode *inode)
 
 #ifdef CONFIG_FS_POSIX_ACL
 	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_acl);
+		put_base_acl(inode->i_acl);
 	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
-		posix_acl_release(inode->i_default_acl);
+		put_base_acl(inode->i_default_acl);
 #endif
 	this_cpu_dec(nr_inodes);
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index efe983e..2fbfec8 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -25,9 +25,9 @@ struct posix_acl **acl_by_type(struct inode *inode, int type)
 {
 	switch (type) {
 	case ACL_TYPE_ACCESS:
-		return &inode->i_acl;
+		return (struct posix_acl **)&inode->i_acl;
 	case ACL_TYPE_DEFAULT:
-		return &inode->i_default_acl;
+		return (struct posix_acl **)&inode->i_default_acl;
 	default:
 		BUG();
 	}
@@ -83,16 +83,16 @@ EXPORT_SYMBOL(forget_cached_acl);
 
 void forget_all_cached_acls(struct inode *inode)
 {
-	struct posix_acl *old_access, *old_default;
+	struct base_acl *old_access, *old_default;
 	spin_lock(&inode->i_lock);
 	old_access = inode->i_acl;
 	old_default = inode->i_default_acl;
 	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
 	spin_unlock(&inode->i_lock);
 	if (old_access != ACL_NOT_CACHED)
-		posix_acl_release(old_access);
+		put_base_acl(old_access);
 	if (old_default != ACL_NOT_CACHED)
-		posix_acl_release(old_default);
+		put_base_acl(old_default);
 }
 EXPORT_SYMBOL(forget_all_cached_acls);
 
@@ -129,7 +129,7 @@ EXPORT_SYMBOL(get_acl);
 void
 posix_acl_init(struct posix_acl *acl, int count)
 {
-	atomic_set(&acl->a_refcount, 1);
+	atomic_set(&acl->a_base.ba_refcount, 1);
 	acl->a_count = count;
 }
 EXPORT_SYMBOL(posix_acl_init);
@@ -163,7 +163,7 @@ posix_acl_clone(const struct posix_acl *acl, gfp_t flags)
 		           sizeof(struct posix_acl_entry);
 		clone = kmemdup(acl, size, flags);
 		if (clone)
-			atomic_set(&clone->a_refcount, 1);
+			atomic_set(&clone->a_base.ba_refcount, 1);
 	}
 	return clone;
 }
@@ -385,7 +385,7 @@ static int posix_acl_create_masq(struct posix_acl *acl, umode_t *mode_p)
 	umode_t mode = *mode_p;
 	int not_equiv = 0;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
                 switch(pa->e_tag) {
@@ -440,7 +440,7 @@ static int __posix_acl_chmod_masq(struct posix_acl *acl, umode_t mode)
 	struct posix_acl_entry *group_obj = NULL, *mask_obj = NULL;
 	struct posix_acl_entry *pa, *pe;
 
-	/* assert(atomic_read(acl->a_refcount) == 1); */
+	/* assert(atomic_read(acl->a_base.ba_refcount) == 1); */
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
 		switch(pa->e_tag) {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e3e1e42..518b990 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -547,6 +547,9 @@ static inline void mapping_allow_writable(struct address_space *mapping)
 #define i_size_ordered_init(inode) do { } while (0)
 #endif
 
+struct base_acl {
+	atomic_t ba_refcount;
+};
 struct posix_acl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
@@ -566,9 +569,9 @@ struct inode {
 	kgid_t			i_gid;
 	unsigned int		i_flags;
 
-#ifdef CONFIG_FS_POSIX_ACL
-	struct posix_acl	*i_acl;
-	struct posix_acl	*i_default_acl;
+#if defined(CONFIG_FS_POSIX_ACL)
+	struct base_acl *i_acl;
+	struct base_acl *i_default_acl;
 #endif
 
 	const struct inode_operations	*i_op;
@@ -2936,4 +2939,17 @@ static inline bool dir_relax(struct inode *inode)
 	return !IS_DEADDIR(inode);
 }
 
+static inline struct base_acl *get_base_acl(struct base_acl *acl)
+{
+	if (acl)
+		atomic_inc(&acl->ba_refcount);
+	return acl;
+}
+
+static inline void put_base_acl(struct base_acl *acl)
+{
+	if (acl && atomic_dec_and_test(&acl->ba_refcount))
+		__kfree_rcu((struct rcu_head *)acl, 0);
+}
+
 #endif /* _LINUX_FS_H */
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 66cf477..2c46441 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -43,7 +43,7 @@ struct posix_acl_entry {
 };
 
 struct posix_acl {
-	atomic_t		a_refcount;
+	struct base_acl		a_base;
 	unsigned int		a_count;
 	struct posix_acl_entry	a_entries[0];
 };
@@ -58,8 +58,7 @@ struct posix_acl {
 static inline struct posix_acl *
 posix_acl_dup(struct posix_acl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -69,8 +68,8 @@ posix_acl_dup(struct posix_acl *acl)
 static inline void
 posix_acl_release(struct posix_acl *acl)
 {
-	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		__kfree_rcu((struct rcu_head *)acl, 0);
+	BUILD_BUG_ON(offsetof(struct posix_acl, a_base) != 0);
+	put_base_acl(&acl->a_base);
 }
 
 
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index a607d6f..60568c5 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -179,7 +179,7 @@ static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
 	if (acl)
-		atomic_inc(&acl->a_refcount);
+		atomic_inc(&acl->a_base.ba_refcount);
 	return acl;
 }
 
-- 
2.1.0


>From 3f5c803548a9fc24f1b7f0be25524fb6bd41ccdd Mon Sep 17 00:00:00 2001
Message-Id: <3f5c803548a9fc24f1b7f0be25524fb6bd41ccdd.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 19:28:44 +0530
Subject: [RFC 18/21] vfs: Cache richacl in struct inode
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Cache richacls in struct inode so that this doesn't have to be done
individually in each filesystem.  This is similar to POSIX ACLs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/inode.c              | 11 +++++--
 fs/posix_acl.c          |  2 +-
 fs/richacl_base.c       | 81 +++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/fs.h      |  6 +++-
 include/linux/richacl.h | 15 ++++++---
 5 files changed, 102 insertions(+), 13 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 555fe9c..5272412 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -175,8 +175,11 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	inode->i_private = NULL;
 	inode->i_mapping = mapping;
 	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
-#ifdef CONFIG_FS_POSIX_ACL
-	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
+	inode->i_acl = ACL_NOT_CACHED;
+# if defined(CONFIG_FS_POSIX_ACL)
+	inode->i_default_acl = ACL_NOT_CACHED;
+# endif
 #endif
 
 #ifdef CONFIG_FSNOTIFY
@@ -231,11 +234,13 @@ void __destroy_inode(struct inode *inode)
 		atomic_long_dec(&inode->i_sb->s_remove_count);
 	}
 
-#ifdef CONFIG_FS_POSIX_ACL
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
 	if (inode->i_acl && inode->i_acl != ACL_NOT_CACHED)
 		put_base_acl(inode->i_acl);
+# if defined(CONFIG_FS_POSIX_ACL)
 	if (inode->i_default_acl && inode->i_default_acl != ACL_NOT_CACHED)
 		put_base_acl(inode->i_default_acl);
+# endif
 #endif
 	this_cpu_dec(nr_inodes);
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 2fbfec8..ebf96b2 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -38,7 +38,7 @@ struct posix_acl *get_cached_acl(struct inode *inode, int type)
 {
 	struct posix_acl **p = acl_by_type(inode, type);
 	struct posix_acl *acl = ACCESS_ONCE(*p);
-	if (acl) {
+	if (acl && IS_POSIXACL(inode)) {
 		spin_lock(&inode->i_lock);
 		acl = *p;
 		if (acl != ACL_NOT_CACHED)
diff --git a/fs/richacl_base.c b/fs/richacl_base.c
index ec570ef..ea53ad5 100644
--- a/fs/richacl_base.c
+++ b/fs/richacl_base.c
@@ -21,6 +21,79 @@
 
 MODULE_LICENSE("GPL");
 
+struct richacl *get_cached_richacl(struct inode *inode)
+{
+	struct richacl *acl;
+
+	acl = (struct richacl *)ACCESS_ONCE(inode->i_acl);
+	if (acl && IS_RICHACL(inode)) {
+		spin_lock(&inode->i_lock);
+		acl = (struct richacl *)inode->i_acl;
+		if (acl != ACL_NOT_CACHED)
+			acl = richacl_get(acl);
+		spin_unlock(&inode->i_lock);
+	}
+	return acl;
+}
+EXPORT_SYMBOL(get_cached_richacl);
+
+struct richacl *get_cached_richacl_rcu(struct inode *inode)
+{
+	return (struct richacl *)rcu_dereference(inode->i_acl);
+}
+EXPORT_SYMBOL(get_cached_richacl_rcu);
+
+void set_cached_richacl(struct inode *inode, struct richacl *acl)
+{
+	struct base_acl *old = NULL;
+	spin_lock(&inode->i_lock);
+	old = inode->i_acl;
+	inode->i_acl = &(richacl_get(acl)->a_base);
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		put_base_acl(old);
+}
+EXPORT_SYMBOL(set_cached_richacl);
+
+void forget_cached_richacl(struct inode *inode)
+{
+	struct base_acl *old = NULL;
+	spin_lock(&inode->i_lock);
+	old = inode->i_acl;
+	inode->i_acl = ACL_NOT_CACHED;
+	spin_unlock(&inode->i_lock);
+	if (old != ACL_NOT_CACHED)
+		put_base_acl(old);
+}
+EXPORT_SYMBOL(forget_cached_richacl);
+
+struct richacl *get_richacl(struct inode *inode)
+{
+	struct richacl *acl;
+
+	acl = get_cached_richacl(inode);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+
+	if (!IS_RICHACL(inode))
+		return NULL;
+
+	/*
+	 * A filesystem can force a ACL callback by just never filling the
+	 * ACL cache. But normally you'd fill the cache either at inode
+	 * instantiation time, or on the first ->get_richacl call.
+	 *
+	 * If the filesystem doesn't have a get_richacl() function at all,
+	 * we'll just create the negative cache entry.
+	 */
+	if (!inode->i_op->get_richacl) {
+		set_cached_richacl(inode, NULL);
+		return NULL;
+	}
+	return inode->i_op->get_richacl(inode);
+}
+EXPORT_SYMBOL_GPL(get_richacl);
+
 /**
  * richacl_alloc  -  allocate a richacl
  * @count:	number of entries
@@ -28,11 +101,13 @@ MODULE_LICENSE("GPL");
 struct richacl *
 richacl_alloc(int count)
 {
-	size_t size = sizeof(struct richacl) + count * sizeof(struct richace);
+	size_t size = max(sizeof(struct rcu_head),
+		sizeof(struct richacl) +
+		count * sizeof(struct richace));
 	struct richacl *acl = kzalloc(size, GFP_KERNEL);
 
 	if (acl) {
-		atomic_set(&acl->a_refcount, 1);
+		atomic_set(&acl->a_base.ba_refcount, 1);
 		acl->a_count = count;
 	}
 	return acl;
@@ -51,7 +126,7 @@ richacl_clone(const struct richacl *acl)
 
 	if (dup) {
 		memcpy(dup, acl, size);
-		atomic_set(&dup->a_refcount, 1);
+		atomic_set(&dup->a_base.ba_refcount, 1);
 	}
 	return dup;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 518b990..e3f27b5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -551,6 +551,7 @@ struct base_acl {
 	atomic_t ba_refcount;
 };
 struct posix_acl;
+struct richacl;
 #define ACL_NOT_CACHED ((void *)(-1))
 
 #define IOP_FASTPERM	0x0001
@@ -569,9 +570,11 @@ struct inode {
 	kgid_t			i_gid;
 	unsigned int		i_flags;
 
-#if defined(CONFIG_FS_POSIX_ACL)
+#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
 	struct base_acl *i_acl;
+# if defined(CONFIG_FS_POSIX_ACL)
 	struct base_acl *i_default_acl;
+# endif
 #endif
 
 	const struct inode_operations	*i_op;
@@ -1586,6 +1589,7 @@ struct inode_operations {
 	void * (*follow_link) (struct dentry *, struct nameidata *);
 	int (*permission) (struct inode *, int);
 	struct posix_acl * (*get_acl)(struct inode *, int);
+	struct richacl * (*get_richacl)(struct inode *);
 
 	int (*readlink) (struct dentry *, char __user *,int);
 	void (*put_link) (struct dentry *, struct nameidata *, void *);
diff --git a/include/linux/richacl.h b/include/linux/richacl.h
index 60568c5..b314643 100644
--- a/include/linux/richacl.h
+++ b/include/linux/richacl.h
@@ -30,7 +30,7 @@ struct richace {
 };
 
 struct richacl {
-	atomic_t	a_refcount;
+	struct base_acl	a_base;
 	unsigned int	a_owner_mask;
 	unsigned int	a_group_mask;
 	unsigned int	a_other_mask;
@@ -178,8 +178,7 @@ struct richacl {
 static inline struct richacl *
 richacl_get(struct richacl *acl)
 {
-	if (acl)
-		atomic_inc(&acl->a_base.ba_refcount);
+	get_base_acl(&acl->a_base);
 	return acl;
 }
 
@@ -189,10 +188,16 @@ richacl_get(struct richacl *acl)
 static inline void
 richacl_put(struct richacl *acl)
 {
-	if (acl && atomic_dec_and_test(&acl->a_refcount))
-		kfree(acl);
+	BUILD_BUG_ON(offsetof(struct richacl, a_base) != 0);
+	put_base_acl(&acl->a_base);
 }
 
+extern struct richacl *get_cached_richacl(struct inode *);
+extern struct richacl *get_cached_richacl_rcu(struct inode *);
+extern void set_cached_richacl(struct inode *, struct richacl *);
+extern void forget_cached_richacl(struct inode *);
+extern struct richacl *get_richacl(struct inode *);
+
 static inline int
 richacl_is_auto_inherit(const struct richacl *acl)
 {
-- 
2.1.0


>From b467e4dcfbff041accd57839765468c4042a20c5 Mon Sep 17 00:00:00 2001
Message-Id: <b467e4dcfbff041accd57839765468c4042a20c5.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 1 Apr 2014 18:08:42 +0530
Subject: [RFC 19/21] vfs: Add richacl permission checking
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Hook the richacl permission checking function into the vfs.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/namei.c     | 51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/posix_acl.c |  6 +++---
 2 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a8d1674..d5b4fcd 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -35,6 +35,7 @@
 #include <linux/fs_struct.h>
 #include <linux/posix_acl.h>
 #include <linux/hash.h>
+#include <linux/richacl.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -256,7 +257,40 @@ void putname(struct filename *name)
 		__putname(name);
 }
 
-static int check_acl(struct inode *inode, int mask)
+static int check_richacl(struct inode *inode, int mask)
+{
+#ifdef CONFIG_FS_RICHACL
+	struct richacl *acl;
+
+	if (mask & MAY_NOT_BLOCK) {
+		acl = get_cached_richacl_rcu(inode);
+		if (!acl)
+			goto no_acl;
+		/* no ->get_richacl() calls in RCU mode... */
+		if (acl == ACL_NOT_CACHED)
+			return -ECHILD;
+		return richacl_permission(inode, acl, mask & ~MAY_NOT_BLOCK);
+	}
+
+	acl = get_richacl(inode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl) {
+		int error = richacl_permission(inode, acl, mask);
+		richacl_put(acl);
+		return error;
+	}
+no_acl:
+#endif
+	if (mask & (MAY_DELETE_SELF | MAY_TAKE_OWNERSHIP |
+		    MAY_CHMOD | MAY_SET_TIMES)) {
+		/* File permission bits cannot grant this. */
+		return -EACCES;
+	}
+	return -EAGAIN;
+}
+
+static int check_posix_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl *acl;
@@ -291,11 +325,24 @@ static int acl_permission_check(struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
 
+	/*
+	 * With POSIX ACLs, the (mode & S_IRWXU) bits exactly match the owner
+	 * permissions, and we can skip checking posix acls for the owner.
+	 * With richacls, the owner may be granted fewer permissions than the
+	 * mode bits seem to suggest (for example, append but not write), and
+	 * we always need to check the richacl.
+	 */
+
+	if (IS_RICHACL(inode)) {
+		int error = check_richacl(inode, mask);
+		if (error != -EAGAIN)
+			return error;
+	}
 	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
 		mode >>= 6;
 	else {
 		if (IS_POSIXACL(inode) && (mode & S_IRWXG)) {
-			int error = check_acl(inode, mask);
+			int error = check_posix_acl(inode, mask);
 			if (error != -EAGAIN)
 				return error;
 		}
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index ebf96b2..16464f0 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -100,13 +100,13 @@ struct posix_acl *get_acl(struct inode *inode, int type)
 {
 	struct posix_acl *acl;
 
+	if (!IS_POSIXACL(inode))
+		return NULL;
+
 	acl = get_cached_acl(inode, type);
 	if (acl != ACL_NOT_CACHED)
 		return acl;
 
-	if (!IS_POSIXACL(inode))
-		return NULL;
-
 	/*
 	 * A filesystem can force a ACL callback by just never filling the
 	 * ACL cache. But normally you'd fill the cache either at inode
-- 
2.1.0


>From c6043a752cec38940291b0caca452826afb1fa04 Mon Sep 17 00:00:00 2001
Message-Id: <c6043a752cec38940291b0caca452826afb1fa04.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 23 Apr 2014 20:54:41 +0530
Subject: [RFC 20/21] ext4: Implement rich acl for ext4
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

Support the richacl permission model in ext4.  The richacls are stored in
"system.richacl" xattrs.  Richacls need to be enabled by tune2fs or at file
system create time.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/Kconfig   |  15 ++++
 fs/ext4/Makefile  |   1 +
 fs/ext4/acl.c     |   7 +-
 fs/ext4/acl.h     |  12 +--
 fs/ext4/file.c    |   6 +-
 fs/ext4/ialloc.c  |   7 +-
 fs/ext4/inode.c   |  10 ++-
 fs/ext4/namei.c   |  11 ++-
 fs/ext4/richacl.c | 229 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/richacl.h |  47 +++++++++++
 fs/ext4/xattr.c   |   6 ++
 fs/ext4/xattr.h   |   1 +
 12 files changed, 332 insertions(+), 20 deletions(-)
 create mode 100644 fs/ext4/richacl.c
 create mode 100644 fs/ext4/richacl.h

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index efea5d5..8c821d2 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -73,3 +73,18 @@ config EXT4_DEBUG
 	  If you select Y here, then you will be able to turn on debugging
 	  with a command such as:
 		echo 1 > /sys/module/ext4/parameters/mballoc_debug
+
+config EXT4_FS_RICHACL
+	bool "Ext4 Rich Access Control Lists (EXPERIMENTAL)"
+	depends on EXT4_FS
+	select FS_RICHACL
+	help
+	  Rich ACLs are an implementation of NFSv4 ACLs, extended by file masks
+	  to fit into the standard POSIX file permission model.  They are
+	  designed to work seamlessly locally as well as across the NFSv4 and
+	  CIFS/SMB2 network file system protocols.
+
+	  To learn more about Rich ACL, visit
+	  http://acl.bestbits.at/richacl/
+
+	  If you don't know what Rich ACLs are, say N
diff --git a/fs/ext4/Makefile b/fs/ext4/Makefile
index 0310fec..b9a3e2e 100644
--- a/fs/ext4/Makefile
+++ b/fs/ext4/Makefile
@@ -12,3 +12,4 @@ ext4-y	:= balloc.o bitmap.o dir.o file.o fsync.o ialloc.o inode.o page-io.o \
 
 ext4-$(CONFIG_EXT4_FS_POSIX_ACL)	+= acl.o
 ext4-$(CONFIG_EXT4_FS_SECURITY)		+= xattr_security.o
+ext4-$(CONFIG_EXT4_FS_RICHACL) 		+= richacl.o
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index d40c8db..7c508f7 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -144,8 +144,7 @@ fail:
  *
  * inode->i_mutex: don't care
  */
-struct posix_acl *
-ext4_get_acl(struct inode *inode, int type)
+struct posix_acl *ext4_get_posix_acl(struct inode *inode, int type)
 {
 	int name_index;
 	char *value = NULL;
@@ -239,7 +238,7 @@ __ext4_set_acl(handle_t *handle, struct inode *inode, int type,
 }
 
 int
-ext4_set_acl(struct inode *inode, struct posix_acl *acl, int type)
+ext4_set_posix_acl(struct inode *inode, struct posix_acl *acl, int type)
 {
 	handle_t *handle;
 	int error, retries = 0;
@@ -264,7 +263,7 @@ retry:
  * inode->i_mutex: up (access to inode is still exclusive)
  */
 int
-ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
+ext4_init_posix_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 {
 	struct posix_acl *default_acl, *acl;
 	int error;
diff --git a/fs/ext4/acl.h b/fs/ext4/acl.h
index da2c795..450b4d1 100644
--- a/fs/ext4/acl.h
+++ b/fs/ext4/acl.h
@@ -54,17 +54,17 @@ static inline int ext4_acl_count(size_t size)
 #ifdef CONFIG_EXT4_FS_POSIX_ACL
 
 /* acl.c */
-struct posix_acl *ext4_get_acl(struct inode *inode, int type);
-int ext4_set_acl(struct inode *inode, struct posix_acl *acl, int type);
-extern int ext4_init_acl(handle_t *, struct inode *, struct inode *);
+struct posix_acl *ext4_get_posix_acl(struct inode *inode, int type);
+int ext4_set_posix_acl(struct inode *inode, struct posix_acl *acl, int type);
+extern int ext4_init_posix_acl(handle_t *, struct inode *, struct inode *);
 
 #else  /* CONFIG_EXT4_FS_POSIX_ACL */
 #include <linux/sched.h>
-#define ext4_get_acl NULL
-#define ext4_set_acl NULL
+#define ext4_get_posix_acl NULL
+#define ext4_set_posix_acl NULL
 
 static inline int
-ext4_init_acl(handle_t *handle, struct inode *inode, struct inode *dir)
+ext4_init_posix_acl(handle_t *handle, struct inode *inode, struct inode *dir)
 {
 	return 0;
 }
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 33a09da..be466f7 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -30,6 +30,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 /*
  * Called when an inode is released. Note that this is different
@@ -651,8 +652,9 @@ const struct inode_operations ext4_file_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 	.fiemap		= ext4_fiemap,
 };
 
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index ac644c3..97d1c4b 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -28,6 +28,7 @@
 #include "ext4_jbd2.h"
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -1039,7 +1040,11 @@ got:
 	if (err)
 		goto fail_drop;
 
-	err = ext4_init_acl(handle, inode, dir);
+	if (EXT4_IS_RICHACL(dir))
+		err = ext4_init_richacl(handle, inode, dir);
+	else
+		err = ext4_init_posix_acl(handle, inode, dir);
+
 	if (err)
 		goto fail_free_drop;
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5cb9a21..c379742 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -44,6 +44,7 @@
 #include "xattr.h"
 #include "acl.h"
 #include "truncate.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 
@@ -4657,9 +4658,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (orphan && inode->i_nlink)
 		ext4_orphan_del(NULL, inode);
 
-	if (!rc && (ia_valid & ATTR_MODE))
-		rc = posix_acl_chmod(inode, inode->i_mode);
-
+	if (!rc && (ia_valid & ATTR_MODE)) {
+		if (EXT4_IS_RICHACL(inode))
+			rc = ext4_richacl_chmod(inode);
+		else
+			rc = posix_acl_chmod(inode, inode->i_mode);
+	}
 err_out:
 	ext4_std_error(inode->i_sb, error);
 	if (!error)
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 28fe71a..da8f498 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -39,6 +39,7 @@
 
 #include "xattr.h"
 #include "acl.h"
+#include "richacl.h"
 
 #include <trace/events/ext4.h>
 /*
@@ -3541,8 +3542,9 @@ const struct inode_operations ext4_dir_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 	.fiemap         = ext4_fiemap,
 };
 
@@ -3552,6 +3554,7 @@ const struct inode_operations ext4_special_inode_operations = {
 	.getxattr	= generic_getxattr,
 	.listxattr	= ext4_listxattr,
 	.removexattr	= generic_removexattr,
-	.get_acl	= ext4_get_acl,
-	.set_acl	= ext4_set_acl,
+	.get_acl	= ext4_get_posix_acl,
+	.set_acl	= ext4_set_posix_acl,
+	.get_richacl	= ext4_get_richacl,
 };
diff --git a/fs/ext4/richacl.c b/fs/ext4/richacl.c
new file mode 100644
index 0000000..89c10ab
--- /dev/null
+++ b/fs/ext4/richacl.c
@@ -0,0 +1,229 @@
+/*
+ * Copyright IBM Corporation, 2010
+ * Copyright (C) 2015  Red Hat, Inc.
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/richacl_xattr.h>
+
+#include "ext4.h"
+#include "ext4_jbd2.h"
+#include "xattr.h"
+#include "acl.h"
+#include "richacl.h"
+
+struct richacl *
+ext4_get_richacl(struct inode *inode)
+{
+	const int name_index = EXT4_XATTR_INDEX_RICHACL;
+	void *value = NULL;
+	struct richacl *acl;
+	int retval;
+
+	if (!IS_RICHACL(inode))
+		return ERR_PTR(-EOPNOTSUPP);
+	acl = get_cached_richacl(inode);
+	if (acl != ACL_NOT_CACHED)
+		return acl;
+	retval = ext4_xattr_get(inode, name_index, "", NULL, 0);
+	if (retval > 0) {
+		value = kmalloc(retval, GFP_KERNEL);
+		if (!value)
+			return ERR_PTR(-ENOMEM);
+		retval = ext4_xattr_get(inode, name_index, "", value, retval);
+	}
+	if (retval > 0) {
+		acl = richacl_from_xattr(value, retval);
+		if (acl == ERR_PTR(-EINVAL))
+			acl = ERR_PTR(-EIO);
+	} else if (retval == -ENODATA || retval == -ENOSYS)
+		acl = NULL;
+	else
+		acl = ERR_PTR(retval);
+	kfree(value);
+
+	if (!IS_ERR_OR_NULL(acl))
+		set_cached_richacl(inode, acl);
+
+	return acl;
+}
+
+static int
+ext4_set_richacl(handle_t *handle, struct inode *inode, struct richacl *acl)
+{
+	const int name_index = EXT4_XATTR_INDEX_RICHACL;
+	size_t size = 0;
+	void *value = NULL;
+	int retval;
+
+	if (acl) {
+		mode_t mode = inode->i_mode;
+		if (richacl_equiv_mode(acl, &mode) == 0) {
+			inode->i_mode = mode;
+			ext4_mark_inode_dirty(handle, inode);
+			acl = NULL;
+		}
+	}
+	if (acl) {
+		size = richacl_xattr_size(acl);
+		value = kmalloc(size, GFP_KERNEL);
+		if (!value)
+			return -ENOMEM;
+		richacl_to_xattr(acl, value);
+	}
+	if (handle)
+		retval = ext4_xattr_set_handle(handle, inode, name_index, "",
+					       value, size, 0);
+	else
+		retval = ext4_xattr_set(inode, name_index, "", value, size, 0);
+	kfree(value);
+	if (!retval)
+		set_cached_richacl(inode, acl);
+
+	return retval;
+}
+
+int
+ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
+{
+	struct richacl *dir_acl = NULL;
+
+	if (!S_ISLNK(inode->i_mode)) {
+		dir_acl = ext4_get_richacl(dir);
+		if (IS_ERR(dir_acl))
+			return PTR_ERR(dir_acl);
+	}
+	if (dir_acl) {
+		struct richacl *acl;
+		int retval;
+
+		acl = richacl_inherit_inode(dir_acl, inode);
+		richacl_put(dir_acl);
+
+		retval = PTR_ERR(acl);
+		if (acl && !IS_ERR(acl)) {
+			retval = ext4_set_richacl(handle, inode, acl);
+			richacl_put(acl);
+		}
+		return retval;
+	} else {
+		inode->i_mode &= ~current_umask();
+		return 0;
+	}
+}
+
+int
+ext4_richacl_chmod(struct inode *inode)
+{
+	struct richacl *acl;
+	int retval;
+
+	if (S_ISLNK(inode->i_mode))
+		return -EOPNOTSUPP;
+	acl = ext4_get_richacl(inode);
+	if (IS_ERR_OR_NULL(acl))
+		return PTR_ERR(acl);
+	acl = richacl_chmod(acl, inode->i_mode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	retval = ext4_set_richacl(NULL, inode, acl);
+	richacl_put(acl);
+
+	return retval;
+}
+
+static size_t
+ext4_xattr_list_richacl(struct dentry *dentry, char *list, size_t list_len,
+			const char *name, size_t name_len, int type)
+{
+	const size_t size = sizeof(RICHACL_XATTR);
+	if (!IS_RICHACL(dentry->d_inode))
+		return 0;
+	if (list && size <= list_len)
+		memcpy(list, RICHACL_XATTR, size);
+	return size;
+}
+
+static int
+ext4_xattr_get_richacl(struct dentry *dentry, const char *name, void *buffer,
+		size_t buffer_size, int type)
+{
+	struct richacl *acl;
+	size_t size;
+
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	acl = ext4_get_richacl(dentry->d_inode);
+	if (IS_ERR(acl))
+		return PTR_ERR(acl);
+	if (acl == NULL)
+		return -ENODATA;
+	size = richacl_xattr_size(acl);
+	if (buffer) {
+		if (size > buffer_size)
+			return -ERANGE;
+		richacl_to_xattr(acl, buffer);
+	}
+	richacl_put(acl);
+
+	return size;
+}
+
+static int
+ext4_xattr_set_richacl(struct dentry *dentry, const char *name,
+		const void *value, size_t size, int flags, int type)
+{
+	handle_t *handle;
+	struct richacl *acl = NULL;
+	int retval, retries = 0;
+	struct inode *inode = dentry->d_inode;
+
+	if (!IS_RICHACL(dentry->d_inode))
+		return -EOPNOTSUPP;
+	if (S_ISLNK(inode->i_mode))
+		return -EOPNOTSUPP;
+	if (strcmp(name, "") != 0)
+		return -EINVAL;
+	if (!uid_eq(current_fsuid(), inode->i_uid) &&
+	    inode_permission(inode, MAY_CHMOD) &&
+	    !capable(CAP_FOWNER))
+		return -EPERM;
+	if (value) {
+		acl = richacl_from_xattr(value, size);
+		if (IS_ERR(acl))
+			return PTR_ERR(acl);
+
+		inode->i_mode &= ~S_IRWXUGO;
+		inode->i_mode |= richacl_masks_to_mode(acl);
+	}
+
+retry:
+	handle = ext4_journal_start(inode, EXT4_HT_XATTR,
+				    EXT4_DATA_TRANS_BLOCKS(inode->i_sb));
+	if (IS_ERR(handle))
+		return PTR_ERR(handle);
+	retval = ext4_set_richacl(handle, inode, acl);
+	ext4_journal_stop(handle);
+	if (retval == -ENOSPC && ext4_should_retry_alloc(inode->i_sb, &retries))
+		goto retry;
+	richacl_put(acl);
+	return retval;
+}
+
+const struct xattr_handler ext4_richacl_xattr_handler = {
+	.prefix	= RICHACL_XATTR,
+	.list	= ext4_xattr_list_richacl,
+	.get	= ext4_xattr_get_richacl,
+	.set	= ext4_xattr_set_richacl,
+};
diff --git a/fs/ext4/richacl.h b/fs/ext4/richacl.h
new file mode 100644
index 0000000..09a5cad
--- /dev/null
+++ b/fs/ext4/richacl.h
@@ -0,0 +1,47 @@
+/*
+ * Copyright IBM Corporation, 2010
+ * Copyright (C)  2015 Red Hat, Inc.
+ * Author Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2.1 of the GNU Lesser General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ *
+ */
+
+#ifndef __FS_EXT4_RICHACL_H
+#define __FS_EXT4_RICHACL_H
+
+#include <linux/richacl.h>
+
+#ifdef CONFIG_EXT4_FS_RICHACL
+
+#define EXT4_IS_RICHACL(inode) IS_RICHACL(inode)
+
+extern struct richacl *ext4_get_richacl(struct inode *);
+extern int ext4_init_richacl(handle_t *, struct inode *, struct inode *);
+extern int ext4_richacl_chmod(struct inode *);
+
+#else  /* CONFIG_FS_EXT4_RICHACL */
+
+#define EXT4_IS_RICHACL(inode) (0)
+#define ext4_get_richacl   NULL
+
+static inline int
+ext4_init_richacl(handle_t *handle, struct inode *inode, struct inode *dir)
+{
+	return 0;
+}
+
+static inline int
+ext4_richacl_chmod(struct inode *inode)
+{
+	return 0;
+}
+
+#endif  /* CONFIG_FS_EXT4_RICHACL */
+#endif  /* __FS_EXT4_RICHACL_H */
diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
index 1e09fc7..815a306 100644
--- a/fs/ext4/xattr.c
+++ b/fs/ext4/xattr.c
@@ -100,6 +100,9 @@ static const struct xattr_handler *ext4_xattr_handler_map[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	[EXT4_XATTR_INDEX_SECURITY]	     = &ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	[EXT4_XATTR_INDEX_RICHACL]           = &ext4_richacl_xattr_handler,
+#endif
 };
 
 const struct xattr_handler *ext4_xattr_handlers[] = {
@@ -112,6 +115,9 @@ const struct xattr_handler *ext4_xattr_handlers[] = {
 #ifdef CONFIG_EXT4_FS_SECURITY
 	&ext4_xattr_security_handler,
 #endif
+#ifdef CONFIG_EXT4_FS_RICHACL
+	&ext4_richacl_xattr_handler,
+#endif
 	NULL
 };
 
diff --git a/fs/ext4/xattr.h b/fs/ext4/xattr.h
index 29bedf5..065821e 100644
--- a/fs/ext4/xattr.h
+++ b/fs/ext4/xattr.h
@@ -97,6 +97,7 @@ struct ext4_xattr_ibody_find {
 extern const struct xattr_handler ext4_xattr_user_handler;
 extern const struct xattr_handler ext4_xattr_trusted_handler;
 extern const struct xattr_handler ext4_xattr_security_handler;
+extern const struct xattr_handler ext4_richacl_xattr_handler;
 
 extern ssize_t ext4_listxattr(struct dentry *, char *, size_t);
 
-- 
2.1.0


>From 2743598850b5ac481b91b7fea5f6f00a04e8beae Mon Sep 17 00:00:00 2001
Message-Id: <2743598850b5ac481b91b7fea5f6f00a04e8beae.1424900921.git.agruenba@redhat.com>
In-Reply-To: <cover.1424900921.git.agruenba@redhat.com>
References: <cover.1424900921.git.agruenba@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 23 Apr 2014 20:54:54 +0530
Subject: [RFC 21/21] ext4: Add richacl feature flag
To: linux-kernel@vger.kernel.org,
    linux-fsdevel@vger.kernel.org,
    linux-nfs@vger.kernel.org

This feature flag selects richacl instead of posix acl support on the file
system. In addition, the "acl" mount option is needed for enabling either of
the two kinds of acls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/ext4/ext4.h  |  6 ++++--
 fs/ext4/super.c | 41 ++++++++++++++++++++++++++++++++---------
 2 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index f63c3d5..64187cd 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -978,7 +978,7 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_UPDATE_JOURNAL	0x01000	/* Update the journal format */
 #define EXT4_MOUNT_NO_UID32		0x02000  /* Disable 32-bit UIDs */
 #define EXT4_MOUNT_XATTR_USER		0x04000	/* Extended user attributes */
-#define EXT4_MOUNT_POSIX_ACL		0x08000	/* POSIX Access Control Lists */
+#define EXT4_MOUNT_ACL			0x08000	/* Access Control Lists */
 #define EXT4_MOUNT_NO_AUTO_DA_ALLOC	0x10000	/* No auto delalloc mapping */
 #define EXT4_MOUNT_BARRIER		0x20000 /* Use block barriers */
 #define EXT4_MOUNT_QUOTA		0x80000 /* Some quota option set */
@@ -1552,6 +1552,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 #define EXT4_FEATURE_INCOMPAT_LARGEDIR		0x4000 /* >2GB or 3-lvl htree */
 #define EXT4_FEATURE_INCOMPAT_INLINE_DATA	0x8000 /* data in inode */
 #define EXT4_FEATURE_INCOMPAT_ENCRYPT		0x10000
+#define EXT4_FEATURE_INCOMPAT_RICHACL		0x20000
 
 #define EXT2_FEATURE_COMPAT_SUPP	EXT4_FEATURE_COMPAT_EXT_ATTR
 #define EXT2_FEATURE_INCOMPAT_SUPP	(EXT4_FEATURE_INCOMPAT_FILETYPE| \
@@ -1576,7 +1577,8 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 					 EXT4_FEATURE_INCOMPAT_64BIT| \
 					 EXT4_FEATURE_INCOMPAT_FLEX_BG| \
 					 EXT4_FEATURE_INCOMPAT_MMP |	\
-					 EXT4_FEATURE_INCOMPAT_INLINE_DATA)
+					 EXT4_FEATURE_INCOMPAT_INLINE_DATA | \
+					 EXT4_FEATURE_INCOMPAT_RICHACL)
 #define EXT4_FEATURE_RO_COMPAT_SUPP	(EXT4_FEATURE_RO_COMPAT_SPARSE_SUPER| \
 					 EXT4_FEATURE_RO_COMPAT_LARGE_FILE| \
 					 EXT4_FEATURE_RO_COMPAT_GDT_CSUM| \
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index e061e66..4226898 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1242,6 +1242,27 @@ static ext4_fsblk_t get_sb_block(void **data)
 	return sb_block;
 }
 
+static int enable_acl(struct super_block *sb)
+{
+	sb->s_flags &= ~(MS_POSIXACL | MS_RICHACL);
+	if (test_opt(sb, ACL)) {
+		if (EXT4_HAS_INCOMPAT_FEATURE(sb, EXT4_FEATURE_INCOMPAT_RICHACL)) {
+#ifdef CONFIG_EXT4_FS_RICHACL
+			sb->s_flags |= MS_RICHACL;
+#else
+			return -EOPNOTSUPP;
+#endif
+		} else {
+#ifdef CONFIG_EXT4_FS_POSIX_ACL
+			sb->s_flags |= MS_POSIXACL;
+#else
+			return -EOPNOTSUPP;
+#endif
+		}
+	}
+	return 0;
+}
+
 #define DEFAULT_JOURNAL_IOPRIO (IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, 3))
 static char deprecated_msg[] = "Mount option \"%s\" will be removed by %s\n"
 	"Contact linux-ext4@vger.kernel.org if you think we should keep it.\n";
@@ -1388,9 +1409,9 @@ static const struct mount_opts {
 	 MOPT_NO_EXT2 | MOPT_DATAJ},
 	{Opt_user_xattr, EXT4_MOUNT_XATTR_USER, MOPT_SET},
 	{Opt_nouser_xattr, EXT4_MOUNT_XATTR_USER, MOPT_CLEAR},
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	{Opt_acl, EXT4_MOUNT_POSIX_ACL, MOPT_SET},
-	{Opt_noacl, EXT4_MOUNT_POSIX_ACL, MOPT_CLEAR},
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+	{Opt_acl, EXT4_MOUNT_ACL, MOPT_SET},
+	{Opt_noacl, EXT4_MOUNT_ACL, MOPT_CLEAR},
 #else
 	{Opt_acl, 0, MOPT_NOSUPPORT},
 	{Opt_noacl, 0, MOPT_NOSUPPORT},
@@ -3538,8 +3559,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		set_opt(sb, NO_UID32);
 	/* xattr user namespace & acls are now defaulted on */
 	set_opt(sb, XATTR_USER);
-#ifdef CONFIG_EXT4_FS_POSIX_ACL
-	set_opt(sb, POSIX_ACL);
+#if defined(CONFIG_EXT4_FS_POSIX_ACL) || defined(CONFIG_EXT4_FS_RICHACL)
+	set_opt(sb, ACL);
 #endif
 	/* don't forget to enable journal_csum when metadata_csum is enabled. */
 	if (ext4_has_metadata_csum(sb))
@@ -3620,8 +3641,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 			clear_opt(sb, DELALLOC);
 	}
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
+	err = enable_acl(sb);
+	if (err)
+		goto failed_mount;
 
 	if (le32_to_cpu(es->s_rev_level) == EXT4_GOOD_OLD_REV &&
 	    (EXT4_HAS_COMPAT_FEATURE(sb, ~0U) ||
@@ -4913,8 +4935,9 @@ static int ext4_remount(struct super_block *sb, int *flags, char *data)
 	if (sbi->s_mount_flags & EXT4_MF_FS_ABORTED)
 		ext4_abort(sb, "Abort forced by user");
 
-	sb->s_flags = (sb->s_flags & ~MS_POSIXACL) |
-		(test_opt(sb, POSIX_ACL) ? MS_POSIXACL : 0);
+	err = enable_acl(sb);
+	if (err)
+		goto restore_opts;
 
 	es = sbi->s_es;
 
-- 
2.1.0

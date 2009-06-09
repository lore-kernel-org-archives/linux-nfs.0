From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2] flow control for WRITE requests
Date: Tue, 09 Jun 2009 19:05:19 -0400
Message-ID: <1244588719.24750.20.camel@heimdal.trondhjem.org>
References: <49C93526.70303@redhat.com>
	 <20090324211917.GJ19389@fieldses.org>  <4A1D9210.8070102@redhat.com>
	 <1243457149.8522.68.camel@heimdal.trondhjem.org>
	 <4A1EB09A.8030809@redhat.com>
	 <1243892886.4868.74.camel@heimdal.trondhjem.org>
	 <4A257167.9090304@redhat.com>
	 <1243980736.4868.314.camel@heimdal.trondhjem.org>
	 <4A268603.4090901@redhat.com>  <4A2EE2F6.7010403@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-dlG9oiA1jorrghM9i+Kz"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40497 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbZFIXFX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 19:05:23 -0400
In-Reply-To: <4A2EE2F6.7010403@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-dlG9oiA1jorrghM9i+Kz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2009-06-09 at 18:32 -0400, Peter Staubach wrote:
> I still need to move this along.

Sorry, it has been a long week at home (state championships,
graduation...).

I did promise to send a dump of the state of the fstatat() stuff from
LSF (see attachments).

As for the patch you posted, I did have comments that haven't really
been addressed. As I said, I certainly don't see the need to have
write() wait for writebacks to complete. I also don't accept that we
need to treat random writes as fundamentally different from serial
writes.
I'm currently inclining towards adding a switch to turn off strict posix
behaviour. There weren't too many people asking for it earlier, and
there aren't that many applications out there that are sensitive to the
exact mtime. Samba and backup applications are the major exceptions to
that rule, but you don't really run those on top of NFS clients if you
can avoid it...

Cheers
  Trond


--=-dlG9oiA1jorrghM9i+Kz
Content-Disposition: inline; filename="1"
Content-Type: application/mbox; name="1"
Content-Transfer-Encoding: 7bit

>From 88971fb7e6f45f238defcc8fbb3e8a1201280e21 Mon Sep 17 00:00:00 2001
From: Mark Fasheh <mfasheh@suse.com>
Date: Tue, 7 Apr 2009 01:00:46 -0700
Subject: [PATCH 1/3] vfs: 'stat light' fstatat flags

This very, very rough patch set adds three flags to fstatat - AT_NO_SIZE,
AT_NO_TIMES, and AT_STRICT.

The first two flags (AT_NO_SIZE, AT_NO_TIMES) allow userspace to notify the
file system layer that certain stat fields are not required to be accurate.
Some file systems want this information in order to optimize away expensive
operations associated with stat. In particular, NFS can avoid some syncing
to the server (if userspace doesn't want atime, ctime or mtime) and Lustre
can avoid some expensive locking by avoiding an update of various size
fields (st_size, st_blocks).

AT_STRICT allows userspace to indicate that it wants the most up to date
version of a files status, regardless of performance impact. A distributed
file system which has a non-coherent inode cache would know then to send a
direct query to it's server.

As noted previously, these patches are really rough. Mostly I'd like to get
some feedback on the interface and general direction of implementation. Some
glaring issues which we want to resolve:

- This patch set doesn't actually wire up any client file systems yet :)

- There's the question of whether we wire up [fl]stat(2) variants instead of
  using fstatat. I went with the former as the implementation was more
  straight forward.

- I'm not sure whether we want to force zeroing of the optional fields, or
  return whatever's in the inode (which may be stale, or just junk).

- Testing has been very light (compiles and boots on x86_64). There really
  isn't a whole lot to test yet anyway.

- There's probably other issues I'm missing :)

Finally, credit should be given to Sage Weil, Ted Tso, Andreas Dilger,
Russell Cattelan, Trond Myklebust and others at LSF who participated in a
lively discussion on this topic :)

Signed-off-by: Mark Fasheh <mfasheh@suse.com>
---
 arch/arm/kernel/sys_oabi-compat.c |    4 +-
 arch/s390/kernel/compat_linux.c   |    4 +-
 arch/sparc/kernel/sys_sparc32.c   |    4 +-
 arch/x86/ia32/sys_ia32.c          |    4 +-
 drivers/block/loop.c              |    2 +-
 fs/compat.c                       |    8 +++---
 fs/libfs.c                        |    2 +-
 fs/nfsd/nfs3proc.c                |    2 +-
 fs/nfsd/nfs3xdr.c                 |    4 +-
 fs/nfsd/nfs4xdr.c                 |    5 ++-
 fs/nfsd/nfsproc.c                 |    6 ++--
 fs/nfsd/nfsxdr.c                  |    2 +-
 fs/stat.c                         |   44 +++++++++++++++++++++---------------
 include/linux/fcntl.h             |    6 +++++
 include/linux/fs.h                |   12 ++++++----
 15 files changed, 63 insertions(+), 46 deletions(-)

diff --git a/arch/arm/kernel/sys_oabi-compat.c b/arch/arm/kernel/sys_oabi-compat.c
index 42623db..b48a9ac 100644
--- a/arch/arm/kernel/sys_oabi-compat.c
+++ b/arch/arm/kernel/sys_oabi-compat.c
@@ -182,9 +182,9 @@ asmlinkage long sys_oabi_fstatat64(int dfd,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 	error = cp_oldabi_stat64(&stat, statbuf);
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 6cc87d8..de65f40 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -708,9 +708,9 @@ asmlinkage long sys32_fstatat64(unsigned int dfd, char __user *filename,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_stat64(statbuf, &stat);
diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index e800503..387823e 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -212,9 +212,9 @@ asmlinkage long compat_sys_fstatat64(unsigned int dfd, char __user *filename,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_compat_stat64(&stat, statbuf);
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index efac92f..003c452 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -135,9 +135,9 @@ asmlinkage long sys32_fstatat(unsigned int dfd, char __user *filename,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_stat64(statbuf, &stat);
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 40b17d3..36b6f80 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1062,7 +1062,7 @@ loop_get_status(struct loop_device *lo, struct loop_info64 *info)
 
 	if (lo->lo_state != Lo_bound)
 		return -ENXIO;
-	error = vfs_getattr(file->f_path.mnt, file->f_path.dentry, &stat);
+	error = vfs_getattr(file->f_path.mnt, file->f_path.dentry, &stat, 0);
 	if (error)
 		return error;
 	memset(info, 0, sizeof(*info));
diff --git a/fs/compat.c b/fs/compat.c
index 3f84d5f..f1b8ca9 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -181,7 +181,7 @@ asmlinkage long compat_sys_newstat(char __user * filename,
 		struct compat_stat __user *statbuf)
 {
 	struct kstat stat;
-	int error = vfs_stat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_stat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_compat_stat(&stat, statbuf);
@@ -192,7 +192,7 @@ asmlinkage long compat_sys_newlstat(char __user * filename,
 		struct compat_stat __user *statbuf)
 {
 	struct kstat stat;
-	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_compat_stat(&stat, statbuf);
@@ -210,9 +210,9 @@ asmlinkage long compat_sys_newfstatat(unsigned int dfd, char __user *filename,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_compat_stat(&stat, statbuf);
diff --git a/fs/libfs.c b/fs/libfs.c
index cd22319..80d6c81 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -13,7 +13,7 @@
 #include <asm/uaccess.h>
 
 int simple_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		   struct kstat *stat)
+		   struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 7c9fe83..63078f4 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -70,7 +70,7 @@ nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 		RETURN_STATUS(nfserr);
 
 	err = vfs_getattr(resp->fh.fh_export->ex_path.mnt,
-			  resp->fh.fh_dentry, &resp->stat);
+			  resp->fh.fh_dentry, &resp->stat, 0);
 	nfserr = nfserrno(err);
 
 	RETURN_STATUS(nfserr);
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 17d0dd9..b19d320 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -218,7 +218,7 @@ encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 	        int err;
 		struct kstat stat;
 
-		err = vfs_getattr(fhp->fh_export->ex_path.mnt, dentry, &stat);
+		err = vfs_getattr(fhp->fh_export->ex_path.mnt, dentry, &stat, 0);
 		if (!err) {
 			*p++ = xdr_one;		/* attributes follow */
 			lease_get_mtime(dentry->d_inode, &stat.mtime);
@@ -271,7 +271,7 @@ void fill_post_wcc(struct svc_fh *fhp)
 		printk("nfsd: inode locked twice during operation.\n");
 
 	err = vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry,
-			&fhp->fh_post_attr);
+			  &fhp->fh_post_attr, 0);
 	if (err)
 		fhp->fh_post_saved = 0;
 	else
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b820c31..e7d2d7f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1780,7 +1780,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			goto out;
 	}
 
-	err = vfs_getattr(exp->ex_path.mnt, dentry, &stat);
+	err = vfs_getattr(exp->ex_path.mnt, dentry, &stat, 0);
 	if (err)
 		goto out_nfserr;
 	if ((bmval0 & (FATTR4_WORD0_FILES_FREE | FATTR4_WORD0_FILES_TOTAL |
@@ -2159,7 +2159,8 @@ out_acl:
 		if (ignore_crossmnt == 0 &&
 		    exp->ex_path.mnt->mnt_root->d_inode == dentry->d_inode) {
 			err = vfs_getattr(exp->ex_path.mnt->mnt_parent,
-				exp->ex_path.mnt->mnt_mountpoint, &stat);
+					  exp->ex_path.mnt->mnt_mountpoint,
+					  &stat, 0);
 			if (err)
 				goto out_nfserr;
 		}
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index e298e26..6317629 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -43,7 +43,7 @@ nfsd_return_attrs(__be32 err, struct nfsd_attrstat *resp)
 	if (err) return err;
 	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
 				    resp->fh.fh_dentry,
-				    &resp->stat));
+				    &resp->stat, 0));
 }
 static __be32
 nfsd_return_dirop(__be32 err, struct nfsd_diropres *resp)
@@ -51,7 +51,7 @@ nfsd_return_dirop(__be32 err, struct nfsd_diropres *resp)
 	if (err) return err;
 	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
 				    resp->fh.fh_dentry,
-				    &resp->stat));
+				    &resp->stat, 0));
 }
 /*
  * Get a file's attributes
@@ -167,7 +167,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
 	if (nfserr) return nfserr;
 	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_path.mnt,
 				    resp->fh.fh_dentry,
-				    &resp->stat));
+				    &resp->stat, 0));
 }
 
 /*
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index afd08e2..25dc0d0 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -207,7 +207,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 __be32 *nfs2svc_encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct kstat stat;
-	vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry, &stat);
+	vfs_getattr(fhp->fh_export->ex_path.mnt, fhp->fh_dentry, &stat, 0);
 	return encode_fattr(rqstp, p, fhp, &stat);
 }
 
diff --git a/fs/stat.c b/fs/stat.c
index 2db740a..624af05 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -37,17 +37,25 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
 
 EXPORT_SYMBOL(generic_fillattr);
 
-int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat,
+		int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	int retval;
+	int attr_flags = ATTR_STAT_ALL;
 
 	retval = security_inode_getattr(mnt, dentry);
 	if (retval)
 		return retval;
 
+	if (flags & AT_NO_SIZE)
+		attr_flags &= ~ATTR_SIZE;
+
+	if (flags & AT_NO_TIMES)
+		attr_flags &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_ATIME);
+
 	if (inode->i_op->getattr)
-		return inode->i_op->getattr(mnt, dentry, stat);
+		return inode->i_op->getattr(mnt, dentry, stat, attr_flags);
 
 	generic_fillattr(inode, stat);
 	return 0;
@@ -55,14 +63,14 @@ int vfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 
 EXPORT_SYMBOL(vfs_getattr);
 
-int vfs_stat_fd(int dfd, char __user *name, struct kstat *stat)
+int vfs_stat_fd(int dfd, char __user *name, struct kstat *stat, int flags)
 {
 	struct path path;
 	int error;
 
 	error = user_path_at(dfd, name, LOOKUP_FOLLOW, &path);
 	if (!error) {
-		error = vfs_getattr(path.mnt, path.dentry, stat);
+		error = vfs_getattr(path.mnt, path.dentry, stat, flags);
 		path_put(&path);
 	}
 	return error;
@@ -70,19 +78,19 @@ int vfs_stat_fd(int dfd, char __user *name, struct kstat *stat)
 
 int vfs_stat(char __user *name, struct kstat *stat)
 {
-	return vfs_stat_fd(AT_FDCWD, name, stat);
+	return vfs_stat_fd(AT_FDCWD, name, stat, 0);
 }
 
 EXPORT_SYMBOL(vfs_stat);
 
-int vfs_lstat_fd(int dfd, char __user *name, struct kstat *stat)
+int vfs_lstat_fd(int dfd, char __user *name, struct kstat *stat, int flags)
 {
 	struct path path;
 	int error;
 
 	error = user_path_at(dfd, name, 0, &path);
 	if (!error) {
-		error = vfs_getattr(path.mnt, path.dentry, stat);
+		error = vfs_getattr(path.mnt, path.dentry, stat, flags);
 		path_put(&path);
 	}
 	return error;
@@ -90,7 +98,7 @@ int vfs_lstat_fd(int dfd, char __user *name, struct kstat *stat)
 
 int vfs_lstat(char __user *name, struct kstat *stat)
 {
-	return vfs_lstat_fd(AT_FDCWD, name, stat);
+	return vfs_lstat_fd(AT_FDCWD, name, stat, 0);
 }
 
 EXPORT_SYMBOL(vfs_lstat);
@@ -101,7 +109,7 @@ int vfs_fstat(unsigned int fd, struct kstat *stat)
 	int error = -EBADF;
 
 	if (f) {
-		error = vfs_getattr(f->f_path.mnt, f->f_path.dentry, stat);
+		error = vfs_getattr(f->f_path.mnt, f->f_path.dentry, stat, 0);
 		fput(f);
 	}
 	return error;
@@ -155,7 +163,7 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
 SYSCALL_DEFINE2(stat, char __user *, filename, struct __old_kernel_stat __user *, statbuf)
 {
 	struct kstat stat;
-	int error = vfs_stat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_stat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_old_stat(&stat, statbuf);
@@ -166,7 +174,7 @@ SYSCALL_DEFINE2(stat, char __user *, filename, struct __old_kernel_stat __user *
 SYSCALL_DEFINE2(lstat, char __user *, filename, struct __old_kernel_stat __user *, statbuf)
 {
 	struct kstat stat;
-	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_old_stat(&stat, statbuf);
@@ -240,7 +248,7 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
 SYSCALL_DEFINE2(newstat, char __user *, filename, struct stat __user *, statbuf)
 {
 	struct kstat stat;
-	int error = vfs_stat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_stat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_new_stat(&stat, statbuf);
@@ -251,7 +259,7 @@ SYSCALL_DEFINE2(newstat, char __user *, filename, struct stat __user *, statbuf)
 SYSCALL_DEFINE2(newlstat, char __user *, filename, struct stat __user *, statbuf)
 {
 	struct kstat stat;
-	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat);
+	int error = vfs_lstat_fd(AT_FDCWD, filename, &stat, 0);
 
 	if (!error)
 		error = cp_new_stat(&stat, statbuf);
@@ -266,13 +274,13 @@ SYSCALL_DEFINE4(newfstatat, int, dfd, char __user *, filename,
 	struct kstat stat;
 	int error = -EINVAL;
 
-	if ((flag & ~AT_SYMLINK_NOFOLLOW) != 0)
+	if ((flag & ~AT_MASK) != 0)
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_new_stat(&stat, statbuf);
@@ -410,9 +418,9 @@ SYSCALL_DEFINE4(fstatat64, int, dfd, char __user *, filename,
 		goto out;
 
 	if (flag & AT_SYMLINK_NOFOLLOW)
-		error = vfs_lstat_fd(dfd, filename, &stat);
+		error = vfs_lstat_fd(dfd, filename, &stat, flag);
 	else
-		error = vfs_stat_fd(dfd, filename, &stat);
+		error = vfs_stat_fd(dfd, filename, &stat, flag);
 
 	if (!error)
 		error = cp_new_stat64(&stat, statbuf);
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index 8603740..b02127a 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -39,6 +39,12 @@
 #define AT_REMOVEDIR		0x200   /* Remove directory instead of
                                            unlinking file.  */
 #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
+#define AT_NO_SIZE		0x800	/* Do not return size or block count */
+#define	AT_NO_TIMES		0x1000	/* Do not return [amc]time */
+#define AT_STRICT		0x2000	/* Guarantee correctness of field
+					 * values */
+
+#define AT_MASK			(AT_SYMLINK_NOFOLLOW|AT_NO_SIZE|AT_NO_TIMES)
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 562d285..cb78dc5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -371,6 +371,8 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 #define ATTR_OPEN	(1 << 15) /* Truncating from open(O_TRUNC) */
 #define ATTR_TIMES_SET	(1 << 16)
 
+#define ATTR_STAT_ALL	(ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_MTIME|ATTR_CTIME)
+
 /*
  * This is the Inode Attributes structure, used for notify_change().  It
  * uses the above definitions as flags, to know which values have changed.
@@ -1471,7 +1473,7 @@ struct inode_operations {
 	void (*truncate) (struct inode *);
 	int (*permission) (struct inode *, int);
 	int (*setattr) (struct dentry *, struct iattr *);
-	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *);
+	int (*getattr) (struct vfsmount *mnt, struct dentry *, struct kstat *, int);
 	int (*setxattr) (struct dentry *, const char *,const void *,size_t,int);
 	ssize_t (*getxattr) (struct dentry *, const char *, void *, size_t);
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
@@ -2235,7 +2237,7 @@ extern int page_symlink(struct inode *inode, const char *symname, int len);
 extern const struct inode_operations page_symlink_inode_operations;
 extern int generic_readlink(struct dentry *, char __user *, int);
 extern void generic_fillattr(struct inode *, struct kstat *);
-extern int vfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int vfs_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 void inode_add_bytes(struct inode *inode, loff_t bytes);
 void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
@@ -2245,8 +2247,8 @@ extern int vfs_readdir(struct file *, filldir_t, void *);
 
 extern int vfs_stat(char __user *, struct kstat *);
 extern int vfs_lstat(char __user *, struct kstat *);
-extern int vfs_stat_fd(int dfd, char __user *, struct kstat *);
-extern int vfs_lstat_fd(int dfd, char __user *, struct kstat *);
+extern int vfs_stat_fd(int dfd, char __user *, struct kstat *, int);
+extern int vfs_lstat_fd(int dfd, char __user *, struct kstat *, int);
 extern int vfs_fstat(unsigned int, struct kstat *);
 
 extern int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
@@ -2269,7 +2271,7 @@ extern int dcache_dir_open(struct inode *, struct file *);
 extern int dcache_dir_close(struct inode *, struct file *);
 extern loff_t dcache_dir_lseek(struct file *, loff_t, int);
 extern int dcache_readdir(struct file *, void *, filldir_t);
-extern int simple_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int simple_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int simple_statfs(struct dentry *, struct kstatfs *);
 extern int simple_link(struct dentry *, struct inode *, struct dentry *);
 extern int simple_unlink(struct inode *, struct dentry *);
-- 
1.6.0.4


--=-dlG9oiA1jorrghM9i+Kz
Content-Disposition: inline; filename="2"
Content-Type: application/mbox; name="2"
Content-Transfer-Encoding: 7bit

>From 88532fa5ea0dd6277ff15572b5f0c66fa8099dd9 Mon Sep 17 00:00:00 2001
From: Mark Fasheh <mfasheh@suse.com>
Date: Tue, 7 Apr 2009 01:01:07 -0700
Subject: [PATCH 2/3] sys_fstatat: Update file systems for new ->getattr callback

The previous patch changed the prototype of ->getattr by adding a flags
field. This patch updates individual file system implementations for the new
flags field.

Signed-off-by: Mark Fasheh <mfasheh@suse.com>
---
 fs/9p/vfs_inode.c          |    2 +-
 fs/afs/inode.c             |    2 +-
 fs/afs/internal.h          |    2 +-
 fs/btrfs/inode.c           |    2 +-
 fs/cifs/cifsfs.h           |    2 +-
 fs/cifs/inode.c            |    2 +-
 fs/coda/inode.c            |    2 +-
 fs/ext4/ext4.h             |    2 +-
 fs/ext4/inode.c            |    2 +-
 fs/fat/fat.h               |    2 +-
 fs/fat/file.c              |    3 ++-
 fs/fuse/dir.c              |    2 +-
 fs/gfs2/ops_inode.c        |    2 +-
 fs/minix/inode.c           |    2 +-
 fs/minix/minix.h           |    2 +-
 fs/nfs/inode.c             |    3 ++-
 fs/ocfs2/file.c            |    3 ++-
 fs/ocfs2/file.h            |    2 +-
 fs/proc/base.c             |    4 ++--
 fs/proc/generic.c          |    2 +-
 fs/proc/proc_net.c         |    2 +-
 fs/proc/proc_sysctl.c      |    2 +-
 fs/proc/root.c             |    2 +-
 fs/sysv/itree.c            |    2 +-
 fs/sysv/sysv.h             |    2 +-
 fs/ubifs/dir.c             |    2 +-
 fs/ubifs/ubifs.h           |    2 +-
 include/linux/coda_linux.h |    2 +-
 include/linux/nfs_fs.h     |    2 +-
 29 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 81f8bbf..e14c502 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -737,7 +737,7 @@ done:
 
 static int
 v9fs_vfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		 struct kstat *stat)
+		 struct kstat *stat, int flags)
 {
 	int err;
 	struct v9fs_session_info *v9ses;
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index c048f06..d87867b 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -301,7 +301,7 @@ error_unlock:
  * read the attributes of an inode
  */
 int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		      struct kstat *stat)
+		struct kstat *stat, int flags)
 {
 	struct inode *inode;
 
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 106be66..04fb51b 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -560,7 +560,7 @@ extern struct inode *afs_iget(struct super_block *, struct key *,
 			      struct afs_callback *);
 extern void afs_zap_data(struct afs_vnode *);
 extern int afs_validate(struct afs_vnode *, struct key *);
-extern int afs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int afs_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int afs_setattr(struct dentry *, struct iattr *);
 extern void afs_clear_inode(struct inode *);
 
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index a0d1dd4..5ada125 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4682,7 +4682,7 @@ fail:
 }
 
 static int btrfs_getattr(struct vfsmount *mnt,
-			 struct dentry *dentry, struct kstat *stat)
+			 struct dentry *dentry, struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 77e190d..3f48788 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -49,7 +49,7 @@ extern int cifs_rmdir(struct inode *, struct dentry *);
 extern int cifs_rename(struct inode *, struct dentry *, struct inode *,
 		       struct dentry *);
 extern int cifs_revalidate(struct dentry *);
-extern int cifs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int cifs_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int cifs_setattr(struct dentry *, struct iattr *);
 
 extern const struct inode_operations cifs_file_inode_ops;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index f121a80..febf385 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1602,7 +1602,7 @@ int cifs_revalidate(struct dentry *direntry)
 }
 
 int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-	struct kstat *stat)
+		 struct kstat *stat, int flags)
 {
 	int err = cifs_revalidate(dentry);
 	if (!err) {
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index 830f51a..ebcfc86 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -220,7 +220,7 @@ static void coda_clear_inode(struct inode *inode)
 	coda_cache_clear_inode(inode);
 }
 
-int coda_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int coda_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags)
 {
 	int err = coda_revalidate_inode(dentry);
 	if (!err)
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index d0f15ef..edf7fbe 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1073,7 +1073,7 @@ extern struct inode *ext4_iget(struct super_block *, unsigned long);
 extern int  ext4_write_inode(struct inode *, int);
 extern int  ext4_setattr(struct dentry *, struct iattr *);
 extern int  ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
-				struct kstat *stat);
+			 struct kstat *stat, int flags);
 extern void ext4_delete_inode(struct inode *);
 extern int  ext4_sync_inode(handle_t *, struct inode *);
 extern void ext4_dirty_inode(struct inode *);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index a2e7952..a566c62 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4823,7 +4823,7 @@ err_out:
 }
 
 int ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		 struct kstat *stat)
+		 struct kstat *stat, int flags)
 {
 	struct inode *inode;
 	unsigned long delalloc_blocks;
diff --git a/fs/fat/fat.h b/fs/fat/fat.h
index ea440d6..c8dd5bc 100644
--- a/fs/fat/fat.h
+++ b/fs/fat/fat.h
@@ -295,7 +295,7 @@ extern const struct inode_operations fat_file_inode_operations;
 extern int fat_setattr(struct dentry * dentry, struct iattr * attr);
 extern void fat_truncate(struct inode *inode);
 extern int fat_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		       struct kstat *stat);
+		       struct kstat *stat, int flags);
 
 /* fat/inode.c */
 extern void fat_attach(struct inode *inode, loff_t i_pos);
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 0a7f4a9..c2b336c 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -253,7 +253,8 @@ void fat_truncate(struct inode *inode)
 	fat_flush_inodes(inode->i_sb, inode, NULL);
 }
 
-int fat_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int fat_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat,
+		int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	generic_fillattr(inode, stat);
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 8b8eebc..7964edf 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -1331,7 +1331,7 @@ static int fuse_setattr(struct dentry *entry, struct iattr *attr)
 }
 
 static int fuse_getattr(struct vfsmount *mnt, struct dentry *entry,
-			struct kstat *stat)
+			struct kstat *stat, int flags)
 {
 	struct inode *inode = entry->d_inode;
 	struct fuse_conn *fc = get_fuse_conn(inode);
diff --git a/fs/gfs2/ops_inode.c b/fs/gfs2/ops_inode.c
index abd5429..99465aa 100644
--- a/fs/gfs2/ops_inode.c
+++ b/fs/gfs2/ops_inode.c
@@ -1129,7 +1129,7 @@ out:
  */
 
 static int gfs2_getattr(struct vfsmount *mnt, struct dentry *dentry,
-			struct kstat *stat)
+			struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct gfs2_inode *ip = GFS2_I(inode);
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index daad3c2..5167138 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -590,7 +590,7 @@ int minix_sync_inode(struct inode * inode)
 	return err;
 }
 
-int minix_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int minix_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags)
 {
 	struct inode *dir = dentry->d_parent->d_inode;
 	struct super_block *sb = dir->i_sb;
diff --git a/fs/minix/minix.h b/fs/minix/minix.h
index e6a0b19..2cc20c7 100644
--- a/fs/minix/minix.h
+++ b/fs/minix/minix.h
@@ -49,7 +49,7 @@ extern unsigned long minix_count_free_inodes(struct minix_sb_info *sbi);
 extern int minix_new_block(struct inode * inode);
 extern void minix_free_block(struct inode *inode, unsigned long block);
 extern unsigned long minix_count_free_blocks(struct minix_sb_info *sbi);
-extern int minix_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int minix_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int __minix_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 64f8719..67db3a9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -502,7 +502,8 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 	}
 }
 
-int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat,
+		int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 8672b95..fe3006e 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -1055,7 +1055,8 @@ bail:
 
 int ocfs2_getattr(struct vfsmount *mnt,
 		  struct dentry *dentry,
-		  struct kstat *stat)
+		  struct kstat *stat,
+		  int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct super_block *sb = dentry->d_inode->i_sb;
diff --git a/fs/ocfs2/file.h b/fs/ocfs2/file.h
index 172f9fb..f63012f 100644
--- a/fs/ocfs2/file.h
+++ b/fs/ocfs2/file.h
@@ -58,7 +58,7 @@ int ocfs2_extend_no_holes(struct inode *inode, u64 new_i_size,
 			  u64 zero_to);
 int ocfs2_setattr(struct dentry *dentry, struct iattr *attr);
 int ocfs2_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		  struct kstat *stat);
+		  struct kstat *stat, int flags);
 int ocfs2_permission(struct inode *inode, int mask);
 
 int ocfs2_should_update_atime(struct inode *inode,
diff --git a/fs/proc/base.c b/fs/proc/base.c
index f715597..8f38338 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1451,7 +1451,7 @@ out_unlock:
 	return NULL;
 }
 
-static int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+static int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *task;
@@ -3104,7 +3104,7 @@ out_no_task:
 	return retval;
 }
 
-static int proc_task_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+static int proc_task_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *p = get_proc_task(inode);
diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index fa678ab..e282e59 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -271,7 +271,7 @@ out:
 }
 
 static int proc_getattr(struct vfsmount *mnt, struct dentry *dentry,
-			struct kstat *stat)
+			struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct proc_dir_entry *de = PROC_I(inode)->pde;
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 04d1270..6ff64b5 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -133,7 +133,7 @@ static struct dentry *proc_tgid_net_lookup(struct inode *dir,
 }
 
 static int proc_tgid_net_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		struct kstat *stat)
+				 struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct net *net;
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 9b1e4e9..3bb38fb 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -335,7 +335,7 @@ static int proc_sys_setattr(struct dentry *dentry, struct iattr *attr)
 	return error;
 }
 
-static int proc_sys_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+static int proc_sys_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags)
 {
 	struct inode *inode = dentry->d_inode;
 	struct ctl_table_header *head = grab_header(inode);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 1e15a2b..20c0335 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -139,7 +139,7 @@ void __init proc_root_init(void)
 	proc_sys_init();
 }
 
-static int proc_root_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat
+static int proc_root_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, int flags
 )
 {
 	generic_fillattr(dentry->d_inode, stat);
diff --git a/fs/sysv/itree.c b/fs/sysv/itree.c
index f042eec..33a8145 100644
--- a/fs/sysv/itree.c
+++ b/fs/sysv/itree.c
@@ -440,7 +440,7 @@ static unsigned sysv_nblocks(struct super_block *s, loff_t size)
 	return blocks;
 }
 
-int sysv_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
+int sysv_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat, 0)
 {
 	struct super_block *s = mnt->mnt_sb;
 	generic_fillattr(dentry->d_inode, stat);
diff --git a/fs/sysv/sysv.h b/fs/sysv/sysv.h
index 5784a31..0d48aa9 100644
--- a/fs/sysv/sysv.h
+++ b/fs/sysv/sysv.h
@@ -146,7 +146,7 @@ extern int sysv_write_inode(struct inode *, int);
 extern int sysv_sync_inode(struct inode *);
 extern int sysv_sync_file(struct file *, struct dentry *, int);
 extern void sysv_set_inode(struct inode *, dev_t);
-extern int sysv_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int sysv_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int sysv_init_icache(void);
 extern void sysv_destroy_icache(void);
 
diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index f55d523..a70380e 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1132,7 +1132,7 @@ out_cancel:
 }
 
 int ubifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		  struct kstat *stat)
+		  struct kstat *stat, int flags)
 {
 	loff_t size;
 	struct inode *inode = dentry->d_inode;
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 0a8341e..0200a3b 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1679,7 +1679,7 @@ int ubifs_setattr(struct dentry *dentry, struct iattr *attr);
 struct inode *ubifs_new_inode(struct ubifs_info *c, const struct inode *dir,
 			      int mode);
 int ubifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
-		  struct kstat *stat);
+		  struct kstat *stat, int flags);
 
 /* xattr.c */
 int ubifs_setxattr(struct dentry *dentry, const char *name,
diff --git a/include/linux/coda_linux.h b/include/linux/coda_linux.h
index dcc228a..e954f46 100644
--- a/include/linux/coda_linux.h
+++ b/include/linux/coda_linux.h
@@ -39,7 +39,7 @@ int coda_open(struct inode *i, struct file *f);
 int coda_release(struct inode *i, struct file *f);
 int coda_permission(struct inode *inode, int mask);
 int coda_revalidate_inode(struct dentry *);
-int coda_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+int coda_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 int coda_setattr(struct dentry *, struct iattr *);
 
 /* this file:  heloers */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fdffb41..cdbd54d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -342,7 +342,7 @@ extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
 extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
-extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+extern int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *, int);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_release(struct inode *, struct file *);
-- 
1.6.0.4


--=-dlG9oiA1jorrghM9i+Kz
Content-Disposition: inline; filename="3"
Content-Type: application/mbox; name="3"
Content-Transfer-Encoding: 7bit

>From a358ec026bb4bcfe0a80a1a38a6c2279749879cf Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 7 Apr 2009 14:57:46 -0700
Subject: [PATCH 3/3] NFS: Support the AT_NO_TIMES and AT_STRICT fstatat flags

If the kernel knows that the application doesn't care about the time
information, then we can avoid having to flush out writes, and we can avoid
revalidating the atime information.

OTOH, if the app sets AT_STRICT then we must force a revalidation of the
attribute metadata.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 67db3a9..76bd229 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -506,9 +506,14 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat,
 		int flags)
 {
 	struct inode *inode = dentry->d_inode;
-	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
+	int force_reval = 0;
 	int err;
 
+	force_reval |= (flags & AT_STRICT) != 0;
+
+	if (!(flags & AT_NO_TIMES))
+		goto do_revalidate;
+
 	/*
 	 * Flush out writes to the server in order to update c/mtime.
 	 *
@@ -531,11 +536,12 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat,
 	 *  - NFS never sets MS_NOATIME or MS_NODIRATIME so there is
 	 *    no point in checking those.
 	 */
- 	if ((mnt->mnt_flags & MNT_NOATIME) ||
- 	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
-		need_atime = 0;
+ 	if (!((mnt->mnt_flags & MNT_NOATIME) ||
+ 	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode))))
+		force_reval |= (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME) != 0;
 
-	if (need_atime)
+do_revalidate:
+	if (force_reval)
 		err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	else
 		err = nfs_revalidate_inode(NFS_SERVER(inode), inode);
-- 
1.6.0.4


--=-dlG9oiA1jorrghM9i+Kz--


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755162Ab2DWTAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 15:00:07 -0400
Date: Mon, 23 Apr 2012 14:59:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120423145935.141cfe0b@tlielax.poochiereds.net>
In-Reply-To: <87zka2qxgs.fsf@tucsk.pomaz.szeredi.hu>
References: <20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420203725.GA3512@us.ibm.com>
	<20120420171314.73801874@corrin.poochiereds.net>
	<CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
	<20120423080012.7c23ef24@tlielax.poochiereds.net>
	<20120423130009.GA13681@fieldses.org>
	<20120423091255.00f926c4@tlielax.poochiereds.net>
	<20120423133412.GB13681@fieldses.org>
	<20120423095021.1a91a23b@tlielax.poochiereds.net>
	<20120423135456.GC13681@fieldses.org>
	<87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
	<20120423111610.0259d610@tlielax.poochiereds.net>
	<87zka2qxgs.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Apr 2012 17:28:19 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Jeff Layton <jlayton@redhat.com> writes:
> 
> >
> > Ok, but again, that only applies to the lookup. It has no bearing on
> > the subsequent operation. For instance, if we're doing:
> >
> >      rename("/foo", "/bar");
> >
> > ...and another client is simultaneously doing:
> >
> >      creat("/bar/baz", 0600);
> >
> > ...and we get back ESTALE from the server on the create because the
> > "old" /bar got replaced after the lookup of it. Then it seems like
> > returning -ENOENT would not be correct since there was never a time
> > where /bar didn't exist...
> 
> It may not be "correct" according to some standard.  But it's what Linux
> does since day one on *all* filesystems.  And probably other OS's that
> have remotely scalable lookup routines.
> 
> Thanks,
> Miklos

The race window with local filesystems is very small though. I'm not
sure I've ever heard of anyone hitting this on one in practice. For NFS
OTOH, it's quite large and it's easy to hit an ESTALE without even
trying very hard.

On a related note, here's a first pass at making the getattr codepaths
handle ERETRYLOOKUP. It assumes that we don't need to fix the devtmpfs
callers or block/loop.c.

The really ugly part is that we have to deal with other callers that
don't have the ability to retry. So we have to convert ERETRYLOOKUP
back to ESTALE in those callers.

Dealing with vfs_getattr is actually fairly trivial. A tougher one would
be the inode_permission codepaths. Those go all over the place and it
would be tough to ensure that we don't leak this new error code to
userspace.

Personally, I think this approach is just too ugly to live in these
other codepaths, but it seems like a reasonable approach to allow us to
retry indefinitely on an ESTALE from a lookup.

-------------------------------------------------------------------------------
vfs-add-an-retry_lookup-functi
-------------------------------------------------------------------------------
vfs: add an retry_lookup function to handle retries on ERETRYLOOKUP

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 fs/namei.c         |   23 +++++++++++++++++++++++
 include/linux/fs.h |    2 ++
 2 files changed, 25 insertions(+), 0 deletions(-)


diff --git a/fs/namei.c b/fs/namei.c
index fef6a0d..a781b0e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -116,6 +116,29 @@
  * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
  * PATH_MAX includes the nul terminator --RR.
  */
+
+/**
+ * retry_lookup - determine whether the caller should retry a lookup and op
+ *
+ * @error: the error we'll be returning
+ * @retry: what retry attempt we're on
+ *
+ */
+bool
+retry_lookup(const long error, const unsigned int retry)
+{
+	long timeout;
+
+	if (likely(error != -ERETRYLOOKUP))
+		return false;
+
+	/* arbitrarily cap backoff delay at 1s */
+	timeout = retry * 2;
+	timeout = timeout > HZ ? HZ : timeout;
+
+	return !schedule_timeout_killable(timeout);
+}
+
 static int do_getname(const char __user *filename, char *page)
 {
 	int retval;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8de6755..5cc03c3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2026,6 +2026,8 @@ extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 extern int filp_close(struct file *, fl_owner_t id);
 extern char * getname(const char __user *);
 
+extern bool retry_lookup(const long error, const unsigned int retry);
+
 /* fs/ioctl.c */
 
 extern int ioctl_preallocate(struct file *filp, void __user *argp);
-------------------------------------------------------------------------------
vfs-make-fstatat-retry-on-esta
-------------------------------------------------------------------------------
vfs: make fstatat retry on ESTALE errors from getattr call

From: Jeff Layton <jlayton@redhat.com>

Have NFS return ERETRYLOOKUP to the vfs when it gets an ESTALE back on a
GETATTR call. The VFS will then retry the lookup and call when it sees
that error.

Unfortunately, we do need to deal with the potential for "leakage" of
this error when we can't retry, so we must check for it in *all* callers
of vfs_getattr and swap -ESTALE for it when it occurs.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---

 fs/ecryptfs/inode.c |    2 +-
 fs/nfs/inode.c      |    2 +-
 fs/nfsd/nfsproc.c   |    1 +
 fs/stat.c           |   20 ++++++++++++--------
 4 files changed, 15 insertions(+), 10 deletions(-)


diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index ab35b11..d4b5f15 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -1068,7 +1068,7 @@ int ecryptfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		generic_fillattr(dentry->d_inode, stat);
 		stat->blocks = lower_stat.blocks;
 	}
-	return rc;
+	return rc == -ERETRYLOOKUP ? -ESTALE : rc;
 }
 
 int
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e8bbfa5..2916e87 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -541,7 +541,7 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	}
 out:
-	return err;
+	return err == -ESTALE ? -ERETRYLOOKUP : err;
 }
 
 static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index e15dc45..5dee967 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -742,6 +742,7 @@ nfserrno (int errno)
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
+		{ nfserr_stale, -ERETRYLOOKUP },
 	};
 	int	i;
 
diff --git a/fs/stat.c b/fs/stat.c
index c733dc5..fb4cf29 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -64,7 +64,7 @@ int vfs_fstat(unsigned int fd, struct kstat *stat)
 		error = vfs_getattr(f->f_path.mnt, f->f_path.dentry, stat);
 		fput(f);
 	}
-	return error;
+	return error == -ERETRYLOOKUP ? -ESTALE : error;
 }
 EXPORT_SYMBOL(vfs_fstat);
 
@@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	unsigned int try = 0;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -84,12 +85,15 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
-	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
-		goto out;
-
-	error = vfs_getattr(path.mnt, path.dentry, stat);
-	path_put(&path);
+	do {
+		error = user_path_at(dfd, filename, lookup_flags, &path);
+		if (!error) {
+			error = vfs_getattr(path.mnt, path.dentry, stat);
+			path_put(&path);
+			break;
+		}
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_lookup(error, try++));
 out:
 	return error;
 }


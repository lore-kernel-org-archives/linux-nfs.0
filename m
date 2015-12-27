Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54560 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbL0C2f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 21:28:35 -0500
Date: Sun, 27 Dec 2015 02:28:31 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Donald Buczek <buczek@molgen.mpg.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH] nfs: do not deny execute access based on outdated mode
 in inode
Message-ID: <20151227022831.GF20997@ZenIV.linux.org.uk>
References: <1451046656-26319-1-git-send-email-buczek@molgen.mpg.de>
 <CAHQdGtSCn4bbx4xiyE7FXmWk3SCY81mvWLJz_1VDow9YtB5VgA@mail.gmail.com>
 <567F29A7.2020906@molgen.mpg.de>
 <CAHQdGtSUmwVv0Do6Gu5=x+BonsoAi4afo_RzOo8KG+wp75t4aw@mail.gmail.com>
 <20151227003837.GE20997@ZenIV.linux.org.uk>
 <CAHQdGtQPGp10hLfEPRG6cq0HmXgNheUhXe+Y+7w0kLRh5+rLig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQPGp10hLfEPRG6cq0HmXgNheUhXe+Y+7w0kLRh5+rLig@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 26, 2015 at 08:26:13PM -0500, Trond Myklebust wrote:

> The may_open() is now happening before NFS gets a chance to issue the
> OPEN rpc call, which is a change w.r.t. the lookup intent code. The
> ordering is significant because it means the OPEN can no longer prime
>  the access cache.

Always had...  Consider e.g. device nodes; there ->open() might very well
have side effects, and ones you do not want to allow for any random caller.
Permissions checks always had been done prior to ->open(), it's not something
new.

> >> > Merry Christmas
> >>
> >> Suggestions Al?
> >
> > Make nfs_permission() relax the checks when it sees MAY_OPEN, if you know
> > that things will be caught by server anyway?
> 
> That can work as long as we're guaranteed that everything that calls
> inode_permission() with MAY_OPEN on a regular file will also follow up
> with a vfs_open() or dentry_open() on success. Is this always the
> case?

1) in do_tmpfile(), followed by do_dentry_open() (not reachable by NFS since
it doesn't have ->tmpfile() instance anyway)

2) in atomic_open(), after the call of ->atomic_open() has succeeded.

3) in do_last(), followed on success by vfs_open()

That's all.  All calls of inode_permission() that get MAY_OPEN come from
may_open(), and there's no other callers of that puppy.


PS: I'm not sure we want to carry that MAY_OPEN in op->acc_mode, actually.
may_open() gets acc_mode without MAY_OPEN only when called from do_last()
in case of O_PATH open.  The check in the very beginning of may_open()
triggers only in that case and might as well be replaced with
	if (likely(!(open_flag & O_PATH))) {
		error = may_open(&nd->path, acc_mode, open_flag);
		if (error)
			goto out;
	}
in that call site (one right after finish_open_created:).  Then we could
bloody well have may_open() do
	error = inode_permission(inode, acc_mode | MAY_OPEN);
and forget about MAY_OPEN in op->acc_mode.

Something like the patch below should be an equivalent transformation and with
that it's really clear what's going on with MAY_OPEN.  Warning: completely
untested.

diff --git a/fs/exec.c b/fs/exec.c
index b06623a..828ec5f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -119,7 +119,7 @@ SYSCALL_DEFINE1(uselib, const char __user *, library)
 	int error = PTR_ERR(tmp);
 	static const struct open_flags uselib_flags = {
 		.open_flag = O_LARGEFILE | O_RDONLY | __FMODE_EXEC,
-		.acc_mode = MAY_READ | MAY_EXEC | MAY_OPEN,
+		.acc_mode = MAY_READ | MAY_EXEC,
 		.intent = LOOKUP_OPEN,
 		.lookup_flags = LOOKUP_FOLLOW,
 	};
@@ -763,7 +763,7 @@ static struct file *do_open_execat(int fd, struct filename *name, int flags)
 	int err;
 	struct open_flags open_exec_flags = {
 		.open_flag = O_LARGEFILE | O_RDONLY | __FMODE_EXEC,
-		.acc_mode = MAY_EXEC | MAY_OPEN,
+		.acc_mode = MAY_EXEC,
 		.intent = LOOKUP_OPEN,
 		.lookup_flags = LOOKUP_FOLLOW,
 	};
diff --git a/fs/namei.c b/fs/namei.c
index 9e102ac..45c702e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2663,10 +2663,6 @@ static int may_open(struct path *path, int acc_mode, int flag)
 	struct inode *inode = dentry->d_inode;
 	int error;
 
-	/* O_PATH? */
-	if (!acc_mode)
-		return 0;
-
 	if (!inode)
 		return -ENOENT;
 
@@ -2688,7 +2684,7 @@ static int may_open(struct path *path, int acc_mode, int flag)
 		break;
 	}
 
-	error = inode_permission(inode, acc_mode);
+	error = inode_permission(inode, MAY_OPEN | acc_mode);
 	if (error)
 		return error;
 
@@ -2880,7 +2876,7 @@ static int atomic_open(struct nameidata *nd, struct dentry *dentry,
 	if (*opened & FILE_CREATED) {
 		WARN_ON(!(open_flag & O_CREAT));
 		fsnotify_create(dir, dentry);
-		acc_mode = MAY_OPEN;
+		acc_mode = 0;
 	}
 	error = may_open(&file->f_path, acc_mode, open_flag);
 	if (error)
@@ -3093,7 +3089,7 @@ retry_lookup:
 		/* Don't check for write permission, don't truncate */
 		open_flag &= ~O_TRUNC;
 		will_truncate = false;
-		acc_mode = MAY_OPEN;
+		acc_mode = 0;
 		path_to_nameidata(&path, nd);
 		goto finish_open_created;
 	}
@@ -3177,10 +3173,11 @@ finish_open:
 		got_write = true;
 	}
 finish_open_created:
-	error = may_open(&nd->path, acc_mode, open_flag);
-	if (error)
-		goto out;
-
+	if (likely(!(open_flag & O_PATH))) {
+		error = may_open(&nd->path, acc_mode, open_flag);
+		if (error)
+			goto out;
+	}
 	BUG_ON(*opened & FILE_OPENED); /* once it's opened, it's opened */
 	error = vfs_open(&nd->path, file, current_cred());
 	if (!error) {
@@ -3267,7 +3264,7 @@ static int do_tmpfile(struct nameidata *nd, unsigned flags,
 		goto out2;
 	audit_inode(nd->name, child, 0);
 	/* Don't check for other permissions, the inode was just created */
-	error = may_open(&path, MAY_OPEN, op->open_flag);
+	error = may_open(&path, 0, op->open_flag);
 	if (error)
 		goto out2;
 	file->f_path.mnt = path.mnt;
diff --git a/fs/open.c b/fs/open.c
index b6f1e96..b25b154 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -887,7 +887,7 @@ EXPORT_SYMBOL(dentry_open);
 static inline int build_open_flags(int flags, umode_t mode, struct open_flags *op)
 {
 	int lookup_flags = 0;
-	int acc_mode;
+	int acc_mode = ACC_MODE(flags);
 
 	if (flags & (O_CREAT | __O_TMPFILE))
 		op->mode = (mode & S_IALLUGO) | S_IFREG;
@@ -909,7 +909,6 @@ static inline int build_open_flags(int flags, umode_t mode, struct open_flags *o
 	if (flags & __O_TMPFILE) {
 		if ((flags & O_TMPFILE_MASK) != O_TMPFILE)
 			return -EINVAL;
-		acc_mode = MAY_OPEN | ACC_MODE(flags);
 		if (!(acc_mode & MAY_WRITE))
 			return -EINVAL;
 	} else if (flags & O_PATH) {
@@ -919,8 +918,6 @@ static inline int build_open_flags(int flags, umode_t mode, struct open_flags *o
 		 */
 		flags &= O_DIRECTORY | O_NOFOLLOW | O_PATH;
 		acc_mode = 0;
-	} else {
-		acc_mode = MAY_OPEN | ACC_MODE(flags);
 	}
 
 	op->open_flag = flags;

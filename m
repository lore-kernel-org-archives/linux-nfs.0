Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50750 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab1IVPd1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 11:33:27 -0400
Received: by fxe4 with SMTP id 4so2850691fxe.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 08:33:26 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, raven@themaw.net,
        viro@zeniv.linux.org.uk, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW
References: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
	<20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
	<6490.1316704925@redhat.com>
Date: Thu, 22 Sep 2011 17:32:55 +0200
In-Reply-To: <6490.1316704925@redhat.com> (David Howells's message of "Thu, 22
	Sep 2011 16:22:05 +0100")
Message-ID: <87litgvbh4.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

David Howells <dhowells@redhat.com> writes:

> One thing that does concern me a little about bringing back the old behaviour
> for stat and *xattr is that there is no reliable way to get at the directory
> mounted directly on the mountpoint (ie. mnt_root).
>
> The problem is that:
>
>  (a) you have to know to trigger the automount with some other operation first
>      and
>
>  (b) the other operation is not atomic wrt to the following stat/xattr, and so
>      the thing mounted on the automount point may be subject to expiration and
>      auto-unmounting before the second operation can proceed.
>
> I'm not sure how much of a problem these are in practice.  Certainly, I'd rate
> (b) as being less serious than (a) as the expiration timeouts are generally
> quite large.  (b) can be suppressed with chdir() or open() also - then you are
> forcing retension of the vfsmount.
>
> The problem can be ameliorated for such as fstatat() by passing an AT_ flag to
> either suppress automounting or to force automounting, but there aren't any
> xattr calls, for example, that take this.
>
>
> I guess it comes down to defining two things:
>
>  (1) What behaviour do we actually want?
>
>  (2) What departure from previous behaviour are we willing to put up with?
>
>
> On the first, I would say definitely we want mass-stat'ers (such as ls) to not
> cause mass automounting.  But for ls, that has been achieved in userspace;
> there are, however, other programs to consider.
>
> I would also say that we do not want lstat(), l*xattr() and co. to cause
> automounting - but maybe they should.  Perhaps if you don't want to cause
> automounting, you should explicitly pass AT_NO_AUTOMOUNT, and all path-taking
> VFS calls should have variants that accept this flag.
>
> Do we want to have guaranteed access to the root of an automounted fs?  Are we
> willing to add getxattrat and similar to get it?

Perhaps we should allow getxattr and friends to work on O_PATH opens to
get the same guarantees?  E.g:

	fd = open(path, O_PATH);
        fgetxattr(fd, ...);

This needs a patch like the following.

Miklos
----


diff --git a/fs/xattr.c b/fs/xattr.c
index f060663..6540324 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -328,7 +328,7 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
 	struct dentry *dentry;
 	int error = -EBADF;
 
-	f = fget(fd);
+	f = fget_raw(fd);
 	if (!f)
 		return error;
 	dentry = f->f_path.dentry;
@@ -414,7 +414,7 @@ SYSCALL_DEFINE4(fgetxattr, int, fd, const char __user *, name,
 	struct file *f;
 	ssize_t error = -EBADF;
 
-	f = fget(fd);
+	f = fget_raw(fd);
 	if (!f)
 		return error;
 	audit_inode(NULL, f->f_path.dentry);
@@ -486,7 +486,7 @@ SYSCALL_DEFINE3(flistxattr, int, fd, char __user *, list, size_t, size)
 	struct file *f;
 	ssize_t error = -EBADF;
 
-	f = fget(fd);
+	f = fget_raw(fd);
 	if (!f)
 		return error;
 	audit_inode(NULL, f->f_path.dentry);
@@ -555,7 +555,7 @@ SYSCALL_DEFINE2(fremovexattr, int, fd, const char __user *, name)
 	struct dentry *dentry;
 	int error = -EBADF;
 
-	f = fget(fd);
+	f = fget_raw(fd);
 	if (!f)
 		return error;
 	dentry = f->f_path.dentry;

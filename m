Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47020 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab0DUHDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Apr 2010 03:03:30 -0400
Date: Wed, 21 Apr 2010 17:03:21 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] Should we expect close-to-open consistency on
 directories?
Message-ID: <20100421170321.41592c77@notabene.brown>
In-Reply-To: <1271768521.25129.94.camel@localhost.localdomain>
References: <20100420172238.520eaa89@notabene.brown>
	<1271768521.25129.94.camel@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Apr 2010 09:02:01 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2010-04-20 at 17:22 +1000, Neil Brown wrote: 
> > Hi Trond et al,
> > 
> > It has come to my attention that NFS directories don't behave consistently
> > in terms of cache consistency.
> > 
> > If, on the client, you have a loop like:
> > 
> >  while true; do sleep 1; ls -l $dirname ; done
> > 
> > and then on the server you make changes to the named directory, there are
> > some cases where you will see changes promptly and some where you wont.
> > 
> > In particular, if $dirname is '.' or the name of an NFS mountpoint, then
> > changes can be delayed by up to acdirmax.  If it is any other path, i.e. with
> > a non-trivial path component that is in the NFS filesystem, then changes
> > are seen promptly.
> > 
> > This seems to me to relate to "close to open" consistency.  Of course with
> > directories the 'close' side isn't relevant, but I still think it should be
> > that when you open a directory it validates the 'change' attribute on that
> > directory over the wire.
> > 
> > However the Linux VFS never tells NFS when a directory is opened.  The
> > current correct behaviour for most directories is achieved through
> > d_revalidate == nfs_lookup_revalidate.
> > 
> > For '.' and mountpoints we need a different approach.  Possibly the VFS could
> > be changed to tell the filesystem when such a directory is opened.  However I
> > don't feel up to that at the moment.
> 
> I agree that mountpoints are problematic in this case, however why isn't
> '.' working correctly? Is the FS_REVAL_DOT mechanism broken?

Yes, the FS_REVAL_DOT mechanism is broken.
Specifically, when you open ".",  ->d_revalidate is called by link_path_walk,
but LOOKUP_PARENT is set, and LOOKUP_OPEN is not set, so
nfs_lookup_verify_inode doesn't force a revalidate.

Then in do_last(), LOOKUP_PARENT is no longer set, and LOOKUP_OPEN is, but
do_last doesn't bother calling ->d_revalidate for LAST_DOT.

I verified this understanding with the following patch which causes 
"ls ." to reliably get current (rather than cached) contents of the directory.


diff --git a/fs/namei.c b/fs/namei.c
index 48e60a1..f9204af 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1620,6 +1620,8 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	switch (nd->last_type) {
 	case LAST_DOTDOT:
 		follow_dotdot(nd);
+		/* fallthrough */
+	case LAST_DOT:
 		dir = nd->path.dentry;
 		if (nd->path.mnt->mnt_sb->s_type->fs_flags & FS_REVAL_DOT) {
 			if (!dir->d_op->d_revalidate(dir, nd)) {
@@ -1627,8 +1629,6 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 				goto exit;
 			}
 		}
-		/* fallthrough */
-	case LAST_DOT:
 	case LAST_ROOT:
 		if (open_flag & O_CREAT)
 			goto exit;

> 
> The other thing is that we should definitely expect the VFS to call
> nfs_opendir() once it has opened the file.

Oh yes, I see that now.  So we could force a cache revalidation there.
But I'm not sure how to test if this is a mountpoint as you suggest below.

Maybe something like the following.  I'm pretty sure this is wrong as it
ignores the return value of d_revalidate, but I didn't know what to do with
the value.
Al ??


--- a/fs/namei.c
+++ b/fs/namei.c
@@ -720,6 +720,11 @@ done:
 	path->mnt = mnt;
 	path->dentry = dentry;
 	__follow_mount(path);
+	if (path->dentry != dentry)
+		if (path->dentry && path->dentry->d_sb &&
+		    (path->dentry->d_sb->s_type->fs_flags & FS_REVAL_DOT))
+			path->dentry->d_op->d_revalidate(
+				path->dentry, nd);
 	return 0;
 
 need_lookup:

Thanks,
NeilBrown


> 
> > An alternative is to do a revalidation in nfs_readdir as below.  i.e. when
> > readdir see f_pos == 0, it requests a revalidation of the page cache.
> > This has two problems:
> > 1/ a seek before the first read would cause the revalidation to be skipped.
> >    This can be fixed by putting a similar test in nfs_llseek_dir, or maybe
> >    triggering off 'dir_cookie == NULL' rather than 'f_pos == 0'.
> > 2/ A normal open/readdir sequence will validate a directory twice, once in the
> >    lookup and once in the readdir.  This is probably undesirable, but it is
> >    not clear to me how to fix it.
> > 
> > 
> > So: is it reasonable to view the current behaviour as 'wrong'?
> >     any suggestions on how to craft a less problematic fix?
> 
> nfs_opendir() should fix case 1/, but still has the issue with case 2/.
> How about just having it force a revalidation if we see that this is a
> mountpoint?
> 
> Cheers
>   Trond


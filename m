From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Should we expect close-to-open consistency on
 directories?
Date: Thu, 06 May 2010 09:58:31 -0400
Message-ID: <1273154311.7699.33.camel@localhost.localdomain>
References: <20100420172238.520eaa89@notabene.brown>
	 <1271768521.25129.94.camel@localhost.localdomain>
	 <20100421170321.41592c77@notabene.brown>
	 <20100506141347.06451f56@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43752 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab0EFN6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 09:58:37 -0400
In-Reply-To: <20100506141347.06451f56-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-05-06 at 14:13 +1000, Neil Brown wrote: 
> On Wed, 21 Apr 2010 17:03:21 +1000
> Neil Brown <neilb@suse.de> wrote:
> 
> > On Tue, 20 Apr 2010 09:02:01 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > On Tue, 2010-04-20 at 17:22 +1000, Neil Brown wrote: 
> > > > Hi Trond et al,
> > > > 
> > > > It has come to my attention that NFS directories don't behave consistently
> > > > in terms of cache consistency.
> > > > 
> > > > If, on the client, you have a loop like:
> > > > 
> > > >  while true; do sleep 1; ls -l $dirname ; done
> > > > 
> > > > and then on the server you make changes to the named directory, there are
> > > > some cases where you will see changes promptly and some where you wont.
> > > > 
> > > > In particular, if $dirname is '.' or the name of an NFS mountpoint, then
> > > > changes can be delayed by up to acdirmax.  If it is any other path, i.e. with
> > > > a non-trivial path component that is in the NFS filesystem, then changes
> > > > are seen promptly.
> > > > 
> > > > This seems to me to relate to "close to open" consistency.  Of course with
> > > > directories the 'close' side isn't relevant, but I still think it should be
> > > > that when you open a directory it validates the 'change' attribute on that
> > > > directory over the wire.
> > > > 
> > > > However the Linux VFS never tells NFS when a directory is opened.  The
> > > > current correct behaviour for most directories is achieved through
> > > > d_revalidate == nfs_lookup_revalidate.
> > > > 
> > > > For '.' and mountpoints we need a different approach.  Possibly the VFS could
> > > > be changed to tell the filesystem when such a directory is opened.  However I
> > > > don't feel up to that at the moment.
> > > 
> > > I agree that mountpoints are problematic in this case, however why isn't
> > > '.' working correctly? Is the FS_REVAL_DOT mechanism broken?
> > 
> > Yes, the FS_REVAL_DOT mechanism is broken.
> > Specifically, when you open ".",  ->d_revalidate is called by link_path_walk,
> > but LOOKUP_PARENT is set, and LOOKUP_OPEN is not set, so
> > nfs_lookup_verify_inode doesn't force a revalidate.
> > 
> > Then in do_last(), LOOKUP_PARENT is no longer set, and LOOKUP_OPEN is, but
> > do_last doesn't bother calling ->d_revalidate for LAST_DOT.
> > 
> > I verified this understanding with the following patch which causes 
> > "ls ." to reliably get current (rather than cached) contents of the directory.
> 
> 
> No replies ... Maybe Al is busy.
> 
> I looked at this again, created a patch that I thought looked good and tested
> it to ensure it addressed both sides of the problem.
> 
> Does it look OK to you Trond?
> Thanks.
> 
> NFS - ensure directory at end of path is always revalidated.
> 
> The FS_REVAL_DOT fs_type flag is meant to ensure that the final component of
> a path is always revalidated, even if it isn't a normal (LAST_NORM) path
> component (which is always revalidated).
> There are two cases where this doesn't happen for NFS
> One is where the last component is '.' as the revalidation happens while
>  LOOKUP_PARENT is set, so NFS ignores it (see nfs_lookup_check_intent).
> The other  is where the directory is a mountpoint, so it is LAST_NORM,
> but that directory is different from the mounted directory.
> 
> This patches fixes these two issues by 
>  1/ extending do_last() to revalidate DOT as well as DOTDOT and
>  2/ extending do_lookup() to revalidate after a successful __follow_mount
>     if FS_REVAL_DOT is set.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index a7dce91..256ae13 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -719,7 +719,11 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
>  done:
>  	path->mnt = mnt;
>  	path->dentry = dentry;
> -	__follow_mount(path);
> +	if (__follow_mount(path) &&
> +	    (path->mnt->mnt_sb->s_type->fs_flags & FS_REVAL_DOT)) {
> +		if (!path->dentry->d_op->d_revalidate(path->dentry, nd))
> +			return -ESTALE;

Won't this prevent you from ever being able to unmount the stale
filesystem?

> +	}
>  	return 0;
>  
>  need_lookup:
> @@ -1619,6 +1623,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
>  	switch (nd->last_type) {
>  	case LAST_DOTDOT:
>  		follow_dotdot(nd);
> +	case LAST_DOT:
>  		dir = nd->path.dentry;
>  		if (nd->path.mnt->mnt_sb->s_type->fs_flags & FS_REVAL_DOT) {
>  			if (!dir->d_op->d_revalidate(dir, nd)) {
> @@ -1627,7 +1632,6 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
>  			}
>  		}
>  		/* fallthrough */
> -	case LAST_DOT:
>  	case LAST_ROOT:
>  		if (open_flag & O_CREAT)
>  			goto exit;
> 



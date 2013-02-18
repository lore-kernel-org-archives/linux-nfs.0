Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756771Ab3BRWG1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 17:06:27 -0500
Date: Mon, 18 Feb 2013 17:05:40 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neilb@suse.de>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>, steved@redhat.com
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130218170540.03cd539e@tlielax.poochiereds.net>
In-Reply-To: <20130218215829.GC3391@fieldses.org>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218074105.38cf49ea@tlielax.poochiereds.net>
	<343C8851-62FD-448D-BFD6-5CBAB8C9DCB5@oracle.com>
	<20130218215829.GC3391@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 18 Feb 2013 16:58:29 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Feb 18, 2013 at 10:36:52AM -0500, Chuck Lever wrote:
> > Before removing FS_REVAL_DOT, I recommend some archaeology:  find out what was fixed by adding that for NFS.  I worked on something related years ago and have a vague recollection about this that there is a situation where revalidating dot is important.
> > 
> > Unfortunately I don't see it in a quick browse through the commit log for fs/nfs/dir.c.  It may be in BitKeeper.
> 
> Everybody should have one of these historical git repos set up--they're
> awesome.
> 
> (No idea if this is helpful, I just note this seems to be where
> FS_REVAL_DOT got added to fs_flags.)
> 
> --b.
> 
> commit e14720a157f5d8745006f44520dfa3b8ac498328
> Author: Trond Myklebust <trond.myklebust@fys.uio.no>
> Date:   Tue Aug 19 21:35:45 2003 -0700
> 
>     [PATCH] Support dentry revalidation under open(".")
>     
>     link_path_walk() currently treats the special filenames ".", ".."
>     and "/" differently in that it does not call down to the filesystem in
>     order to revalidate the cached dentry, but just assumes that it is
>     fine.
>     
>       For most filesystems this is OK, but it the case of the stateless
>     NFS, this means that it circumvents path staleness detection, and the
>     attribute+data cache revalidation code on such common commands as
>     opendir(".").
>     
>     This change provides a way to do such revalidation for NFS without
>     impacting other filesystems.
>     
>     Note: the failure to revalidate the path here does not result in a
>     call to d_invalidate() unlike (all?) other calls to d_revalidate(). It
>     only results in an ESTALE error being returned to the caller.
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index f922236..9e1fcb9 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -572,7 +572,7 @@ int link_path_walk(const char * name, struct nameidata *nd)
>  	while (*name=='/')
>  		name++;
>  	if (!*name)
> -		goto return_base;
> +		goto return_reval;
>  
>  	inode = nd->dentry->d_inode;
>  	if (current->link_count)
> @@ -693,7 +693,7 @@ last_component:
>  				inode = nd->dentry->d_inode;
>  				/* fallthrough */
>  			case 1:
> -				goto return_base;
> +				goto return_reval;
>  		}
>  		if (nd->dentry->d_op && nd->dentry->d_op->d_hash) {
>  			err = nd->dentry->d_op->d_hash(nd->dentry, &this);
> @@ -737,6 +737,20 @@ lookup_parent:
>  			nd->last_type = LAST_DOT;
>  		else if (this.len == 2 && this.name[1] == '.')
>  			nd->last_type = LAST_DOTDOT;
> +		else
> +			goto return_base;
> +return_reval:
> +		/*
> +		 * We bypassed the ordinary revalidation routines.
> +		 * We may need to check the cached dentry for staleness.
> +		 */
> +		if (nd->dentry && nd->dentry->d_sb &&
> +		    (nd->dentry->d_sb->s_type->fs_flags & FS_REVAL_DOT)) {
> +			err = -ESTALE;
> +			/* Note: we do not d_invalidate() */
> +			if (!nd->dentry->d_op->d_revalidate(nd->dentry, nd))
> +				break;
> +		}
>  return_base:
>  		return 0;
>  out_dput:
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1bae8c1..c8e3191 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1343,7 +1343,7 @@ static struct file_system_type nfs_fs_type = {
>  	.name		= "nfs",
>  	.get_sb		= nfs_get_sb,
>  	.kill_sb	= nfs_kill_super,
> -	.fs_flags	= FS_ODD_RENAME,
> +	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT,
>  };
>  
>  #ifdef CONFIG_NFS_V4
> @@ -1575,7 +1575,7 @@ static struct file_system_type nfs4_fs_type = {
>  	.name		= "nfs4",
>  	.get_sb		= nfs4_get_sb,
>  	.kill_sb	= nfs_kill_super,
> -	.fs_flags	= FS_ODD_RENAME,
> +	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT,
>  };
>  
>  #define nfs4_zero_state(nfsi) \
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8df205c..a9e02e3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -89,6 +89,7 @@ extern int leases_enable, dir_notify_enable, lease_break_time;
>  
>  /* public flags for file_system_type */
>  #define FS_REQUIRES_DEV 1 
> +#define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
>  #define FS_ODD_RENAME	32768	/* Temporary stuff; will go away as soon
>  				  * as nfs_rename() will be cleaned up
>  				  */


Thanks Bruce, that helps. I think we still end up with those semantics
with the patch I sent earlier, but Al has a good point that we can do
this a little more cleanly without needing this flag.

I'll plan to take another swipe at it tomorrow and see whether we can't
get this fixed. Once we have that, we'll still need to address the
problem Neil originally brought up on this thread with umount(), but
maybe that will be easier once we've fixed this problem...

-- 
Jeff Layton <jlayton@redhat.com>

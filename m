Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:46853 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756956Ab3BRWRC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 17:17:02 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: More fun with unmounting ESTALE directories.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130218215829.GC3391@fieldses.org>
Date: Mon, 18 Feb 2013 17:16:06 -0500
Cc: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>, steved@redhat.com
Message-Id: <2E3BCAEF-AD53-4BA0-BE70-D93E844538B1@oracle.com>
References: <20130212113813.427b8e05@notabene.brown> <20130214104230.013b7f71@tlielax.poochiereds.net> <20130218132509.0ce779de@notabene.brown> <20130218074105.38cf49ea@tlielax.poochiereds.net> <343C8851-62FD-448D-BFD6-5CBAB8C9DCB5@oracle.com> <20130218215829.GC3391@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 18, 2013, at 4:58 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Feb 18, 2013 at 10:36:52AM -0500, Chuck Lever wrote:
>> Before removing FS_REVAL_DOT, I recommend some archaeology:  find out what was fixed by adding that for NFS.  I worked on something related years ago and have a vague recollection about this that there is a situation where revalidating dot is important.
>> 
>> Unfortunately I don't see it in a quick browse through the commit log for fs/nfs/dir.c.  It may be in BitKeeper.
> 
> Everybody should have one of these historical git repos set up--they're
> awesome.

I forgot I had one of those.  Thanks.

> (No idea if this is helpful, I just note this seems to be where
> FS_REVAL_DOT got added to fs_flags.)

Yes, I believe this is what I was remembering.

> --b.
> 
> commit e14720a157f5d8745006f44520dfa3b8ac498328
> Author: Trond Myklebust <trond.myklebust@fys.uio.no>
> Date:   Tue Aug 19 21:35:45 2003 -0700
> 
>    [PATCH] Support dentry revalidation under open(".")
> 
>    link_path_walk() currently treats the special filenames ".", ".."
>    and "/" differently in that it does not call down to the filesystem in
>    order to revalidate the cached dentry, but just assumes that it is
>    fine.
> 
>      For most filesystems this is OK, but it the case of the stateless
>    NFS, this means that it circumvents path staleness detection, and the
>    attribute+data cache revalidation code on such common commands as
>    opendir(".").
> 
>    This change provides a way to do such revalidation for NFS without
>    impacting other filesystems.
> 
>    Note: the failure to revalidate the path here does not result in a
>    call to d_invalidate() unlike (all?) other calls to d_revalidate(). It
>    only results in an ESTALE error being returned to the caller.
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index f922236..9e1fcb9 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -572,7 +572,7 @@ int link_path_walk(const char * name, struct nameidata *nd)
> 	while (*name=='/')
> 		name++;
> 	if (!*name)
> -		goto return_base;
> +		goto return_reval;
> 
> 	inode = nd->dentry->d_inode;
> 	if (current->link_count)
> @@ -693,7 +693,7 @@ last_component:
> 				inode = nd->dentry->d_inode;
> 				/* fallthrough */
> 			case 1:
> -				goto return_base;
> +				goto return_reval;
> 		}
> 		if (nd->dentry->d_op && nd->dentry->d_op->d_hash) {
> 			err = nd->dentry->d_op->d_hash(nd->dentry, &this);
> @@ -737,6 +737,20 @@ lookup_parent:
> 			nd->last_type = LAST_DOT;
> 		else if (this.len == 2 && this.name[1] == '.')
> 			nd->last_type = LAST_DOTDOT;
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
> return_base:
> 		return 0;
> out_dput:
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 1bae8c1..c8e3191 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1343,7 +1343,7 @@ static struct file_system_type nfs_fs_type = {
> 	.name		= "nfs",
> 	.get_sb		= nfs_get_sb,
> 	.kill_sb	= nfs_kill_super,
> -	.fs_flags	= FS_ODD_RENAME,
> +	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT,
> };
> 
> #ifdef CONFIG_NFS_V4
> @@ -1575,7 +1575,7 @@ static struct file_system_type nfs4_fs_type = {
> 	.name		= "nfs4",
> 	.get_sb		= nfs4_get_sb,
> 	.kill_sb	= nfs_kill_super,
> -	.fs_flags	= FS_ODD_RENAME,
> +	.fs_flags	= FS_ODD_RENAME|FS_REVAL_DOT,
> };
> 
> #define nfs4_zero_state(nfsi) \
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 8df205c..a9e02e3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -89,6 +89,7 @@ extern int leases_enable, dir_notify_enable, lease_break_time;
> 
> /* public flags for file_system_type */
> #define FS_REQUIRES_DEV 1 
> +#define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
> #define FS_ODD_RENAME	32768	/* Temporary stuff; will go away as soon
> 				  * as nfs_rename() will be cleaned up
> 				  */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





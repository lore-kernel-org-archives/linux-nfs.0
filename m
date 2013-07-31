Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760455Ab3GaOVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 10:21:13 -0400
Date: Wed, 31 Jul 2013 10:21:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@netapp.com
Subject: Re: [PATCH] NFSv4: Fix the sync mount option for nfs4 mounts
Message-ID: <20130731102111.51bfc07d@tlielax.poochiereds.net>
In-Reply-To: <1375279301-48950-1-git-send-email-smayhew@redhat.com>
References: <1375279301-48950-1-git-send-email-smayhew@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 31 Jul 2013 10:01:41 -0400
Scott Mayhew <smayhew@redhat.com> wrote:

> The sync mount option stopped working for NFSv4 mounts after commit
> c02d7adf8c5429727a98bad1d039bccad4c61c50 (NFSv4: Replace nfs4_path_walk() with
> FS path lookup in a private namespace).  If MS_SYNCHRONOUS is set in the
> super_block that we're cloning from, then it should be set in the new
> super_block as well.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/super.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 71fdc0d..f6db66d 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2478,6 +2478,10 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
>  	if (server->flags & NFS_MOUNT_NOAC)
>  		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
>  
> +	if (mount_info->cloned != NULL && mount_info->cloned->sb != NULL)
> +		if (mount_info->cloned->sb->s_flags & MS_SYNCHRONOUS)
> +			sb_mntdata.mntflags |= MS_SYNCHRONOUS;
> +
>  	/* Get a superblock - note that we may end up sharing one that already exists */
>  	s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
>  	if (IS_ERR(s)) {

Might also consider this for stable, since it's a regression, though it
is a relatively minor bug...
 
Reviewed-and-Tested-by: Jeff Layton <jlayton@redhat.com>

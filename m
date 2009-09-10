From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Revert default r/wsize behavior
Date: Thu, 10 Sep 2009 17:17:12 -0400
Message-ID: <1252617432.8722.157.camel@heimdal.trondhjem.org>
References: <20090910205950.3670.7878.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52090 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884AbZIJVRM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 17:17:12 -0400
In-Reply-To: <20090910205950.3670.7878.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-10 at 17:05 -0400, Chuck Lever wrote:
> When the "rsize=" or "wsize=" mount options are not specified,
> text-based mounts have slightly different behavior than legacy binary
> mounts.  Text-based mounts use the smaller of the server's maximum
> and the client's maximum, but binary mounts use the smaller of the
> server's _preferred_ size and the client's maximum.
> 
> This difference is actually pretty subtle.  Most servers advertise
> the same value as their largest and their preferred transfer size, so
> the end result is the same in most cases.
> 
> The reason for this difference is that for text-based mounts, if
> r/wsize are not specified, they are set to the largest value supported
> by the client.  For binary mounts, the values are set to zero if these
> options are not specified.
> 
> nfs_server_set_fsinfo() can negotiate the defaults correctly in any
> case.  There's no need to specify any particular value as default in
> the text-based option parsing logic.
> 
> Thanks to James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org> for reporting and
> diagnosing the problem.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> James-
> 
> Is this what you want?

Hmm.... Strictly speaking, I don't think we need to do this for the
NFSv4 case, since that has no equivalent to the NFSv3 rtpref/wtpref
attribute. It might help make the code look more consistent, though.

Note: at some point soon, I want to clean those functions up by
introducing an 'alloc_nfs_parsed_mount_data()' function that both
allocates the nfs_parsed_mount_data structure and initialises it with
the common defaults.


>  fs/nfs/super.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index bde444b..cf0d754 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1635,8 +1635,6 @@ static int nfs_validate_mount_data(void *options,
>  		goto out_no_data;
>  
>  	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
> -	args->rsize		= NFS_MAX_FILE_IO_SIZE;
> -	args->wsize		= NFS_MAX_FILE_IO_SIZE;
>  	args->acregmin		= NFS_DEF_ACREGMIN;
>  	args->acregmax		= NFS_DEF_ACREGMAX;
>  	args->acdirmin		= NFS_DEF_ACDIRMIN;
> @@ -2351,8 +2349,6 @@ static int nfs4_validate_mount_data(void *options,
>  	if (data == NULL)
>  		goto out_no_data;
>  
> -	args->rsize		= NFS_MAX_FILE_IO_SIZE;
> -	args->wsize		= NFS_MAX_FILE_IO_SIZE;
>  	args->acregmin		= NFS_DEF_ACREGMIN;
>  	args->acregmax		= NFS_DEF_ACREGMAX;
>  	args->acdirmin		= NFS_DEF_ACDIRMIN;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbaHENwD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2014 09:52:03 -0400
Message-ID: <1407246721.4455.32.camel@dwysocha-rhel7-t530.usersys.redhat.com>
Subject: Re: [PATCH] nfs: reject changes to resvport and sharecache during
 remount
From: Dave Wysochanski <dwysocha@redhat.com>
Reply-To: dwysocha@redhat.com
To: Scott Mayhew <smayhew@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Date: Tue, 05 Aug 2014 09:52:01 -0400
In-Reply-To: <1407188247-3050-1-git-send-email-smayhew@redhat.com>
References: <1407188247-3050-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-08-04 at 17:37 -0400, Scott Mayhew wrote:
> Commit c8e47028 made it possible to change resvport/noresvport and
> sharecache/nosharecache via a remount operation, neither of which should be
> allowed.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/super.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 084af10..3fd8332 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2180,7 +2180,7 @@ out_no_address:
>  	return -EINVAL;
>  }
>  
> -#define NFS_MOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
> +#define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
>  		| NFS_MOUNT_SECURE \
>  		| NFS_MOUNT_TCP \
>  		| NFS_MOUNT_VER3 \
> @@ -2188,15 +2188,16 @@ out_no_address:
>  		| NFS_MOUNT_NONLM \
>  		| NFS_MOUNT_BROKEN_SUID \
>  		| NFS_MOUNT_STRICTLOCK \
> -		| NFS_MOUNT_UNSHARED \
> -		| NFS_MOUNT_NORESVPORT \
>  		| NFS_MOUNT_LEGACY_INTERFACE)
>  
> +#define NFS_MOUNT_CMP_FLAGMASK (NFS_REMOUNT_CMP_FLAGMASK & \
> +		~(NFS_MOUNT_UNSHARED | NFS_MOUNT_NORESVPORT))
> +
>  static int
>  nfs_compare_remount_data(struct nfs_server *nfss,
>  			 struct nfs_parsed_mount_data *data)
>  {
> -	if ((data->flags ^ nfss->flags) & NFS_MOUNT_CMP_FLAGMASK ||
> +	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
>  	    data->rsize != nfss->rsize ||
>  	    data->wsize != nfss->wsize ||
>  	    data->version != nfss->nfs_client->rpc_ops->version ||

I reviewed this and it looks good to me.

Reviewed-by: Dave Wysochanski <dwysocha@redhat.com>




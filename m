Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab0JaQI1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Oct 2010 12:08:27 -0400
Subject: Re: [PATCH] Regression: fix mounting NFS when NFSv3 support is not
 compiled
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20101031155840.21196.49014.stgit@localhost.localdomain>
References: <20101031155840.21196.49014.stgit@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 31 Oct 2010 12:08:10 -0400
Message-ID: <1288541290.15171.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-10-31 at 17:58 +0200, Paulius Zaleckas wrote:
> Trying to mount NFS (root partition in my case) fails if CONFIG_NFS_V3
> is not selected. nfs_validate_mount_data() returns EPROTONOSUPPORT,
> because of this check:
> 
> #ifndef CONFIG_NFS_V3
> 	if (args->version == 3)
> 		goto out_v3_not_compiled;
> #endif /* !CONFIG_NFS_V3 */
> 
> and args->version was always initialized to 3.
> 
> It was working in 2.6.36
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
> ---
> 
>  fs/nfs/super.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 0a42e8f..8737017 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -2277,7 +2277,11 @@ static int nfs_get_sb(struct file_system_type *fs_type,
>  	};
>  	int error = -ENOMEM;
>  
> +#ifdef CONFIG_NFS_V3
>  	data = nfs_alloc_parsed_mount_data(3);
> +#else
> +	data = nfs_alloc_parsed_mount_data(2);
> +#endif
>  	mntfh = nfs_alloc_fhandle();
>  	if (data == NULL || mntfh == NULL)
>  		goto out_free_fh;
> 

Let's do this as

#ifdef CONFIG_NFS_V3
#define NFS_DEFAULT_VERSION 3
#else
#define NFS_DEFAULT_VERSION 2
#endif

	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);

instead.

Cheers
  Trond

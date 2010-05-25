From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead
 of LAYOUT_NFSV4_FILES
Date: Tue, 25 May 2010 09:55:02 +0300
Message-ID: <4BFB7446.7000608@panasas.com>
References: <> <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3173 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753723Ab0EYGzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 02:55:04 -0400
In-Reply-To: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 24, 2010, 20:37 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> So that we can be consistent with the spec definitions.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Committed at pnfs-all-2.6.34-2010-05-25

Thanks!

Benny

> ---
>  fs/nfs/nfs4filelayout.c    |    4 ++--
>  fs/nfs/nfs4filelayoutdev.c |    2 +-
>  include/linux/nfs4.h       |    2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 9d1274d..d39315a 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -766,8 +766,8 @@ struct layoutdriver_policy_operations filelayout_policy_operations = {
>  };
>  
>  struct pnfs_layoutdriver_type filelayout_type = {
> -	.id = LAYOUT_NFSV4_FILES,
> -	.name = "LAYOUT_NFSV4_FILES",
> +	.id = LAYOUT_NFSV4_1_FILES,
> +	.name = "LAYOUT_NFSV4_1_FILES",
>  	.ld_io_ops = &filelayout_io_operations,
>  	.ld_policy_ops = &filelayout_policy_operations,
>  };
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 462f6de..b540679 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -510,7 +510,7 @@ get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id)
>  		goto out_free;
>  
>  	memcpy(&pdev->dev_id, dev_id, NFS4_PNFS_DEVICEID4_SIZE);
> -	pdev->layout_type = LAYOUT_NFSV4_FILES;
> +	pdev->layout_type = LAYOUT_NFSV4_1_FILES;
>  	pdev->pages = pages;
>  	pdev->pgbase = 0;
>  	pdev->pglen = PAGE_SIZE * max_pages;
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 1730e86..219e6b4 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -565,7 +565,7 @@ enum state_protect_how4 {
>  };
>  
>  enum pnfs_layouttype {
> -	LAYOUT_NFSV4_FILES  = 1,
> +	LAYOUT_NFSV4_1_FILES  = 1,
>  	LAYOUT_OSD2_OBJECTS = 2,
>  	LAYOUT_BLOCK_VOLUME = 3,
>  };

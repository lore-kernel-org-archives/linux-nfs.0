Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:64551 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab1GIOKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jul 2011 10:10:25 -0400
Received: by fxd18 with SMTP id 18so2763105fxd.11
        for <linux-nfs@vger.kernel.org>; Sat, 09 Jul 2011 07:10:24 -0700 (PDT)
Message-ID: <4E18614C.4010002@tonian.com>
Date: Sat, 09 Jul 2011 17:10:20 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Peng Tao <bergwolf@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-04 04:30, Peng Tao wrote:
> There is no need to keep lseg reference when read/write through MDS.
> This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
> because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
> is not NULL.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>

Looks good to me.

Benny

> ---
>  fs/nfs/pnfs.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 30a0394..55fdf02 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1193,6 +1193,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>  
>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>  		data->pnfs_error);
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
>  	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>  				    data->mds_ops, NFS_FILE_SYNC);
>  	return status ? : -EAGAIN;
> @@ -1240,6 +1243,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>  
>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>  		data->pnfs_error);
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
>  	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
>  				   data->mds_ops);
>  	return status ? : -EAGAIN;

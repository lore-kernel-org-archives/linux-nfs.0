Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754366Ab1G0UQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 16:16:27 -0400
Subject: Re: [PATCH v3 25/25] NFS41: Drop lseg ref before fallthru to MDS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 16:16:26 -0400
In-Reply-To: <1311792048-12551-26-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-26-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311797786.25645.28.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Peng Tao <bergwolf@gmail.com>
> 
> There is no need to keep lseg reference when read/write through MDS.
> This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
> because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
> is not NULL.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/pnfs.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 3b20753..fda3019 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1182,6 +1182,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>  
>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>  		data->pnfs_error);
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
>  	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>  				    data->mds_ops, NFS_FILE_SYNC);

As I've said before: the real bug here is calling
nfs_initiate_write()...

> 	return status ? : -EAGAIN;
> @@ -1282,6 +1285,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>  
>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>  		data->pnfs_error);
> +
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
>  	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
>  				   data->mds_ops);
>  	return status ? : -EAGAIN;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] SQUASHME: pnfs-submit: avoid NULL dereference in
 filelayout_commit dprintk
Date: Mon, 14 Jun 2010 20:07:24 -0400
Message-ID: <4C16C43C.4090107@panasas.com>
References: <1276455986-15911-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:65534 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751826Ab0FOAH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 20:07:26 -0400
In-Reply-To: <1276455986-15911-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-14

Thanks!

Benny

On Jun. 13, 2010, 15:06 -0400, Fred Isaman <iisaman@netapp.com> wrote:
> ds_nfs_client will be NULL when filelayout_commit is called.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/nfs4filelayout.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index b82e4ff..e6d45b8 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -569,8 +569,7 @@ filelayout_commit(struct pnfs_layout_type *layoutid, int sync,
>  	struct nfs_write_data *dsdata;
>  	struct nfs4_pnfs_ds *ds;
>  
> -	dprintk("%s data %p pnfs_client %p sync %d\n",
> -		__func__, data, data->fldata.ds_nfs_client->cl_rpcclient, sync);
> +	dprintk("%s data %p sync %d\n", __func__, data, sync);
>  
>  	/* Alloc room for both in one go */
>  	ds_page_list = kzalloc((NFS4_PNFS_MAX_MULTI_CNT + 1) *

From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 2/5] pNFS: recoalesce when ld read pagelist fails
Date: Wed, 10 Aug 2011 10:55:05 -0700
Message-ID: <4E42C5F9.50807@panasas.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com> <1312685635-1593-2-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Benny Halevy <benny@tonian.com>, <linux-nfs@vger.kernel.org>,
	Peng Tao <peng_tao@emc.com>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:40445 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab1HJRzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 13:55:17 -0400
In-Reply-To: <1312685635-1593-2-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/06/2011 07:53 PM, Peng Tao wrote:
> For pnfs pagelist read failure, we need to pg_recoalesce and resend
> IO to mds.
> 
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/internal.h |    2 ++
>  fs/nfs/pnfs.c     |   18 ++++++++++++++----
>  fs/nfs/read.c     |    3 ++-
>  3 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 62f183d..78b662e 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -307,6 +307,8 @@ extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
>  		struct list_head *head);
>  extern int do_nfs_writepage(struct page *page, struct writeback_control *wbc,
>  		struct nfs_pageio_descriptor *pgio);
> +extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
> +		struct inode *inode);
>  extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
>  		struct inode *inode, int ioflags);
>  extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 08aba45..66fc854 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1300,7 +1300,7 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>  int
>  pnfs_ld_read_done(struct nfs_read_data *data)
>  {
> -	int status;
> +	struct nfs_pageio_descriptor pgio;
>  
>  	if (!data->pnfs_error) {
>  		__nfs4_read_done_cb(data);
> @@ -1309,11 +1309,21 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>  		return 0;
>  	}
>  
> +	put_lseg(data->lseg);
> +	data->lseg = NULL;
>  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>  		data->pnfs_error);
> -	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
> -				   data->mds_ops);
> -	return status ? : -EAGAIN;
> +	nfs_pageio_init_read_mds(&pgio, data->inode);
> +	pgio.pg_recoalesce = 1;
> +	while (!list_empty(&data->pages)) {
> +		struct nfs_page *req = nfs_list_entry(data->pages.next);
> +
> +		nfs_pageio_add_request(&pgio, req);
> +	}
> +	nfs_pageio_complete(&pgio);
> +	nfs_readdata_release(data);
> +
> +	return 0;
>  }
>  EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
>  
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 2171c04..2484131 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -112,12 +112,13 @@ static void nfs_readpage_truncate_uninitialised_page(struct nfs_read_data *data)
>  	}
>  }
>  
> -static void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
> +void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
>  		struct inode *inode)
>  {
>  	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops,
>  			NFS_SERVER(inode)->rsize, 0);
>  }
> +EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
>  

Here to. Who is the user of this export?

Boaz

>  void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
>  {


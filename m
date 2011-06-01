Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13924 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab1FAFsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 01:48:00 -0400
Message-ID: <4DE5D287.603@panasas.com>
Date: Wed, 01 Jun 2011 08:47:51 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
In-Reply-To: <1306898310-9229-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/01/2011 06:18 AM, Weston Andros Adamson wrote:
> Use nfs_generic_pg_test instead of pnfs_generic_pg_test.
> 
> This fixes the BUG at fs/nfs/write.c:941 introduced by
> 89a58e32d9105c01022a757fb32ddc3b51bf0025.
> 
> I was able to trigger this BUG reliably using pynfs in pnfs mode,
> by using dd(1) to write many small blocks.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> Fix proposed by Trond.
> 
> Benny- Does this make sense?
> 
>  fs/nfs/nfs4filelayout.c  |    2 +-
>  fs/nfs/pagelist.c        |    5 ++++-
>  include/linux/nfs_page.h |    3 ++-
>  3 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 4269088..1c3bb72 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -661,7 +661,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  	u64 p_stripe, r_stripe;
>  	u32 stripe_unit;
>  
> -	if (!pnfs_generic_pg_test(pgio, prev, req))
> +	if (!nfs_generic_pg_test(pgio, prev, req))
>  		return 0;
>  

pnfs_generic_pg_test is the one that gets the layout.

What you've done is revert to MDS IO

Boaz

>  	if (!pgio->pg_lseg)
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 7913961..1a4b0de 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -204,7 +204,9 @@ nfs_wait_on_request(struct nfs_page *req)
>  			TASK_UNINTERRUPTIBLE);
>  }
>  
> -static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev, struct nfs_page *req)
> +bool
> +nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *prev,
> +		    struct nfs_page *req)
>  {
>  	/*
>  	 * FIXME: ideally we should be able to coalesce all requests
> @@ -218,6 +220,7 @@ static bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_p
>  
>  	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
>  }
> +EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
>  
>  /**
>   * nfs_pageio_init - initialise a page io descriptor
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index 3a34e80..7d8a779 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -96,7 +96,8 @@ extern  int nfs_wait_on_request(struct nfs_page *);
>  extern	void nfs_unlock_request(struct nfs_page *req);
>  extern	int nfs_set_page_tag_locked(struct nfs_page *req);
>  extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
> -
> +extern  bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
> +				 struct nfs_page *prev, struct nfs_page *req);
>  
>  /*
>   * Lock the page of an asynchronous request without getting a new reference


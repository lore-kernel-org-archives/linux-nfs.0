Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:39663 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab1EYQ5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 12:57:05 -0400
Message-ID: <4DDD34DE.4080409@panasas.com>
Date: Wed, 25 May 2011 19:57:02 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SQUASHME: pnfs-obj: pg_test check for max_io_size
References: <4DDA8C3D.5080706@panasas.com> <1306168699-11685-1-git-send-email-bhalevy@panasas.com> <4DDD0675.9080900@panasas.com> <4DDD06F6.7070508@panasas.com>
In-Reply-To: <4DDD06F6.7070508@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-25 16:41, Boaz Harrosh wrote:
> 
> This should be squashed into:
> 	pnfs-obj: osd raid engine read/write implementation
> 
> Implement pg_test vector to test for max IO sizes. We calculate
> a max_io_size member only once, and cache it in lseg so to not
> do so on every page insert.

Looks good (except one minor nit, see inline below).
I prefer to commit it as a separate patch rather than squash it
if ok with you.

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objio_osd.c |   14 +++++++++++++-
>  1 files changed, 13 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 0dcffc2..0dba6ec 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -129,6 +129,8 @@ struct objio_segment {
>  	u64 group_depth;
>  	unsigned group_count;
>  
> +	unsigned max_io_size;
> +
>  	unsigned comps_index;
>  	unsigned num_comps;
>  	/* variable length */
> @@ -366,6 +368,11 @@ extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
>  		objio_seg->group_count = 1;
>  	}
>  
> +	/* Cache this calculation it will hit for every page */
> +	objio_seg->max_io_size = (BIO_MAX_PAGES_KMALLOC * PAGE_SIZE -
> +				  objio_seg->stripe_unit) *
> +				 objio_seg->group_width;
> +
>  	*outp = &objio_seg->lseg;
>  	return 0;
>  
> @@ -1000,7 +1007,12 @@ int
>  objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>  		   struct nfs_page *req)
>  {
> -	return 1;
> +	struct objio_segment *layout = OBJIO_LSEG(pgio->pg_lseg);
> +
> +	if ((pgio->pg_count + req->wb_bytes) > layout->max_io_size)
> +		return 0;
> +	else
> +		return 1;

why not simply do this?
	return (pgio->pg_count + req->wb_bytes) <= layout->max_io_size;

Benny

>  }
>  
>  static struct pnfs_layoutdriver_type objlayout_type = {

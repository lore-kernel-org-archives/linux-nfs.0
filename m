Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:60230 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab1IUJvi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 05:51:38 -0400
Message-ID: <4E79B39B.1080102@panasas.com>
Date: Wed, 21 Sep 2011 12:51:23 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH 1/1] Prevent 3.0 from crashing if it receives a partial
 layout
References: <1316544755-31845-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1316544755-31845-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/20/2011 09:52 PM, Fred Isaman wrote:
> This is a backport of critical parts of
> commit 7c24d9489f "NFSv4.1: File layout only supports whole file layouts"
> 
> It prevents the file layout driver from (incorrectly) using
> partial layouts, but ignores the part of the referenced commmit that
> relies on additional machinery to change the LAYOUTGET request
> based on layout driver.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>

Hi Fred

Do you know of any plans/timetables to support segments in the files-layout-driver?
Both objects and blocks do support it.
Is there some missing generic infrastructure needed or its only LD stuff?

Just that I know of a few files-based servers that can only serve segments
and are unusable with current Linux-pNFS-client which is a great pity.

I wish it could be ready for next BAT

Thanks
Boaz

> ---
>  fs/nfs/nfs4filelayout.c |    8 ++++++++
>  fs/nfs/pnfs.c           |    3 ++-
>  2 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 614c4d2..75af812 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -428,6 +428,14 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
>  
>  	dprintk("--> %s\n", __func__);
>  
> +	/* FIXME: remove this check when layout segment support is added */
> +	if (lgr->range.offset != 0 ||
> +	    lgr->range.length != NFS4_MAX_UINT64) {
> +		dprintk("%s Only whole file layouts supported. Use MDS i/o\n",
> +			__func__);
> +		goto out;
> +	}
> +
>  	if (fl->pattern_offset > lgr->range.offset) {
>  		dprintk("%s pattern_offset %lld too large\n",
>  				__func__, fl->pattern_offset);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a726c0a..36d2a29 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -980,7 +980,8 @@ pnfs_update_layout(struct inode *ino,
>  		arg.offset -= pg_offset;
>  		arg.length += pg_offset;
>  	}
> -	arg.length = PAGE_CACHE_ALIGN(arg.length);
> +	if (arg.length != NFS4_MAX_UINT64)
> +		arg.length = PAGE_CACHE_ALIGN(arg.length);
>  
>  	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
>  	if (!lseg && first) {


From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] typo
Date: Tue, 22 Feb 2011 17:23:47 -0800
Message-ID: <4D6461A3.6090806@panasas.com>
References: <20110223003157.GA8716@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
	Fred Isaman <iisaman@netapp.com>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31819 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab1BWBXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 20:23:50 -0500
In-Reply-To: <20110223003157.GA8716-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks. merged.
Although it's not a critical fix, we should try to push it out
in one of the next submit waves.

Benny

On 2011-02-22 16:31, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/nfs4filelayout.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 91fe4d0..e3e69d6 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -281,7 +281,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
>  	dprintk("--> %s\n", __func__);
>  
>  	if (fl->pattern_offset > lgr->range.offset) {
> -		dprintk("%s pattern_offset %lld to large\n",
> +		dprintk("%s pattern_offset %lld too large\n",
>  				__func__, fl->pattern_offset);
>  		goto out;
>  	}

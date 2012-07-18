Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59108 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857Ab2GRRjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jul 2012 13:39:20 -0400
Date: Wed, 18 Jul 2012 13:39:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Trond.Myklebust@netapp.com, davem@davemloft.net, davej@redhat.com,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Message-ID: <20120718173913.GA1298@fieldses.org>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 17, 2012 at 12:01:26AM +0200, Sasha Levin wrote:
> The buffer size in read_flush() is too small for the longest possible values
> for it. This can lead to a kernel stack corruption:

Thanks!

> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 2afd2a8..f86d95e 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1409,11 +1409,11 @@ static ssize_t read_flush(struct file *file, char __user *buf,
>  			  size_t count, loff_t *ppos,
>  			  struct cache_detail *cd)
>  {
> -	char tbuf[20];
> +	char tbuf[22];

I wonder how common this sort of calculation is in the kernel?  It might
provide some peace of mind to be able to write this something like

	char tbuf[MAXLEN_BASE10_UL + 2]  /* + 2 for final "\n\0" */

--b.

>  	unsigned long p = *ppos;
>  	size_t len;
>  
> -	sprintf(tbuf, "%lu\n", convert_to_wallclock(cd->flush_time));
> +	snprintf(tbuf, sizeof(tbuf), "%lu\n", convert_to_wallclock(cd->flush_time));
>  	len = strlen(tbuf);
>  	if (p >= len)
>  		return 0;
> -- 
> 1.7.8.6
> 

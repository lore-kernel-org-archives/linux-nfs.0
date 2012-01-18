Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755214Ab2ARWlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jan 2012 17:41:11 -0500
Date: Wed, 18 Jan 2012 17:41:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [patch] nfsd: don't allow zero length strings in cache_parse()
Message-ID: <20120118224107.GC27205@fieldses.org>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
 <20120116115258.GC3294@mwanda>
 <20120116155031.GC1750@fieldses.org>
 <20120118095601.GE3356@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120118095601.GE3356@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 18, 2012 at 12:56:02PM +0300, Dan Carpenter wrote:
> There is no point in passing a zero length string here and quite a
> few of that cache_parse() implementations will Oops if count is
> zero.

Thanks, I'll apply.

Could we clean up any checks in cache_parse() that are unnecessary now?

--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 465df9a..8c6598e 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -828,6 +828,8 @@ static ssize_t cache_do_downcall(char *kaddr, const char __user *buf,
>  {
>  	ssize_t ret;
>  
> +	if (count == 0)
> +		return -EINVAL;
>  	if (copy_from_user(kaddr, buf, count))
>  		return -EFAULT;
>  	kaddr[count] = '\0';



From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 2/2] sunrpc/cache: fix module refcnt leak in a failure
	path
Date: Wed, 24 Mar 2010 10:43:41 -0400
Message-ID: <20100324144341.GH12057@fieldses.org>
References: <201003112208.o2BM8Bng013520@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	lizf@cn.fujitsu.com, Trond.Myklebust@netapp.com, neilb@suse.de
To: akpm@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37616 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479Ab0CXOlt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Mar 2010 10:41:49 -0400
In-Reply-To: <201003112208.o2BM8Bng013520-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 11, 2010 at 02:08:10PM -0800, akpm@linux-foundation.org wrote:
> From: Li Zefan <lizf@cn.fujitsu.com>
> 
> Don't forget to release the module refcnt if seq_open() returns failure.

Thanks, applied for 2.6.35.--b.

> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  net/sunrpc/cache.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff -puN net/sunrpc/cache.c~sunrpc-cache-fix-module-refcnt-leak-in-a-failure-path net/sunrpc/cache.c
> --- a/net/sunrpc/cache.c~sunrpc-cache-fix-module-refcnt-leak-in-a-failure-path
> +++ a/net/sunrpc/cache.c
> @@ -1233,8 +1233,10 @@ static int content_open(struct inode *in
>  	if (!cd || !try_module_get(cd->owner))
>  		return -EACCES;
>  	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
> -	if (han == NULL)
> +	if (han == NULL) {
> +		module_put(cd->owner);
>  		return -ENOMEM;
> +	}
>  
>  	han->cd = cd;
>  	return 0;
> _

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34252 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab2GJQbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:31:23 -0400
Date: Tue, 10 Jul 2012 12:31:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eldad Zack <eldad@fogrefinery.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Joe Perches <joe@perches.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2,resend] sunrpc/cache.h: replace simple_strtoul
Message-ID: <20120710163119.GB3884@fieldses.org>
References: <1341603117-13064-1-git-send-email-eldad@fogrefinery.com>
 <1341603117-13064-2-git-send-email-eldad@fogrefinery.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341603117-13064-2-git-send-email-eldad@fogrefinery.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.

On Fri, Jul 06, 2012 at 09:31:57PM +0200, Eldad Zack wrote:
> This patch replaces the usage of simple_strtoul with kstrtoint in
> get_int(), since the simple_str* family doesn't account for overflow
> and is deprecated.
> Also, in this specific case, the long from strtol is silently converted
> to an int by the caller.

(By the way, one advantage which simple_str* does have is documentation.
Some kerneldoc comments might be helpful for kstrto* as well?)

--b.

> 
> As Joe Perches <joe@perches.com> suggested, this patch also removes
> the redundant temporary variable rv, since kstrtoint() will not write to
> anint unless it's successful.
> 
> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
> ---
> Resent to include improvements from Joe Perches and proper changelog as
> J. Bruce Fields kindly pointed out.
>  include/linux/sunrpc/cache.h |    6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 6def1f6..af42596 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -217,8 +217,6 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
>  static inline int get_int(char **bpp, int *anint)
>  {
>  	char buf[50];
> -	char *ep;
> -	int rv;
>  	int len = qword_get(bpp, buf, sizeof(buf));
>  
>  	if (len < 0)
> @@ -226,11 +224,9 @@ static inline int get_int(char **bpp, int *anint)
>  	if (len == 0)
>  		return -ENOENT;
>  
> -	rv = simple_strtol(buf, &ep, 0);
> -	if (*ep)
> +	if (kstrtoint(buf, 0, anint))
>  		return -EINVAL;
>  
> -	*anint = rv;
>  	return 0;
>  }
>  
> -- 
> 1.7.10
> 

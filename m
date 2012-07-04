Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48741 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958Ab2GDX7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jul 2012 19:59:24 -0400
Date: Wed, 4 Jul 2012 19:59:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eldad Zack <eldad@fogrefinery.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
Message-ID: <20120704235921.GA26797@fieldses.org>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
 <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 05, 2012 at 01:00:26AM +0200, Eldad Zack wrote:
> This patch replaces the usage of simple_strtoul with kstrtoint in
> get_int().

Why?

--b.

> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
> ---
>  include/linux/sunrpc/cache.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index 0757887..9a60bcc 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -217,7 +217,7 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
>  static inline int get_int(char **bpp, int *anint)
>  {
>  	char buf[50];
> -	char *ep;
> +	ssize_t ret;
>  	int rv;
>  	int len = qword_get(bpp, buf, 50);
>  
> @@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
>  	if (len == 0)
>  		return -ENOENT;
>  
> -	rv = simple_strtol(buf, &ep, 0);
> -	if (*ep)
> +	ret = kstrtoint(buf, 0, &rv);
> +	if (ret)
>  		return -EINVAL;
>  
>  	*anint = rv;
> -- 
> 1.7.10
> 

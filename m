Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755203Ab2APPue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jan 2012 10:50:34 -0500
Date: Mon, 16 Jan 2012 10:50:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [patch] nfsd: oopses in cache_parse()
Message-ID: <20120116155031.GC1750@fieldses.org>
References: <1321611289-21809-1-git-send-email-levinsasha928@gmail.com>
 <20120116115258.GC3294@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120116115258.GC3294@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 16, 2012 at 02:52:58PM +0300, Dan Carpenter wrote:
> We fixed expkey_parse() in b2ea70afad "nfsd: Fix oops when parsing a
> 0 length export" but there are other cache_parse() implimentations
> which have the same issue.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Since half of the implimentations get this wrong, maybe we should
> just check for this in cache_do_downcall().  Is there ever a valid
> reason to pass a zero length string to cache_parse()?

I don't think so, no.  Checking in cache_do_downcall() sounds like a
good idea.

--b.

> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index cf8a6bd..1d147a8 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -496,7 +496,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  	struct svc_export exp = {}, *expp;
>  	int an_int;
>  
> -	if (mesg[mlen-1] != '\n')
> +	if (mlen < 1 || mesg[mlen - 1] != '\n')
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> index a6e711a..d945d71 100644
> --- a/fs/nfs/dns_resolve.c
> +++ b/fs/nfs/dns_resolve.c
> @@ -217,7 +217,7 @@ static int nfs_dns_parse(struct cache_detail *cd, char *buf, int buflen)
>  	ssize_t len;
>  	int ret = -EINVAL;
>  
> -	if (buf[buflen-1] != '\n')
> +	if (buflen < 1 || buf[buflen - 1] != '\n')
>  		goto out;
>  	buf[buflen-1] = '\0';
>  
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index 9409627..f8456a4 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -202,7 +202,7 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
>  	int len;
>  	int error = -EINVAL;
>  
> -	if (buf[buflen - 1] != '\n')
> +	if (buflen < 1 || buf[buflen - 1] != '\n')
>  		return (-EINVAL);
>  	buf[buflen - 1]= '\0';
>  
> @@ -378,7 +378,7 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
>  	char *buf1;
>  	int error = -EINVAL;
>  
> -	if (buf[buflen - 1] != '\n')
> +	if (buflen < 1 || buf[buflen - 1] != '\n')
>  		return (-EINVAL);
>  	buf[buflen - 1]= '\0';
>  
> 


